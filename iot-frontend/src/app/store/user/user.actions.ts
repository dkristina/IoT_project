import { createActionGroup, emptyProps, props } from '@ngrx/store';
import { User } from '../../core/models/user.model';

export const UserActions = createActionGroup({
  source: 'User Management',
  events: {
    'Load Users': emptyProps(),
    'Load Users Success': props<{ users: User[] }>(),
    'Load Users Failure': props<{ error: any }>(),
    
    'Search Users': props<{ name: string }>(),
    
    'Delete User': props<{ id: number }>(),
    'Delete User Success': props<{ id: number }>(),
    'Delete User Failure': props<{ error: any }>(),
    
    'Update Password': props<{ id: number, password: any }>(),
    'Update Password Success': props<{ user: User }>(),
    'Update Password Failure': props<{ error: any }>(),

    
    'Create User': props<{ user: any }>(),
    'Create User Success': props<{ user: User }>(),
    'Create User Failure': props<{ error: any }>(),
  }
});