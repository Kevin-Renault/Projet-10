import { HttpErrorResponse, HttpHandler, HttpHeaders, HttpRequest, provideHttpClient } from '@angular/common/http';
import { TestBed } from '@angular/core/testing';
import { of, throwError } from 'rxjs';
import { CsrfTokenService } from '../auth/csrf-token.service';
import { CredentialsInterceptor } from './CredentialsInterceptor';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';

describe('CredentialsInterceptor (jest)', () => {
    it('always sets withCredentials=true', () => {
        TestBed.configureTestingModule({
            providers: [CredentialsInterceptor, CsrfTokenService],
        });

        const interceptor = TestBed.inject(CredentialsInterceptor);
        const handler: HttpHandler = {
            handle: jest.fn(() => of({} as any)),
        };

        const req = new HttpRequest('GET', '/api/ping');
        interceptor.intercept(req, handler).subscribe();

        const patchedReq = (handler.handle as jest.Mock).mock.calls[0][0] as HttpRequest<unknown>;
        expect(patchedReq.withCredentials).toBe(true);
    });

    it('adds X-XSRF-TOKEN only for unsafe methods when a token exists', () => {
        TestBed.configureTestingModule({
            providers: [CredentialsInterceptor, CsrfTokenService],
        });

        const interceptor = TestBed.inject(CredentialsInterceptor);
        const csrf = TestBed.inject(CsrfTokenService);
        csrf.setToken('token-123');

        const handler: HttpHandler = {
            handle: jest.fn(() => of({} as any)),
        };

        interceptor.intercept(new HttpRequest('POST', '/api/x', {}), handler).subscribe();
        const postReq = (handler.handle as jest.Mock).mock.calls[0][0] as HttpRequest<unknown>;
        expect(postReq.headers.get('X-XSRF-TOKEN')).toBe('token-123');

        (handler.handle as jest.Mock).mockClear();
        interceptor.intercept(new HttpRequest('GET', '/api/x'), handler).subscribe();
        const getReq = (handler.handle as jest.Mock).mock.calls[0][0] as HttpRequest<unknown>;
        expect(getReq.headers.has('X-XSRF-TOKEN')).toBe(false);
    });

    it('does not override an existing X-XSRF-TOKEN header', () => {
        TestBed.configureTestingModule({
            providers: [CredentialsInterceptor, CsrfTokenService],
        });

        const interceptor = TestBed.inject(CredentialsInterceptor);
        const csrf = TestBed.inject(CsrfTokenService);
        csrf.setToken('token-should-not-be-used');

        const handler: HttpHandler = {
            handle: jest.fn(() => of({} as any)),
        };

        const req = new HttpRequest('PUT', '/api/x', {}, {
            headers: new HttpHeaders({ 'X-XSRF-TOKEN': 'already-set' }),
        });

        interceptor.intercept(req, handler).subscribe();
        const patchedReq = (handler.handle as jest.Mock).mock.calls[0][0] as HttpRequest<unknown>;
        expect(patchedReq.headers.get('X-XSRF-TOKEN')).toBe('already-set');
    });

    it('refreshes CSRF and retries once after a 403 on an unsafe request', (done) => {
        TestBed.configureTestingModule({
            providers: [
                CredentialsInterceptor,
                CsrfTokenService,
                provideHttpClient(),
                provideHttpClientTesting(),
            ],
        });

        const interceptor = TestBed.inject(CredentialsInterceptor);
        TestBed.inject(CsrfTokenService).setToken('stale-token');
        const handler: HttpHandler = {
            handle: jest.fn()
                .mockReturnValueOnce(throwError(() => new HttpErrorResponse({ status: 403 })))
                .mockReturnValueOnce(of({} as any)),
        };

        interceptor.intercept(new HttpRequest('POST', '/api/chats/1/messages', {}), handler).subscribe({
            next: () => {
                expect(handler.handle).toHaveBeenCalledTimes(2);
                expect((handler.handle as jest.Mock).mock.calls[1][0].headers.get('X-XSRF-TOKEN'))
                    .toBe('csrf-retry');
                done();
            },
            error: done,
        });

        const csrfRequest = TestBed.inject(HttpTestingController).expectOne('/api/auth/csrf');
        csrfRequest.flush(null, { headers: new HttpHeaders({ 'X-XSRF-TOKEN': 'csrf-retry' }) });
    });
});
