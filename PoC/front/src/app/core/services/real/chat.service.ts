import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ChatEvent } from '../../models/chat-event.model';
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
export class ChatService implements ChatDataSource {
    private readonly apiUrl = '/api/chats';

    constructor(private readonly http: HttpClient) { }

    getAll(): Observable<Chat[]> {
        return this.http.get<Chat[]>(this.apiUrl);
    }

    getOpen(): Observable<Chat[]> {
        return this.http.get<Chat[]>(`${this.apiUrl}/open`);
    }

    getAgentView(filter: AgentChatFilter): Observable<Chat[]> {
        return this.http.get<Chat[]>(`${this.apiUrl}/agent-view`, { params: { filter } });
    }

    getById(chatId: number): Observable<Chat> {
        return this.http.get<Chat>(`${this.apiUrl}/${chatId}`);
    }

    create(payload: CreateChatPayload): Observable<Chat> {
        return this.http.post<Chat>(this.apiUrl, payload);
    }

    claim(chatId: number): Observable<Chat> {
        return this.http.post<Chat>(`${this.apiUrl}/${chatId}/claim`, {});
    }

    release(chatId: number): Observable<Chat> {
        return this.http.post<Chat>(`${this.apiUrl}/${chatId}/release`, {});
    }

    close(chatId: number): Observable<Chat> {
        return this.http.post<Chat>(`${this.apiUrl}/${chatId}/close`, {});
    }

    getMessages(chatId: number): Observable<ChatMessage[]> {
        return this.http.get<ChatMessage[]>(`${this.apiUrl}/${chatId}/messages`);
    }

    sendMessage(chatId: number, payload: SendChatMessagePayload): Observable<ChatMessage> {
        return this.http.post<ChatMessage>(`${this.apiUrl}/${chatId}/messages`, payload);
    }

    getParticipants(chatId: number): Observable<ChatParticipant[]> {
        return this.http.get<ChatParticipant[]>(`${this.apiUrl}/${chatId}/participants`);
    }

    addParticipant(chatId: number, payload: AddChatParticipantPayload): Observable<ChatParticipant> {
        return this.http.post<ChatParticipant>(`${this.apiUrl}/${chatId}/participants`, payload);
    }

    chatEvents(chatId: number): Observable<ChatEvent> {
        return this.openEventStream(`${this.apiUrl}/${chatId}/events`);
    }

    agentEvents(): Observable<ChatEvent> {
        return this.openEventStream(`${this.apiUrl}/agent-events`);
    }

    private openEventStream(url: string): Observable<ChatEvent> {
        return new Observable<ChatEvent>(subscriber => {
            const source = new EventSource(url, { withCredentials: true });
            const onEvent = (event: Event) => {
                try {
                    subscriber.next(JSON.parse((event as MessageEvent).data) as ChatEvent);
                } catch (error) {
                    subscriber.error(error);
                }
            };

            source.addEventListener('chat-event', onEvent);
            source.onerror = () => undefined;

            return () => {
                source.removeEventListener('chat-event', onEvent);
                source.close();
            };
        });
    }
}
