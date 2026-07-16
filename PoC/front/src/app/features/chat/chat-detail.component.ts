import { AsyncPipe, DatePipe } from '@angular/common';
import { Component, computed, DestroyRef, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { Location } from '@angular/common';
import { catchError, filter, finalize, map, merge, Observable, of, shareReplay, Subject, switchMap, take, throwError } from 'rxjs';
import { takeUntilDestroyed, toSignal } from '@angular/core/rxjs-interop';
import { CHAT_DATASOURCE } from '../../core/services/chat-datasource.interface';
import { USER_DATASOURCE } from '../../core/services/user-datasource.interface';
import { ChatMessage } from '../../core/models/chat.model';
import { HeaderComponent } from '../../shared/header/header.component';
import { CommonComponent } from '../../shared/common-component';

@Component({
    selector: 'app-chat-detail',
    standalone: true,
    imports: [AsyncPipe, DatePipe, FormsModule, HeaderComponent],
    templateUrl: './chat-detail.component.html',
    styleUrls: ['./chat-detail.component.scss']
})
export class ChatDetailComponent extends CommonComponent {
    private readonly chatDataSource = inject(CHAT_DATASOURCE);
    private readonly userDataSource = inject(USER_DATASOURCE);
    private readonly route = inject(ActivatedRoute);
    private readonly router = inject(Router);
    private readonly location = inject(Location);
    private readonly destroyRef = inject(DestroyRef);
    private readonly refreshMessages$ = new Subject<void>();
    private readonly refreshParticipants$ = new Subject<void>();
    private readonly userNameCache = new Map<number, Observable<string>>();
    private readonly loaded = signal(false);

    readonly chatId = Number(this.route.snapshot.paramMap.get('id'));
    readonly currentUserId = this.authDataSource.getCurrentUser().id;
    readonly isAgent = this.authDataSource.getCurrentUser().role === 'agent';
    readonly messageContent = signal('');
    readonly selectedParticipantId = signal<number | null>(null);
    private readonly chatEvents$ = this.chatDataSource.chatEvents(this.chatId).pipe(shareReplay(1));

    private readonly chatClosedSubscription = this.chatEvents$.pipe(
        filter(event => event.type === 'chat-closed'),
        takeUntilDestroyed(this.destroyRef)
    ).subscribe(() => {
        if (this.isAgent) {
            this.router.navigate(['/chats']);
        }
    });

    readonly chat = toSignal(merge(
        of(void 0),
        this.chatEvents$.pipe(map(() => void 0))
    ).pipe(
        switchMap(() => this.chatDataSource.getById(this.chatId).pipe(
            catchError(() => {
                this.router.navigate(['/chats']);
                return of(null);
            }),
            finalize(() => this.loaded.set(true))
        ))
    ), { initialValue: null });

    readonly messages = toSignal(merge(
        of(void 0),
        this.refreshMessages$,
        this.chatEvents$.pipe(
            filter(event => event.type === 'message-created'),
            map(() => void 0)
        ),
    ).pipe(
        switchMap(() => this.chatDataSource.getMessages(this.chatId)),
        takeUntilDestroyed()
    ), { initialValue: [] });

    readonly participants = toSignal(merge(
        of(void 0),
        this.refreshParticipants$,
        this.chatEvents$.pipe(map(() => void 0))
    ).pipe(
        switchMap(() => this.chatDataSource.getParticipants(this.chatId)),
        takeUntilDestroyed()
    ), { initialValue: [] });

    readonly users = toSignal(this.userDataSource.getAll(), { initialValue: [] });
    readonly availableUsers = computed(() => {
        const participantIds = new Set(this.participants().map(participant => participant.userId));
        return this.users().filter(user => user.id !== this.currentUserId
            && user.role === 'client'
            && !participantIds.has(user.id));
    });

    protected override computeIsPageLoading(): boolean {
        return !this.loaded();
    }

    userName(userId: number): Observable<string> {
        if (!this.userNameCache.has(userId)) {
            this.userNameCache.set(userId, this.userDataSource.getById(userId).pipe(
                map(user => user.username),
                catchError(() => of('Utilisateur')),
                shareReplay(1)
            ));
        }
        return this.userNameCache.get(userId)!;
    }

    isMine(message: ChatMessage): boolean {
        return message.senderId === this.currentUserId;
    }

    sendMessage(): void {
        if (this.chat()?.status === 'closed') return;
        const content = this.messageContent().trim();
        if (!content) return;

        this.startSubmit();
        this.chatDataSource.sendMessage(this.chatId, { content, contentType: 'text' }).pipe(
            catchError(error => {
                this.error.set(true);
                this.message.set('Erreur lors de l envoi du message.');
                return throwError(() => error);
            }),
            finalize(() => this.isLoading.set(false)),
            take(1)
        ).subscribe({
            next: () => {
                this.messageContent.set('');
                this.message.set(null);
                this.refreshMessages$.next();
            }
        });
    }

    closeChat(): void {
        if (!this.chat() || this.chat()?.status === 'closed' || !window.confirm('Clôturer cette conversation ?')) {
            return;
        }

        this.startSubmit();
        this.chatDataSource.close(this.chatId).pipe(
            catchError(error => {
                this.error.set(true);
                this.message.set('Impossible de clôturer la conversation.');
                return throwError(() => error);
            }),
            finalize(() => this.isLoading.set(false)),
            take(1)
        ).subscribe({
            next: () => {
                this.message.set(null);
                this.location.back();
            }
        });
    }

    releaseChat(): void {
        const currentChat = this.chat();
        if (!this.isAgent || !currentChat
            || currentChat.status !== 'assigned'
            || currentChat.assignedAgentId !== this.currentUserId) {
            return;
        }

        this.startSubmit();
        this.chatDataSource.release(this.chatId).pipe(
            catchError(error => {
                this.error.set(true);
                this.message.set('Erreur lors de la liberation de la conversation.');
                return throwError(() => error);
            }),
            finalize(() => this.isLoading.set(false)),
            take(1)
        ).subscribe(() => this.router.navigate(['/chats']));
    }

    addParticipant(): void {
        const userId = this.selectedParticipantId();
        if (!userId) return;

        this.startSubmit();
        this.chatDataSource.addParticipant(this.chatId, { userId, role: 'client' }).pipe(
            catchError(error => {
                this.error.set(true);
                this.message.set('Impossible d ajouter ce participant.');
                return throwError(() => error);
            }),
            finalize(() => this.isLoading.set(false)),
            take(1)
        ).subscribe({
            next: () => {
                this.selectedParticipantId.set(null);
                this.message.set('Participant ajouté.');
                this.refreshParticipants$.next();
            }
        });
    }

    back(): void {
        this.router.navigate(['/chats']);
    }
}
