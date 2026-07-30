import { User } from '../../core/models/user.model';

export const MOCK_USERS: User[] = [
    { id: 1, username: 'agent_01', email: 'agent_01@gmail.com', password: 'Agent_01@MDP', role: 'agent' },
    { id: 2, username: 'agent_02', email: 'agent_02@gmail.com', password: 'Agent_02@MDP', role: 'agent' },
    { id: 3, username: 'client_01', email: 'client_01@gmail.com', password: 'Client_01@MDP', role: 'client' },
    { id: 4, username: 'client_02', email: 'client_02@gmail.com', password: 'Client_02@MDP', role: 'client' },
    { id: 5, username: 'client_03', email: 'client_03@gmail.com', password: 'Client_03@MDP', role: 'client' }
];
