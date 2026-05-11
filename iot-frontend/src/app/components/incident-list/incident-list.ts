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

}