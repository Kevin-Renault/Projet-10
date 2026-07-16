import { inject, Injectable } from '@angular/core';
import { Observable, of, throwError, EMPTY } from 'rxjs';
import { ChatEvent } from '../../models/chat-event.model';
import { MOCK_USERS } from '../../../shared/mock/mock-users.data';
import { AUTH_DATASOURCE } from '../../auth/auth-datasource.interface';
import {
    AddChatParticipantPayload,
    AgentChatFilter,
    Chat,
    ChatMessage,
    ChatParticipant,
    CreateChatPayload,
    SendChatMessagePayload
} from '../../models/chat.model';
import { ChatDataSource } from '../chat-datasource.interface';

@Injectable({ providedIn: 'root' })
export class ChatMockService implements ChatDataSource {
    private readonly authDataSource = inject(AUTH_DATASOURCE);
    private readonly chats: Chat[] = [
        {
            id: 1,
            chatUuid: '00000000-0000-4000-8000-000000000001',
            subject: 'Accompagnement Java',
            bookingId: null,
            createdBy: 1,
            status: 'open',
            createdAt: '2024-02-01T09:00:00Z',
            updatedAt: '2024-02-02T14:30:00Z'
        },
        {
            id: 2,
            chatUuid: '00000000-0000-4000-8000-000000000002',
            subject: 'Question sur Angular',
            bookingId: null,
            createdBy: 2,
            status: 'open',
            createdAt: '2024-02-03T10:00:00Z',
            updatedAt: '2024-02-03T11:15:00Z'
        }
    ];

    private readonly messages: ChatMessage[] = [
        {
            id: 1,
            chatId: 1,
            senderId: 1,
            contentType: 'text',
            content: 'Bonjour, je voudrais revoir les bases de Java.',
            status: 'sent',
            createdAt: '2024-02-01T09:05:00Z',
            updatedAt: '2024-02-01T09:05:00Z'
        },
        {
            id: 2,
            chatId: 1,
            senderId: 1,
            contentType: 'text',
            content: 'Bonjour ! Nous pouvons commencer par la programmation objet.',
            status: 'sent',
            createdAt: '2024-02-02T14:30:00Z',
            updatedAt: '2024-02-02T14:30:00Z'
        },
        {
            id: 3,
            chatId: 2,
            senderId: 2,
            contentType: 'text',
            content: 'Pouvez-vous m aider sur les composants Angular ?',
            status: 'sent',
            createdAt: '2024-02-03T11:15:00Z',
            updatedAt: '2024-02-03T11:15:00Z'
        }
    ];

    private readonly participants: ChatParticipant[] = [
        { id: 1, chatId: 1, userId: 1, role: 'client', joinedAt: '2024-02-01T09:00:00Z', leftAt: null },
        { id: 2, chatId: 1, userId: 2, role: 'agent', joinedAt: '2024-02-01T09:00:00Z', leftAt: null },
        { id: 3, chatId: 2, userId: 1, role: 'client', joinedAt: '2024-02-03T10:00:00Z', leftAt: null },
    ];

    private get currentUserId(): number {
        return this.authDataSource.getCurrentUser().id;
    }

    getAll(): Observable<Chat[]> {
        return of(this.chats.filter(chat => this.participants.some(
            participant => participant.chatId === chat.id && participant.userId === this.currentUserId && !participant.leftAt
        )));
    }

    getOpen(): Observable<Chat[]> {
        if (this.authDataSource.getCurrentUser().role !== 'agent') return of([]);

        return of(this.chats.filter(chat => chat.status === 'open' && !this.participants.some(
            participant => participant.chatId === chat.id && participant.userId === this.currentUserId && !participant.leftAt
        )));
    }

    getAgentView(filter: AgentChatFilter): Observable<Chat[]> {
        if (this.authDataSource.getCurrentUser().role !== 'agent') return of([]);

        return of(this.chats.filter(chat => {
            if (filter === 'closed') return chat.status === 'closed' || chat.status === 'archived';
            if (filter === 'waiting') return chat.status === 'open' || chat.status === 'waiting_reassignment';
            if (filter === 'assigned') return chat.status === 'assigned';
            if (filter === 'mine') return this.participants.some(participant =>
                participant.chatId === chat.id && participant.userId === this.currentUserId
                && participant.role === 'agent' && !participant.leftAt);
            return true;
        }));
    }

