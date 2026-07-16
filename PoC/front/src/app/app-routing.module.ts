import { Routes } from '@angular/router';
import { AuthGuard } from './core/auth/auth.guard';

export const routes: Routes = [
  { path: '', loadComponent: () => import('./features/home/home.component').then(m => m.HomeComponent) },
  { path: 'user/register', loadComponent: () => import('./features/user/register/register.component').then(m => m.RegisterComponent) },
  { path: 'user/login', loadComponent: () => import('./features/user/login/login.component').then(m => m.LoginComponent) },
  {
    path: 'chats', loadComponent: () => import('./features/chat/chat-list.component').then(m => m.ChatListComponent),
    canActivate: [AuthGuard]
  },
  {
    path: 'chats/create', loadComponent: () => import('./features/chat/chat-create.component').then(m => m.ChatCreateComponent),
    canActivate: [AuthGuard]
  },
  {
    path: 'chats/:id', loadComponent: () => import('./features/chat/chat-detail.component').then(m => m.ChatDetailComponent),
    canActivate: [AuthGuard]
  },
  {
    path: '**', loadComponent: () => import('./shared/error/error.component').then(m => m.ErrorComponent),
    canActivate: [AuthGuard]
  }
];