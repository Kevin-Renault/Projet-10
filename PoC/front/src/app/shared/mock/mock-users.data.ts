import { User } from '../../core/models/user.model';

export const MOCK_USERS: User[] = [
    { id: 1, username: 'alice', email: 'alice@email.com', password: 'Mock-password1', role: 'client' },
    { id: 2, username: 'kevin', email: 'kevin.renault@example.com', password: 'Password-123_1', role: 'agent' },
    { id: 3, username: 'charlie', email: 'charlie@email.com', password: 'Mock-password3', role: 'client' },
    { id: 4, username: 'diana', email: 'diana@email.com', password: 'Mock-password4', role: 'client' },
    { id: 5, username: 'eve', email: 'eve@email.com', password: 'Mock-password5', role: 'client' }
];
