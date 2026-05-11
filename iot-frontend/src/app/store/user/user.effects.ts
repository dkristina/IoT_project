import { Injectable, inject } from '@angular/core';
import { Actions, createEffect, ofType } from '@ngrx/effects';
import { UsersService } from '../../core/services/user.service';
import { UserActions } from './user.actions';
import { switchMap, map, catchError, mergeMap, of } from 'rxjs';
import { AuthService } from '../../core/services/auth';

@Injectable()
export class UserEffects {
  private actions$ = inject(Actions);
  private usersService = inject(UsersService);
  private authService = inject(AuthService);
  // switchMap: Odličan za load/search jer otkazuje prethodni zahtev ako stigne novi
  loadUsers$ = createEffect(() => this.actions$.pipe(
    ofType(UserActions.loadUsers),
    switchMap(() => {
      // 2. Provera uloge: Admin dobija sve, Operator samo kolege
      const request$ = this.authService.isAdmin() 
        ? this.usersService.findAll() 
        : this.usersService.findOperators();

      return request$.pipe(
        map(users => UserActions.loadUsersSuccess({ users })),
        catchError(error => of(UserActions.loadUsersFailure({ error })))
      );
    })
  ));

  searchUsers$ = createEffect(() => this.actions$.pipe(
    ofType(UserActions.searchUsers),
    switchMap(({ name }) => {
      const obs$ = name.trim() 
        ? this.usersService.searchByName(name) 
        : this.usersService.findAll();
      return obs$.pipe(
        map(users => UserActions.loadUsersSuccess({ users })),
        catchError(error => of(UserActions.loadUsersFailure({ error })))
      );
    })
  ));

  // mergeMap: Koristimo ga za brisanje (asinhrono)
  deleteUser$ = createEffect(() => this.actions$.pipe(
    ofType(UserActions.deleteUser),
    mergeMap(({ id }) => this.usersService.remove(id).pipe(
      map(() => UserActions.deleteUserSuccess({ id })),
      catchError(error => of(UserActions.deleteUserFailure({ error })))
    ))
  ));

  updatePassword$ = createEffect(() => this.actions$.pipe(
    ofType(UserActions.updatePassword),
    mergeMap(({ id, password }) => this.usersService.update(id, { password } as any).pipe(
      map(user => UserActions.updatePasswordSuccess({ user })),
      catchError(error => of(UserActions.updatePasswordFailure({ error })))
    ))
  ));

  createUser$ = createEffect(() => this.actions$.pipe(
    ofType(UserActions.createUser),
    mergeMap(({ user }) => this.usersService.create(user).pipe(
        map(newUser => UserActions.createUserSuccess({ user: newUser })),
        catchError(error => {
        alert(error.error?.message || 'Greška pri kreiranju korisnika');
        return of(UserActions.createUserFailure({ error }));
        })
    ))
    ));
}