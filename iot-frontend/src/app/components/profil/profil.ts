import { Component, ElementRef, inject, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Store } from '@ngrx/store';
import { map, switchMap, filter } from 'rxjs/operators';
import { AuthService } from '../../core/services/auth';
import { Observable } from 'rxjs';

import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { selectAllIncidents, selectIncidentsLoading, selectMyIncidents } from '../../store/incident/incident.selector';
import { IncidentStatus } from '../../core/models/incident.model';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatTooltipModule } from '@angular/material/tooltip';
import { IncidentActions } from '../../store/incident/incident.actions';

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
    MatTooltipModule    
  ],
  templateUrl: './profil.html',
  styleUrl: './profil.scss'
})
export class ProfileComponent {
  private store = inject(Store);
  public authService = inject(AuthService);

  // Dodajemo ove ViewChild-ove da bi TS "video" inpute
  @ViewChild('usernameInput') usernameInput!: ElementRef;
  @ViewChild('fullNameInput') fullNameInput!: ElementRef;
  @ViewChild('emailInput') emailInput!: ElementRef;

  user$ = this.authService.currentUser$;
  isEditing = false;
  selectedAvatar: string | null = null;


  // 1. Uhvati sve incidente (provera po imenu u opisu i dodeljenom korisniku)
  myIncidents$ = this.user$.pipe(
  filter(user => !!user),
  switchMap(user => this.store.select(selectAllIncidents).pipe(
    map(incidents => incidents.filter(inc => {
      const myUsername = user!.username.toLowerCase(); 
      
      // Proveravamo da li je korisnik dodeljen preko objekta ili prostog stringa
      const isAssigned = inc.assignedTo?.username?.toLowerCase() === myUsername || 
                         inc.assignedTo?.id === user!.id ||
                         (typeof inc.assignedTo === 'string' && inc.assignedTo === myUsername);
      
      // DODATNA PROVERA: Da li se username nalazi u opisu 
      const inDescription = inc.description?.toLowerCase().includes(myUsername);

      return isAssigned || inDescription;
    }))
  ))
);

  // 2. Aktivni: Sve što NIJE 'resolved' (bez obzira na velika/mala slova)
  activeTasks$ = this.myIncidents$.pipe(
    map(incidents => incidents.filter(i => 
      i.status?.toLowerCase() !== 'resolved'
    ))
  );

  // 3. Rešeni: Sve što JESTE 'resolved'
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

  // Funkcija sada sama uzima vrednosti iz inputa
  onUpdateProfile() {
  const currentUser = this.authService.getCurrentUserValue();
  if (!currentUser) return;

  const updateData = {
    username: this.usernameInput?.nativeElement.value || currentUser.username,
    fullName: this.fullNameInput?.nativeElement.value || currentUser.fullName,
    email: this.emailInput?.nativeElement.value || currentUser.email,
    avatarUrl: this.selectedAvatar || currentUser.avatarUrl
  };

  this.authService.updateProfile(currentUser.id, updateData).subscribe({
    next: () => {
      this.isEditing = false;
      this.selectedAvatar = null;
      alert('Profil uspešno sačuvan!');
    },
    error: (err) => console.error('Greška:', err)
  });
}

  // KLJUČNA METODA ZA ZATVARANJE
  resolve(incidentId: number) {
    this.store.dispatch(IncidentActions.updateIncident({
      id: incidentId,
      changes: { status: IncidentStatus.RESOLVED }
    }));
  }

  onLogout() { this.authService.logout(); }
}