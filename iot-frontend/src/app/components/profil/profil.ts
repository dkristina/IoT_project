import { Component, ElementRef, inject, ViewChild, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Store } from '@ngrx/store';
import { map, switchMap, filter, take } from 'rxjs/operators';
import { AuthService } from '../../core/services/auth';
import { Observable } from 'rxjs';

import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { selectAllIncidents } from '../../store/incident/incident.selector';
import { IncidentStatus } from '../../core/models/incident.model';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatTooltipModule } from '@angular/material/tooltip';
import { IncidentActions } from '../../store/incident/incident.actions';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';

@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [
    CommonModule, 
    MatCardModule, 
    MatIconModule, 
    MatButtonModule, 
    MatProgressSpinnerModule,
    MatFormFieldModule, 
    MatInputModule,     
    MatTooltipModule,
    MatSnackBarModule
  ],
  templateUrl: './profil.html',
  styleUrl: './profil.scss'
})
export class ProfileComponent implements OnInit {
  private store = inject(Store);
  public authService = inject(AuthService);
  private dialog = inject(MatDialog);
  private snackBar = inject(MatSnackBar);

  @ViewChild('usernameInput') usernameInput!: ElementRef;
  @ViewChild('fullNameInput') fullNameInput!: ElementRef;
  @ViewChild('emailInput') emailInput!: ElementRef;
  @ViewChild('passwordInput') passwordInput!: ElementRef;
  @ViewChild('confirmPasswordInput') confirmPasswordInput!: ElementRef;

  user$ = this.authService.currentUser$;
  isEditing = false;
  selectedAvatar: string | null = null;

  ngOnInit() {
    this.store.dispatch(IncidentActions.loadIncidents());
  }
  
  // 1. Uhvati sve incidente (provera po imenu u opisu i dodeljenom korisniku)
  myIncidents$ = this.user$.pipe(
    filter(user => !!user),
    switchMap(user => this.store.select(selectAllIncidents).pipe(
      map(incidents => incidents.filter(inc => {
        if (!inc.assignedTo) return false;
        const myUsername = user!.username.toLowerCase(); 
        
        const isAssigned = inc.assignedTo?.username?.toLowerCase() === myUsername || 
                           inc.assignedTo?.id === user!.id ||
                           (typeof inc.assignedTo === 'string' && inc.assignedTo === myUsername);
        
        const isInProgress = inc.status?.toLowerCase() === 'in_progress';
        return isAssigned || isInProgress;
      }))
    ))
  );

  // 2. Aktivni: Sve sto NIJE 'resolved'
  activeTasks$ = this.myIncidents$.pipe(
    map(incidents => incidents.filter(i => 
      i.status?.toLowerCase() !== 'resolved'
    ))
  );

  // 3. Reseni: Sve sto JESTE 'resolved'
  resolvedTasks$ = this.myIncidents$.pipe(
    map(incidents => incidents.filter(i => 
      i.status?.toLowerCase() === 'resolved'
    ))
  );

  toggleEdit() {
    this.isEditing = !this.isEditing;
    if (!this.isEditing) this.selectedAvatar = null;
  }

