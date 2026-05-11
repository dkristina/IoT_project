import { Component, OnInit, inject } from '@angular/core';
import { Store } from '@ngrx/store';
import { IncidentActions } from '../../store/incident/incident.actions';
import { CommonModule } from '@angular/common';
import { selectAllIncidents } from '../../store/incident/incident.selector';
import { AuthService } from '../../core/services/auth';

@Component({
  selector: 'app-incident-list',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './incident-list.html',
  styleUrls: ['./incident-list.scss']
})
export class IncidentListComponent implements OnInit {
  private store = inject(Store);
  public authService = inject(AuthService);
  
  incidents$ = this.store.select(selectAllIncidents);

  ngOnInit() {
    this.store.dispatch(IncidentActions.loadIncidents());
  }

  claimIncident(incidentId: number) {
    const user = JSON.parse(localStorage.getItem('user_data') || '{}');
    if (user && user.id) {
      this.store.dispatch(IncidentActions.takeIncident({ 
        id: incidentId, 
        userId: user.id 
      }));
    }
  }

  // Ova metoda je neophodna jer je pozivaš u HTML-u za prikaz vremena
  getDuration(inc: any): string {
    if (!inc.resolvedAt) return 'U toku...'; // Da ne bude prazno
    const start = new Date(inc.createdAt).getTime();
    const end = new Date(inc.resolvedAt).getTime();
    return this.formatTimeDiff(start, end);
  }

  // Novo: Vreme od nastanka do preuzimanja (assignedAt)
  getResponseTime(inc: any): string {
    if (!inc.assignedAt) return 'Nije preuzeto';
    const start = new Date(inc.createdAt).getTime();
    const assigned = new Date(inc.assignedAt).getTime();
    return this.formatTimeDiff(start, assigned);
  }

  private formatTimeDiff(start: number, end: number): string {
    const diffMins = Math.round((end - start) / 60000);
    if (diffMins < 1) return '< 1 min';
    if (diffMins < 60) return `${diffMins} min`;
    return `${Math.floor(diffMins / 60)}h ${diffMins % 60}min`;
  }
}