    getById(chatId: number): Observable<Chat> {
        return of(this.chats.find(chat => chat.id === chatId)!);
    }

    create(payload: CreateChatPayload): Observable<Chat> {
        const now = new Date().toISOString();
        const chat: Chat = {
            id: Date.now(),
            chatUuid: crypto.randomUUID(),
            subject: payload.subject || 'Nouvelle conversation',
            bookingId: payload.bookingId ?? null,
            createdBy: this.currentUserId,
            status: 'open',
            createdAt: now,
            updatedAt: now
        };
        this.chats.unshift(chat);
        this.participants.push({
            id: Date.now() + 1,
            chatId: chat.id,
            userId: this.currentUserId,
            role: 'client',
            joinedAt: now,
            leftAt: null
        });
        return of(chat);
    }

    claim(chatId: number): Observable<Chat> {
        if (this.authDataSource.getCurrentUser().role !== 'agent') {
            return throwError(() => new Error('Seuls les agents peuvent prendre en charge une demande.'));
        }

        const chat = this.chats.find(item => item.id === chatId)!;
        chat.status = 'assigned';
        this.participants.push({
            id: Date.now(),
            chatId,
            userId: this.currentUserId,
            role: 'agent',
            joinedAt: new Date().toISOString(),
            leftAt: null
        });
        return of(chat);
    }

    release(chatId: number): Observable<Chat> {
        if (this.authDataSource.getCurrentUser().role !== 'agent') {
            return throwError(() => new Error('Seuls les agents peuvent libérer une conversation.'));
        }
        const chat = this.chats.find(item => item.id === chatId)!;
        const participant = this.participants.find(item =>
            item.chatId === chatId && item.userId === this.currentUserId && item.role === 'agent' && !item.leftAt);
        if (participant) participant.leftAt = new Date().toISOString();
        chat.status = 'waiting_reassignment';
        return of(chat);
    }

    close(chatId: number): Observable<Chat> {
        if (this.authDataSource.getCurrentUser().role === 'agent') {
            return throwError(() => new Error('Seul le client peut clôturer la conversation.'));
        }
        const chat = this.chats.find(item => item.id === chatId)!;
        chat.status = 'closed';
        return of(chat);
    }

    getMessages(chatId: number): Observable<ChatMessage[]> {
        return of(this.messages
            .filter(message => message.chatId === chatId)
            .sort((left, right) => new Date(left.createdAt).getTime() - new Date(right.createdAt).getTime()));
    }

    sendMessage(chatId: number, payload: SendChatMessagePayload): Observable<ChatMessage> {
        const chat = this.chats.find(item => item.id === chatId);
        if (chat?.status === 'closed') {
            return throwError(() => new Error('Cette conversation est clôturée.'));
        }
        const now = new Date().toISOString();
        const message: ChatMessage = {
            id: Date.now(),
            chatId,
            senderId: this.currentUserId,
            contentType: payload.contentType || 'text',
            content: payload.content,
            status: 'sent',
            createdAt: now,
            updatedAt: now
        };
        this.messages.push(message);
        if (chat) chat.updatedAt = now;
        return of(message);
    }

    getParticipants(chatId: number): Observable<ChatParticipant[]> {
        return of(this.participants.filter(participant => participant.chatId === chatId && !participant.leftAt));
    }

    addParticipant(chatId: number, payload: AddChatParticipantPayload): Observable<ChatParticipant> {
        const participant: ChatParticipant = {
            id: Date.now(),
            chatId,
            userId: payload.userId,
            role: payload.role || 'agent',
            joinedAt: new Date().toISOString(),
            leftAt: null
        };
        this.participants.push(participant);
        return of(participant);
    }

    chatEvents(_chatId: number): Observable<ChatEvent> {
        return EMPTY;
    }

    agentEvents(): Observable<ChatEvent> {
        return EMPTY;
    }

    userName(userId: number): string {
        return MOCK_USERS.find(user => user.id === userId)?.username || 'Utilisateur';
    }
}
