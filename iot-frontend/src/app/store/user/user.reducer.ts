import { createEntityAdapter, EntityAdapter, EntityState } from '@ngrx/entity';
import { createReducer, on } from '@ngrx/store';
import { User } from '../../core/models/user.model';
import { UserActions } from './user.actions';

export interface UserState extends EntityState<User> {
  loading: boolean;
  error: any;
}

export const adapter: EntityAdapter<User> = createEntityAdapter<User>();

export const initialState: UserState = adapter.getInitialState({
  loading: false,
  error: null
});

export const userReducer = createReducer(
  initialState,
  on(UserActions.loadUsers, (state) => ({ ...state, loading: true })),
  on(UserActions.loadUsersSuccess, (state, { users }) => 
    adapter.setAll(users, { ...state, loading: false })),
  on(UserActions.deleteUserSuccess, (state, { id }) => 
    adapter.removeOne(id, state)), // Entity magija - automatski sklanja iz liste
  on(UserActions.updatePasswordSuccess, (state, { user }) => 
    adapter.updateOne({ id: user.id, changes: user }, state)),
  on(UserActions.loadUsersFailure, (state, { error }) => ({ ...state, error, loading: false })),
  
  on(UserActions.createUserSuccess, (state, { user }) => 
    adapter.addOne(user, { ...state, loading: false })),
);