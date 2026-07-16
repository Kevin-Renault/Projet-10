export interface Chat {
    id: number;
    chatUuid: string;
    subject: string | null;
    bookingId: number | null;
    createdBy: number;
    status: string;
    assignedAgentId: number | null;
    createdAt: string;
    updatedAt: string;
}

export type AgentChatFilter = 'all' | 'closed' | 'mine' | 'waiting' | 'assigned';

export interface ChatMessage {
    id: number;
    chatId: number;
    senderId: number;
    contentType: string;
    content: string;
    status: string;
    createdAt: string;
    updatedAt: string;
}

export interface ChatParticipant {
    id: number;
    chatId: number;
    userId: number;
    role: string;
    joinedAt: string;
    leftAt: string | null;
}

export interface CreateChatPayload {
    subject?: string;
    bookingId?: number;
    participantIds?: number[];
}

export type ChatRole = 'client' | 'agent';

export interface SendChatMessagePayload {
    content: string;
    contentType?: string;
}

export interface AddChatParticipantPayload {
    userId: number;
    role?: string;
}
