import { Provider } from '@angular/core';

import { AUTH_DATASOURCE } from '../auth/auth-datasource.interface';
import { AuthMockService } from '../auth/auth-mock.service';
import { AuthService } from '../auth/auth.service';

import { USER_DATASOURCE } from '../services/user-datasource.interface';
import { UserMockService } from '../services/mock/user-mock.service';
import { UserService } from '../services/real/user.service';

import { CHAT_DATASOURCE } from '../services/chat-datasource.interface';
import { ChatMockService } from '../services/mock/chat-mock.service';
import { ChatService } from '../services/real/chat.service';

export type DataSourceProvidersOptions = {
    useMock: boolean;
};

/**
 * Centralise le câblage DI des datasources (mock vs real).
 *
 * Usage app:
 *  providers: [ ...provideDataSources({ useMock: environment.useMock }) ]
 *
 * Usage TU:
 *  TestBed.configureTestingModule({ providers: [ ...provideDataSources({ useMock: true }) ] })
 */
export function provideDataSources(options: DataSourceProvidersOptions): Provider[] {
    return [
        {
            provide: AUTH_DATASOURCE,
            // useExisting évite d'avoir 2 instances d'AuthService/AuthMockService
            // (une via providedIn: 'root' + une via le token).
            useExisting: options.useMock ? AuthMockService : AuthService,
        },
        {
            provide: USER_DATASOURCE,
            useClass: options.useMock ? UserMockService : UserService,
        },
        {
            provide: CHAT_DATASOURCE,
            useClass: options.useMock ? ChatMockService : ChatService,
        },
    ];
}
