import { provideDataSources } from './data-sources.providers';
import { AUTH_DATASOURCE } from '../auth/auth-datasource.interface';
import { AuthMockService } from '../auth/auth-mock.service';
import { AuthService } from '../auth/auth.service';
import { USER_DATASOURCE } from '../services/user-datasource.interface';
import { UserMockService } from '../services/mock/user-mock.service';
import { UserService } from '../services/real/user.service';
import { CHAT_DATASOURCE } from '../services/chat-datasource.interface';
import { ChatMockService } from '../services/mock/chat-mock.service';
import { ChatService } from '../services/real/chat.service';

describe('provideDataSources (jest)', () => {
    it('wires mock providers when useMock=true', () => {
        const providers = provideDataSources({ useMock: true }) as any[];
        const byToken = new Map(providers.map(p => [p.provide, p]));

        expect(byToken.get(AUTH_DATASOURCE).useExisting).toBe(AuthMockService);
        expect(byToken.get(USER_DATASOURCE).useClass).toBe(UserMockService);
        expect(byToken.get(CHAT_DATASOURCE).useClass).toBe(ChatMockService);
    });

    it('wires real providers when useMock=false', () => {
        const providers = provideDataSources({ useMock: false }) as any[];
        const byToken = new Map(providers.map(p => [p.provide, p]));

        expect(byToken.get(AUTH_DATASOURCE).useExisting).toBe(AuthService);
        expect(byToken.get(USER_DATASOURCE).useClass).toBe(UserService);
        expect(byToken.get(CHAT_DATASOURCE).useClass).toBe(ChatService);
    });
});
