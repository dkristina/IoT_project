import { Component, OnInit, inject, Inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { AbstractControl, FormBuilder, FormGroup, FormsModule, ReactiveFormsModule, ValidationErrors, Validators } from '@angular/forms';
import { Store } from '@ngrx/store';
import { AuthService } from '../../core/services/auth';

import { User } from '../../core/models/user.model';
import { BehaviorSubject, Observable, map, switchMap } from 'rxjs';
import { selectAllUsers, selectUsersLoading } from '../../store/user/user.selectors';
import { UserActions } from '../../store/user/user.actions';
import { UserModalComponent } from '../user-modal/user-modal';
import { MatDialog, MatDialogModule, MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { selectUsersLeaderboard } from '../../store/incident/incident.selector';
import { UserAnalyticsDialogComponent } from '../user-analytics-dialog/user-analytics-dialog';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatIconModule } from '@angular/material/icon'; // 🚀 DODAT UNOS ZA MAT IKONE

@Component({
  selector: 'app-users',
  standalone: true,
  imports: [
    CommonModule, 
    FormsModule, 
    UserModalComponent, 
    MatDialogModule, 
    MatSnackBarModule, 
    MatIconModule // 🚀 DODATO OVDE
  ],
  templateUrl: './users.html',
  styleUrl: './users.scss'
})
export class UsersComponent implements OnInit {
  private store = inject(Store);
  private authService = inject(AuthService);
  private dialog = inject(MatDialog);
  private snackBar = inject(MatSnackBar);

  users$ = this.store.select(selectAllUsers);
  loading$ = this.store.select(selectUsersLoading);
  
  private selectedPeriod$ = new BehaviorSubject<string>('24h');
  leaderboard$ = this.selectedPeriod$.pipe(
    switchMap(period => this.store.select(selectUsersLeaderboard(period)))
  );
  
  searchTerm: string = '';
  isAdmin: boolean = false;
  isModalOpen: boolean = false;

  ngOnInit() {
    const currentUser = this.authService.getCurrentUserValue(); 
    this.isAdmin = currentUser?.role === 'ADMIN';
    this.store.dispatch(UserActions.loadUsers());
  }

  onPeriodChange(event: Event) {
    const selectElement = event.target as HTMLSelectElement;
    this.selectedPeriod$.next(selectElement.value);
  }

  openAnalytics(user: User) {
    this.dialog.open(UserAnalyticsDialogComponent, {
      data: { user: user },
      width: '600px'
    });
  }

  onSearch() {
    this.store.dispatch(UserActions.searchUsers({ name: this.searchTerm }));
  }

  handleUpdatePassword(user: User) {
    const dialogRef = this.dialog.open(UpdatePasswordDialog, {
      data: { username: user.username },
      width: '400px',
      panelClass: 'dark-dialog-panel'
    });

    dialogRef.afterClosed().subscribe((newPass: string) => {
      if (newPass && newPass.length >= 6) {
        this.store.dispatch(UserActions.updatePassword({ id: user.id, password: newPass }));
        this.snackBar.open(`✨ Lozinka za @${user.username} je uspešno izmenjena.`, 'Zatvori', { duration: 3000 });
      }
    });
  }

  handleDelete(id: number) {
    const dialogRef = this.dialog.open(DeleteUserConfirmationDialog, {
      width: '400px',
      panelClass: 'dark-dialog-panel',
      backdropClass: 'blur-backdrop'
    });

    dialogRef.afterClosed().subscribe(confirmed => {
      if (confirmed) {
        this.store.dispatch(UserActions.deleteUser({ id }));
        this.snackBar.open('🗑️ Korisnik je uspešno uklonjen sa sistema.', 'Zatvori', { duration: 3000 });
      }
    });
  }

  onUserSave(userData: any) {
    this.store.dispatch(UserActions.createUser({ user: userData }));
    this.isModalOpen = false;
  }
}

@Component({
  standalone: true,
  imports: [MatDialogModule, ReactiveFormsModule, CommonModule],
  template: `
    <div class="custom-dialog-container">
      <h2>🔑 Promena lozinke</h2>
      <p class="dialog-subtitle">Unesite novu lozinku za operatera <strong>&#64;{{data.username}}</strong></p>
      
      <form [formGroup]="passForm" (ngSubmit)="submit()" autocomplete="off">
        <input type="text" name="prevent_autofill_user" style="display:none;" aria-hidden="true" tabindex="-1" />
        <input type="password" name="prevent_autofill_pass" style="display:none;" aria-hidden="true" tabindex="-1" />

        <mat-dialog-content class="dialog-body">
          <div class="input-field-group">
            <label>Nova lozinka (min. 6 karaktera)</label>
            <input 
              formControlName="password" 
              type="password" 
              placeholder="••••••••" 
              class="dialog-input" 
              autocomplete="one-time-code"
              [class.input-error]="passForm.get('password')?.invalid && passForm.get('password')?.touched"
              autofocus
            >
          </div>

          <div class="input-field-group" style="margin-top: 12px;">
            <label>Potvrdite novu lozinku</label>
            <input 
              formControlName="confirmPassword" 
              type="password" 
              placeholder="••••••••" 
              class="dialog-input"
              autocomplete="one-time-code"
              [class.input-error]="passForm.get('confirmPassword')?.invalid && passForm.get('confirmPassword')?.touched"
            >
          </div>

          <div *ngIf="passForm.get('confirmPassword')?.errors?.['passwordMismatch'] && passForm.get('confirmPassword')?.touched" class="dialog-error-message">
            Lozinke se ne poklapaju.
          </div>
        </mat-dialog-content>
        
        <mat-dialog-actions align="end" class="dialog-actions">
          <button type="button" (click)="dialogRef.close()" class="btn-dialog-secondary">Otkaži</button>
          <button type="submit" [disabled]="passForm.invalid" class="btn-dialog-primary">Sačuvaj</button>
        </mat-dialog-actions>
      </form>
    </div>
  `,
  styles: [`
    .custom-dialog-container { background-color: #1e293b; color: #f8fafc; padding: 20px; border-radius: 12px; border: 1px solid #334155; }
    h2 { margin: 0 0 4px 0; color: #ffffff; font-size: 1.2rem; font-weight: 600; }
    .dialog-subtitle { color: #94a3b8; font-size: 0.85rem; margin-bottom: 20px; }
    .dialog-subtitle strong { color: #38bdf8; }
    .input-field-group { display: flex; flex-direction: column; gap: 6px; }
    .input-field-group label { font-size: 0.8rem; color: #94a3b8; font-weight: 500; }
    .dialog-input { background: #0f172a; border: 1px solid #334155; border-radius: 6px; padding: 10px 12px; color: #fff; font-size: 0.9rem; outline: none; }
    .dialog-input:focus { border-color: #38bdf8; }
    .input-error { border-color: #ef4444 !important; }
    .dialog-error-message { color: #ef4444; font-size: 0.8rem; margin-top: 6px; font-weight: 500; }
    .dialog-body { padding: 0 0 20px 0 !important; }
    .dialog-actions { padding: 0; gap: 10px; }
    .btn-dialog-secondary { background: transparent; color: #94a3b8; border: 1px solid #334155; border-radius: 6px; padding: 8px 14px; cursor: pointer; font-size: 0.85rem; }
    .btn-dialog-secondary:hover { background: #334155; color: #fff; }
    .btn-dialog-primary { background: #38bdf8; color: #0f172a; border: none; border-radius: 6px; padding: 8px 14px; font-weight: 600; cursor: pointer; font-size: 0.85rem; }
    .btn-dialog-primary:hover:not(:disabled) { background: #0ea5e9; }
    .btn-dialog-primary:disabled { background: #475569; color: #94a3b8; cursor: not-allowed; }
  `]
})
class UpdatePasswordDialog {
  passForm: FormGroup;
  private fb = inject(FormBuilder);

  constructor(
    public dialogRef: MatDialogRef<UpdatePasswordDialog>,
    @Inject(MAT_DIALOG_DATA) public data: { username: string }
  ) {
    this.passForm = this.fb.group({
      password: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', Validators.required]
    }, {
      validators: this.passwordMatchValidator
    });
  }

  passwordMatchValidator(control: AbstractControl): ValidationErrors | null {
    const password = control.get('password');
    const confirmPassword = control.get('confirmPassword');

    if (password && confirmPassword && password.value !== confirmPassword.value) {
      confirmPassword.setErrors({ passwordMismatch: true });
      return { passwordMismatch: true };
    }
    return null;
  }

  submit() {
    if (this.passForm.valid) {
      // Vraćamo samo vrednost polja 'password' u UsersComponent
      this.dialogRef.close(this.passForm.value.password);
    }
  }
}

@Component({
  standalone: true,
  imports: [MatDialogModule],
  template: `
    <div class="custom-dialog-container danger-border">
      <h2>🗑️ Brisanje korisnika</h2>
      <mat-dialog-content class="dialog-body">
        Da li ste sigurni da želite trajno da obrišete ovog korisnika iz baze? Ova akcija je <strong>nepovratna</strong> i operater će odmah izgubiti pristup sistemu.
      </mat-dialog-content>
      <mat-dialog-actions align="end" class="dialog-actions">
        <button [mat-dialog-close]="false" class="btn-dialog-secondary">Otkaži</button>
        <button [mat-dialog-close]="true" class="btn-dialog-danger">Obriši trajno</button>
      </mat-dialog-actions>
    </div>
  `,
  styles: [`
    .custom-dialog-container { background-color: #1e293b; color: #f8fafc; padding: 24px; border-radius: 12px; border: 1px solid #334155; max-width: 380px; }
    .danger-border { border-top: 4px solid #ef4444; }
    h2 { margin: 0 0 12px 0; color: #ef4444; font-size: 1.2rem; font-weight: 600; }
    .dialog-body { color: #cbd5e1; font-size: 0.9rem; line-height: 1.5; padding: 0 0 20px 0 !important; }
    .dialog-body strong { color: #ef4444; }
    .dialog-actions { padding: 0; gap: 10px; }
    .btn-dialog-secondary { background: transparent; color: #94a3b8; border: 1px solid #334155; border-radius: 6px; padding: 10px 16px; cursor: pointer; }
    .btn-dialog-secondary:hover { background: #334155; color: #fff; }
    .btn-dialog-danger { background: #ef4444; color: #ffffff; border: none; border-radius: 6px; padding: 10px 16px; font-weight: 600; cursor: pointer; }
    .btn-dialog-danger:hover { background: #dc2626; }
  `]
})
class DeleteUserConfirmationDialog {}