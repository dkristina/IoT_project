import { createFeatureSelector, createSelector } from '@ngrx/store';
import { UserState, adapter } from './user.reducer';

export const selectUserState = createFeatureSelector<UserState>('users');

const { selectAll } = adapter.getSelectors();

export const selectAllUsers = createSelector(selectUserState, selectAll);
export const selectUsersLoading = createSelector(selectUserState, (state) => state.loading);