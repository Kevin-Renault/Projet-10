import { Injectable, inject } from '@angular/core';
import { HttpBackend, HttpClient, HttpErrorResponse, HttpEvent, HttpHandler, HttpInterceptor, HttpRequest } from '@angular/common/http';
import { HttpContextToken } from '@angular/common/http';
import { catchError, finalize, map, Observable, shareReplay, switchMap, throwError } from 'rxjs';
import { CsrfTokenService } from '../auth/csrf-token.service';

@Injectable()
export class CredentialsInterceptor implements HttpInterceptor {
    private readonly csrfTokenService = inject(CsrfTokenService);
    private readonly backendClient = new HttpClient(inject(HttpBackend));
    private csrfInitialization$?: Observable<void>;

    private static readonly csrfRetry = new HttpContextToken<boolean>(() => false);

    intercept(req: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
        const csrfToken = this.csrfTokenService.get();
        const needsCsrf = this.needsCsrfHeader(req);

        if (needsCsrf && !csrfToken && !req.headers.has('X-XSRF-TOKEN')) {
            return this.initializeCsrf().pipe(
                switchMap(() => this.send(req, next))
            );
        }

        return this.send(req, next);
    }

    private send(req: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
        const request = this.withCredentials(req, this.csrfTokenService.get());
        return next.handle(request).pipe(
            catchError((error: unknown) => {
                const shouldRetry = error instanceof HttpErrorResponse
                    && error.status === 403
                    && this.needsCsrfHeader(req)
                    && !req.context.get(CredentialsInterceptor.csrfRetry);

                if (!shouldRetry) {
                    return throwError(() => error);
                }

                this.csrfTokenService.clear();
                const retryRequest = req.clone({
                    context: req.context.set(CredentialsInterceptor.csrfRetry, true)
                });
                return this.initializeCsrf().pipe(
                    switchMap(() => next.handle(this.withCredentials(retryRequest, this.csrfTokenService.get())))
                );
            })
        );
    }

    private withCredentials(req: HttpRequest<unknown>, csrfToken?: string): HttpRequest<unknown> {
        return req.clone({
            withCredentials: true,
            setHeaders: csrfToken && this.needsCsrfHeader(req) && !req.headers.has('X-XSRF-TOKEN')
                ? { 'X-XSRF-TOKEN': csrfToken }
                : {},
        });
    }

    private initializeCsrf(): Observable<void> {
        if (!this.csrfInitialization$) {
            this.csrfInitialization$ = this.backendClient.get<void>('/api/auth/csrf', { observe: 'response' }).pipe(
                map(response => {
                    this.csrfTokenService.set(response.headers.get('X-XSRF-TOKEN'));
                }),
                catchError(error => throwError(() => error)),
                finalize(() => this.csrfInitialization$ = undefined),
                shareReplay(1)
            );
        }
        return this.csrfInitialization$;
    }

    private needsCsrfHeader(req: HttpRequest<unknown>): boolean {
        // Only protect unsafe methods.
        if (['GET', 'HEAD', 'OPTIONS'].includes(req.method.toUpperCase())) {
            return false;
        }
        // Limit to API calls; avoids touching external URLs.
        return req.url.includes('/api/');
    }
}