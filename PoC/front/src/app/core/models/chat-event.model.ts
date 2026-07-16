export interface ChatEvent {
    type: 'chat-created' | 'chat-claimed' | 'chat-without-agent' | 'chat-closed' | 'message-created';
    chatId: number;
    data: unknown;
}
