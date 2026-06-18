import { Component, OnInit, inject } from '@angular/core';
import { Store } from '@ngrx/store';
import { IncidentActions } from '../../store/incident/incident.actions';
import { CommonModule } from '@angular/common';
import { selectAllIncidents } from '../../store/incident/incident.selector';
import { AuthService } from '../../core/services/auth';
import { Incident } from '../../core/models/incident.model';
import { map } from 'rxjs';

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
  
  incidents$ = this.store.select(selectAllIncidents).pipe(
    map(incidents => [...incidents].sort((a, b) => {
      const aDesc = a.description || '';
      const bDesc = b.description || '';

      // 1. KRITERIJUM: Rucne prijave idu na vrh!
      const aManual = aDesc.includes('[RUČNA PRIJAVA') ? 1 : 0;
      const bManual = bDesc.includes('[RUČNA PRIJAVA') ? 1 : 0;
      if (aManual !== bManual) {
        return bManual - aManual; 
      }

      // 2. KRITERIJUM: Status (Aktivni idu ispred resenih)
      const aResolved = a.status === 'RESOLVED' ? 1 : 0;
      const bResolved = b.status === 'RESOLVED' ? 1 : 0;
      if (aResolved !== bResolved) {
        return aResolved - bResolved; 
      }

      // 3. KRITERIJUM: Ako je sve isto, noviji ID (veći broj) ide prvi
      return b.id - a.id;
    }))
  );

  ngOnInit() {
    this.store.dispatch(IncidentActions.loadIncidents());
  }

  /*
  claimIncident(incidentId: number) {
    const user = JSON.parse(localStorage.getItem('user_data') || '{}');
    if (user && user.id) {
      this.store.dispatch(IncidentActions.takeIncident({ 
        id: incidentId, 
        userId: user.id 
      }));
    }
  }*/

 claimIncident(incident: Incident) {
    const currentUser = this.authService.getCurrentUserValue();
    if (!currentUser) return;

    const username = currentUser.username || 'operater';
    const trenutnoVreme = new Date().toLocaleTimeString('sr-RS', { hour: '2-digit', minute: '2-digit' });
    
    
    const Log = `📥 @${username} preuzeo u ${trenutnoVreme}`;

    this.store.dispatch(IncidentActions.updateIncident({
      id: incident.id,
      changes: {
        status: 'IN_PROGRESS',
        assignedToId: currentUser.id,  
        historyLogs: Log
      }
    }));
  }

  hasBeenAbandoned(historyLogs: string | undefined): boolean {
    if (!historyLogs) return false;
    return historyLogs.includes('odustao') || historyLogs.includes('↩️');
  }
}