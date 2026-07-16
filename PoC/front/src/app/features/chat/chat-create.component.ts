import { Component, inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, finalize, throwError } from 'rxjs';
import { CHAT_DATASOURCE } from '../../core/services/chat-datasource.interface';
import { DynamicFormComponent, DynamicFormValues, FormElement } from '../../shared/form/dynamic-form.component';
import { HeaderComponent } from '../../shared/header/header.component';
import { CommonComponent } from '../../shared/common-component';

@Component({
    selector: 'app-chat-create',
    standalone: true,
    imports: [DynamicFormComponent, HeaderComponent],
    templateUrl: './chat-create.component.html',
    styleUrls: ['./chat-create.component.scss']
})
export class ChatCreateComponent extends CommonComponent {
    private readonly chatDataSource = inject(CHAT_DATASOURCE);
    private readonly router = inject(Router);

    readonly chatFormElements: FormElement[] = [
        { type: 'text', name: 'subject', label: 'Sujet', placeholder: 'Objet de la demande', required: true, maxLength: 255 }
    ];

    onFormSubmit(values: DynamicFormValues): void {
        const subject = values['subject'];
        if (typeof subject !== 'string' || !subject.trim()) {
            this.error.set(true);
            this.message.set('Veuillez renseigner le sujet.');
            return;
        }

        this.startSubmit();
        this.message.set('Création en cours...');
        this.chatDataSource.create({ subject: subject.trim() }).pipe(
            catchError(error => {
                this.error.set(true);
                this.message.set('Erreur lors de la création du chat.');
                return throwError(() => error);
            }),
            finalize(() => this.isLoading.set(false))
        ).subscribe({
            next: chat => this.router.navigate(['/chats', chat.id])
        });
    }

    back(): void {
        this.router.navigate(['/chats']);
    }
}
