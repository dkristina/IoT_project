import { CommonModule } from '@angular/common';
import { Component, inject } from '@angular/core';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../core/services/auth';
import { MatIconModule } from '@angular/material/icon';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';


@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [CommonModule, RouterModule, MatIconModule],
  templateUrl: './navbar.html',
  styleUrl: './navbar.scss',
})
export class NavbarComponent {
  public authService = inject(AuthService);
  private dialog = inject(MatDialog);

  onLogout() {
  
    const dialogRef = this.dialog.open(LogoutConfirmationDialog);

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.authService.logout();
      }
    });
  }
}

@Component({
  standalone: true,
  imports: [MatDialogModule],
  template: `
    <div class="custom-dialog-container">
      <div class="dialog-header">
        <h2 mat-dialog-title>Potvrda odjave</h2>
      </div>
      
      <mat-dialog-content class="dialog-body">
        Da li ste sigurni da želite da se odjavite sa IoT sistema?
      </mat-dialog-content>
      
      <mat-dialog-actions align="end" class="dialog-actions">
        <button [mat-dialog-close]="false" class="btn-secondary">Otkaži</button>
        <button [mat-dialog-close]="true" class="btn-danger">Odjavi se</button>
      </mat-dialog-actions>
    </div>
  `,
  styles: [`
    .custom-dialog-container {
      background-color: #1e293b; /* Тамно плава нијанса из твоје апликације */
      color: #f8fafc;
      padding: 24px;
      border-radius: 12px;
      border: 1px solid #334155;
      font-family: inherit;
      max-width: 400px;
    }
    h2[mat-dialog-title] {
      margin: 0 0 12px 0;
      color: #ffffff;
      font-size: 1.25rem;
      font-weight: 600;
      letter-spacing: -0.025em;
    }
    .dialog-body {
      color: #94a3b8;
      font-size: 0.95rem;
      line-height: 1.5;
      padding: 0 0 24px 0 !important;
    }
    .dialog-actions {
      padding: 0;
      gap: 12px;
    }
    .btn-secondary {
      background: transparent;
      color: #94a3b8;
      border: 1px solid #334155;
      border-radius: 6px;
      padding: 10px 18px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;
    }
    .btn-secondary:hover {
      background: #334155;
      color: #fff;
    }
    .btn-danger {
      background: #ef4444; /* Иста она лепа црвена */
      color: #ffffff;
      border: none;
      border-radius: 6px;
      padding: 10px 18px;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.2s;
    }
    .btn-danger:hover {
      background: #dc2626;
    }
  `]
})
export class LogoutConfirmationDialog {}
