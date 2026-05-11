import { Component, inject, signal } from '@angular/core';
import { NavigationEnd, Router, RouterOutlet } from '@angular/router';
import { CommonModule } from '@angular/common';
import { NavbarComponent } from './components/navbar/navbar';
import { AuthService } from './core/services/auth';
import { filter, map, Subject, Subscription, take, takeUntil } from 'rxjs';
import { WebsocketService } from './core/services/websocket.service';
import { Store } from '@ngrx/store';
import * as DashboardActions from './store/dashboard/dashboard.actions';
import { selectAllIncidents } from './store/incident/incident.selector';
import { IncidentActions } from './store/incident/incident.actions';


@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, NavbarComponent, CommonModule], 
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  //protected readonly title = signal('iot-frontend');
  public authService = inject(AuthService);
  private router = inject(Router);
  private socketService = inject(WebsocketService); // Injectuj socket
  private store = inject(Store); 

  private destroy$ = new Subject<void>();
  
  isLoginPage$ = this.router.events.pipe(
    filter(event => event instanceof NavigationEnd),
    map(() => this.router.url === '/login' || this.router.url === '/')
  );

  ngOnInit() {
    this.initSocketListeners();
  }

 private initSocketListeners() {
  // 1. INCIDENTI - Ovo ostaje skoro isto, jer želimo real-time update
  this.socketService.listenToIncidents()
    .pipe(takeUntil(this.destroy$))
    .subscribe(incidentFromServer => {
      this.store.select(selectAllIncidents).pipe(take(1)).subscribe(currentIncidents => {
        const exists = currentIncidents.find(i => i.id === incidentFromServer.id);
        if (exists) {
          this.store.dispatch(IncidentActions.updateIncidentSuccess({ incident: incidentFromServer }));
        } else {
          this.store.dispatch(IncidentActions.socketIncidentReceived({ incident: incidentFromServer }));
        }
      });
      // Osvežavamo dashboard SAMO kad se desi incident (to je retko i opravdano)
      this.store.dispatch(DashboardActions.loadDashboard());
    });

  // 2. MERENJA - OVDE JE PROBLEM
  this.socketService.listenToMeasurements()
    .pipe(takeUntil(this.destroy$))
    .subscribe(data => {
      console.log('New measurement received:', data);
      
      // OBRIŠI loadDashboard() odavde! 
      // Merenja služe samo da se pune tabele istorije, 
      // nema potrebe da se ceo dashboard resetuje zbog jednog broja.
    });
}

  ngOnDestroy() {
    // Kada se aplikacija ugasi, prekidamo vezu
    this.destroy$.next();
    this.destroy$.complete();
  }
}