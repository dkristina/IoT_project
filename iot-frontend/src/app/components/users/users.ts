import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Store } from '@ngrx/store';
import { AuthService } from '../../core/services/auth';

import { User } from '../../core/models/user.model';
import { map } from 'rxjs';
import { selectAllUsers, selectUsersLoading } from '../../store/user/user.selectors';
import { UserActions } from '../../store/user/user.actions';
import { UserModalComponent } from '../user-modal/user-modal';

@Component({
  selector: 'app-users',
  standalone: true,
  imports: [CommonModule, FormsModule, UserModalComponent],
  templateUrl: './users.html',
  styleUrl: './users.scss'
})
export class UsersComponent implements OnInit {
  private store = inject(Store);
  private authService = inject(AuthService);

  // Selektori su Observables - koristimo async pipe u HTML-u
  users$ = this.store.select(selectAllUsers);
  loading$ = this.store.select(selectUsersLoading);
  
  searchTerm: string = '';
  isAdmin: boolean = false;
  isModalOpen: boolean = false;

  ngOnInit() {
    const currentUser = this.authService.getCurrentUserValue(); //
    this.isAdmin = currentUser?.role === 'ADMIN';
    
    // Inicijalno učitavanje
    this.store.dispatch(UserActions.loadUsers());
  }

  onSearch() {
    // Okidamo pretragu kroz akciju
    this.store.dispatch(UserActions.searchUsers({ name: this.searchTerm }));
  }

  handleUpdatePassword(user: User) {
    const newPass = prompt(`Nova lozinka za ${user.username}:`);
    if (newPass && newPass.length >= 4) {
      this.store.dispatch(UserActions.updatePassword({ id: user.id, password: newPass }));
    }
  }

  handleDelete(id: number) {
    if (confirm('Obrisati korisnika?')) {
      this.store.dispatch(UserActions.deleteUser({ id }));
    }
  }

  onUserSave(userData: any) {
    this.store.dispatch(UserActions.createUser({ user: userData }));
    this.isModalOpen = false;
  }
}