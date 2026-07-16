import { DatePipe } from '@angular/common';
import { Component, computed, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import { toSignal } from '@angular/core/rxjs-interop';
import { filter, forkJoin, of, shareReplay, tap } from 'rxjs';
import { AgentChatFilter, Chat } from '../../core/models/chat.model';
import { CHAT_DATASOURCE } from '../../core/services/chat-datasource.interface';
import { HeaderComponent } from '../../shared/header/header.component';
import { CommonComponent } from '../../shared/common-component';

@Component({
    selector: 'app-chat-list',
    standalone: true,
    imports: [DatePipe, HeaderComponent],
    templateUrl: './chat-list.component.html',
    styleUrls: ['./chat-list.component.scss']
})
export class ChatListComponent extends CommonComponent {
    private readonly chatDataSource = inject(CHAT_DATASOURCE);
    private readonly router = inject(Router);
    private readonly loaded = signal(false);

    constructor() {
        super();
        if (this.isAgent) {
            this.refreshAgentData();
            this.chatDataSource.agentEvents().pipe(
                filter(event => event.type.startsWith('chat-'))
            ).subscribe(() => this.refreshAgentData());
        }
    }

    private readonly chats$ = this.chatDataSource.getAll().pipe(
        tap({
            next: () => this.loaded.set(true),
            error: () => this.loaded.set(true)
        }),
        shareReplay(1)
    );

    readonly chats = toSignal(this.chats$, {
        initialValue: [],
        requireSync: false
    });

    readonly isAgent = this.authDataSource.getCurrentUser().role === 'agent';
    readonly agentFilter = signal<AgentChatFilter>('all');
    readonly agentChats = signal<Chat[]>([]);
    readonly allAgentChats = signal<Chat[]>([]);
    readonly mineAgentChats = signal<Chat[]>([]);

    readonly visibleAgentChats = computed(() => {
        const filter = this.agentFilter();
        return this.agentChats();
    });

    readonly agentCounts = computed(() => ({
        all: this.allAgentChats().length,
        closed: this.allAgentChats().filter(chat => chat.status === 'closed' || chat.status === 'archived').length,
        mine: this.mineAgentChats().length,
        waiting: this.allAgentChats().filter(chat => chat.status === 'open' || chat.status === 'waiting_reassignment').length,
        assigned: this.allAgentChats().filter(chat => chat.status === 'assigned').length
    }));

    readonly chatsSorted = computed(() => [...this.chats()].sort(
        (left, right) => new Date(right.updatedAt).getTime() - new Date(left.updatedAt).getTime()
    ));

    protected override computeIsPageLoading(): boolean {
        return !this.loaded();
    }

    createChat(): void {
        this.router.navigate(['/chats/create']);
    }

    openChat(chatId: number): void {
        this.router.navigate(['/chats', chatId]);
    }

    claimChat(chatId: number): void {
        this.chatDataSource.claim(chatId).subscribe(() => this.openChat(chatId));
    }

    setAgentFilter(filter: AgentChatFilter): void {
        this.agentFilter.set(filter);
        this.chatDataSource.getAgentView(filter).subscribe(chats => this.agentChats.set(chats));
    }

    releaseChat(chatId: number): void {
        this.chatDataSource.release(chatId).subscribe(() => this.setAgentFilter(this.agentFilter()));
    }

    agentCount(filter: AgentChatFilter): number {
        return this.agentCounts()[filter];
    }

    statusLabel(status: string): string {
        return status === 'waiting_reassignment' ? 'Sans agent'
            : status === 'assigned' ? 'Attribué'
                : status === 'closed' || status === 'archived' ? 'Clôturée'
                    : 'En attente';
    }

    activateAgentChat(chat: Chat, event: Event): void {
        if ((event.target as HTMLElement).closest('button')) return;
        if (chat.status === 'open' || chat.status === 'waiting_reassignment') {
            this.claimChat(chat.id);
        } else {
            this.openChat(chat.id);
        }
    }

    private refreshAgentData(): void {
        forkJoin({
            all: this.chatDataSource.getAgentView('all'),
            mine: this.chatDataSource.getAgentView('mine'),
            visible: this.chatDataSource.getAgentView(this.agentFilter())
        }).subscribe(({ all, mine, visible }) => {
            this.allAgentChats.set(all);
            this.mineAgentChats.set(mine);
            this.agentChats.set(visible);
        });
    }
}
