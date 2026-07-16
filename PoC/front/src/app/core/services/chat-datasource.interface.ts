import { InjectionToken } from '@angular/core';
import { Observable } from 'rxjs';
import { ChatEvent } from '../models/chat-event.model';
import {
    AddChatParticipantPayload,
    AgentChatFilter,
    Chat,
    ChatMessage,
    ChatParticipant,
    CreateChatPayload,
    SendChatMessagePayload
} from '../models/chat.model';

export const CHAT_DATASOURCE = new InjectionToken<ChatDataSource>('ChatDataSource');

export interface ChatDataSource {
    getAll(): Observable<Chat[]>;
    getOpen(): Observable<Chat[]>;
    getAgentView(filter: AgentChatFilter): Observable<Chat[]>;
    getById(chatId: number): Observable<Chat>;
    create(payload: CreateChatPayload): Observable<Chat>;
    claim(chatId: number): Observable<Chat>;
    release(chatId: number): Observable<Chat>;
    close(chatId: number): Observable<Chat>;
    getMessages(chatId: number): Observable<ChatMessage[]>;
    sendMessage(chatId: number, payload: SendChatMessagePayload): Observable<ChatMessage>;
    getParticipants(chatId: number): Observable<ChatParticipant[]>;
    addParticipant(chatId: number, payload: AddChatParticipantPayload): Observable<ChatParticipant>;
    chatEvents(chatId: number): Observable<ChatEvent>;
    agentEvents(): Observable<ChatEvent>;
}