  onFileSelected(event: any) {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e: any) => this.selectedAvatar = e.target.result;
      reader.readAsDataURL(file);
    }
  }

  onUpdateProfile() {
    const currentUser = this.authService.getCurrentUserValue();
    if (!currentUser) return;

    const newPassword = this.passwordInput?.nativeElement.value;
    const confirmPassword = this.confirmPasswordInput?.nativeElement.value;
    if (newPassword || confirmPassword) {
      if (newPassword !== confirmPassword) {
        this.snackBar.open('❌ Lozinke se ne poklapaju!', 'Zatvori', { duration: 4000 });
        return; 
      }
      if (newPassword.length < 6) {
        this.snackBar.open('❌ Lozinka mora imati najmanje 6 karaktera!', 'Zatvori', { duration: 4000 });
        return;
      }
    }

    const updateData: any= {
      username: this.usernameInput?.nativeElement.value || currentUser.username,
      fullName: this.fullNameInput?.nativeElement.value || currentUser.fullName,
      email: this.emailInput?.nativeElement.value || currentUser.email,
      avatarUrl: this.selectedAvatar || currentUser.avatarUrl
    };
    
    if (newPassword && newPassword.trim() !== '') {
      updateData.password = newPassword;
    }

    this.authService.updateProfile(currentUser.id, updateData).subscribe({
      next: () => {
        this.isEditing = false;
        this.selectedAvatar = null;
      
        this.snackBar.open('✨ Profil je uspešno sačuvan!', 'Zatvori', {
          duration: 3000,
          horizontalPosition: 'end', 
          verticalPosition: 'top',     
        });
      },
      error: (err) => {
        console.error('Greška:', err);
        this.snackBar.open('❌ Greška pri čuvanju profila.', 'Zatvori', { duration: 4000 });
      }
    });
  }

  //ZATVARANJE / RESAVANJE INCIDENTA 
  resolve(incidentId: number) {
    this.activeTasks$.pipe(
      take(1),
      map(tasks => tasks.find(t => t.id === incidentId)),
      filter(task => !!task)
    ).subscribe(() => {
      const username = this.authService.getCurrentUserValue()?.username || 'operater';
      const now = new Date();
      const trenutnoVreme = now.toTimeString().split(' ')[0].substring(0, 5);
      const noviLog = `🏁 @${username} rešio u ${trenutnoVreme}`;

      this.store.dispatch(IncidentActions.updateIncident({
        id: incidentId,
        changes: { 
          status: IncidentStatus.RESOLVED,
          historyLogs: noviLog
        }
      }));
    });
  }


  abandon(incidentId: number) {
  this.activeTasks$.pipe(
    take(1),
    map(tasks => tasks.find(t => t.id === incidentId)),
    filter(task => !!task)
  ).subscribe(() => {
    
    const dialogRef = this.dialog.open(AbandonConfirmationDialog);

    dialogRef.afterClosed().subscribe(confirmed => {
      if (confirmed) {
        const username = this.authService.getCurrentUserValue()?.username || 'operater';
        const now = new Date();
        const trenutnoVreme = now.toTimeString().split(' ')[0].substring(0, 5);
        const noviLog = `↩️ @${username} odustao u ${trenutnoVreme}`;

        this.store.dispatch(IncidentActions.updateIncident({
          id: incidentId,
          changes: { 
            status: IncidentStatus.NEW,          
            assignedToId: null, 
            historyLogs: noviLog
          }
        }));
      }
    });

  });
}
  
  onLogout() { this.authService.logout(); }

  //Pomocna funkcija za racunanje trajanja rada na resavanju incidenta
  getWorkTime(incident: any): string {
    if (!incident.pickedUpAt || !incident.resolvedAt) return '0 min';
    
    const start = new Date(incident.pickedUpAt).getTime();
    const end = new Date(incident.resolvedAt).getTime();
    
    const diffMs = end - start;
    const diffMin = Math.round(diffMs / (1000 * 60));
    
    if (diffMin < 60) {
      return `${diffMin} min`;
    } else {
      const hours = Math.floor(diffMin / 60);
      const mins = diffMin % 60;
      return mins > 0 ? `${hours}h ${mins}m` : `${hours}h`;
    }
  }
}



@Component({
  standalone: true,
  imports: [MatDialogModule],
  template: `
    <div class="custom-dialog-container warning-border">
      <div class="dialog-header">
        <h2 mat-dialog-title>⚠️ Odustajanje od zadatka</h2>
      </div>
      
      <mat-dialog-content class="dialog-body">
        Da li ste sigurni da želite da odustanete od ovog incidenta? 
      </mat-dialog-content>
      
      <mat-dialog-actions align="end" class="dialog-actions">
        <button [mat-dialog-close]="false" class="btn-secondary">Prekini</button>
        <button [mat-dialog-close]="true" class="btn-warning">Da, odustani</button>
      </mat-dialog-actions>
    </div>
  `,
  styles: [`
    .custom-dialog-container {
      background-color: #1e293b;
      color: #f8fafc;
      padding: 24px;
      border-radius: 12px;
      border: 1px solid #334155;
      font-family: inherit;
      max-width: 420px;
    }
    .warning-border {
      border-top: 4px solid #f59e0b; /* Суптилна наранџаста линија на врху за упозорење */
    }
    h2[mat-dialog-title] {
      margin: 0 0 12px 0;
      color: #f59e0b; /* Жут наслов */
      font-size: 1.25rem;
      font-weight: 600;
    }
    .dialog-body {
      color: #cbd5e1;
      font-size: 0.95rem;
      line-height: 1.5;
      padding: 0 0 24px 0 !important;
    }
    .dialog-body strong {
      color: #f59e0b;
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
    .btn-warning {
      background: #f59e0b;
      color: #0f172a; /* Тамна слова на жутој позадини ради бољег контраста */
      border: none;
      border-radius: 6px;
      padding: 10px 18px;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.2s;
    }
    .btn-warning:hover {
      background: #d97706;
    }
  `]
})
export class AbandonConfirmationDialog {}