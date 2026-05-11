import { inject, Injectable } from '@angular/core';
import { Actions, createEffect, ofType, OnInitEffects } from '@ngrx/effects';

import { IncidentActions } from './incident.actions';
import { catchError, map, mergeMap, of, switchMap, tap, zip } from 'rxjs';
import { IncidentService } from '../../core/services/incident.service';
import { MatSnackBar } from '@angular/material/snack-bar';
import { WebsocketService } from '../../core/services/websocket.service';
import { Action } from '@ngrx/store';

@Injectable()
export class IncidentEffects implements OnInitEffects{
  private actions$ = inject(Actions);
  private incidentService = inject(IncidentService);
  private snackBar = inject(MatSnackBar);
  private webSocketService = inject(WebsocketService);

  ngrxOnInitEffects(): Action {
    return { type: '[Incident] Initialize WebSockets' };
  }

  loadIncidents$ = createEffect(() => this.actions$.pipe(
    ofType(IncidentActions.loadIncidents),
    mergeMap(() => this.incidentService.findAll().pipe(
      map(incidents => IncidentActions.loadIncidentsSuccess({ incidents })),
      catchError(error => of(IncidentActions.loadIncidentsFailure({ error })))
    ))
  ));

  updateIncident$ = createEffect(() => this.actions$.pipe(
    ofType(IncidentActions.updateIncident),
    mergeMap(({ id, changes }) => this.incidentService.update(id, changes).pipe(
      map(incident => IncidentActions.updateIncidentSuccess({ incident })),
      catchError(error => of(IncidentActions.updateIncidentFailure({ error })))
    ))
  ));

  createIncident$ = createEffect(() => this.actions$.pipe(
    ofType(IncidentActions.createIncident),
    mergeMap(({ incident }) => this.incidentService.create(incident).pipe(
      map(newIncident => IncidentActions.createIncidentSuccess({ incident: newIncident })),
      catchError(error => of(IncidentActions.createIncidentFailure({ error })))
    ))
  ));

  showNotification$ = createEffect(() => this.actions$.pipe(
    ofType(IncidentActions.createIncidentSuccess, IncidentActions.socketIncidentReceived),
    tap(({ incident }) => {

      if (incident.status !== 'NEW') {
        return; 
      }
      // Određujemo klasu na osnovu stvarnog severity-ja incidenta
      let snackClass = 'info-snackbar'; // default
      
      switch (incident.severity) {
        case 'CRITICAL': snackClass = 'red-snackbar'; break;
        case 'HIGH':     snackClass = 'orange-snackbar'; break;
        case 'MEDIUM':   snackClass = 'yellow-snackbar'; break;
        case 'LOW':      snackClass = 'blue-snackbar'; break;
      }

      this.snackBar.open(`⚠️ Novi incident: ${incident.description}`, 'OK', {
        duration: 5000,
        verticalPosition: 'top',
        horizontalPosition: 'right',
        panelClass: [snackClass] // Prosleđujemo dinamičku klasu
      });
    })
  ), { dispatch: false });

  takeIncident$ = createEffect(() => this.actions$.pipe(
    ofType(IncidentActions.takeIncident),
    switchMap(({ id, userId }) => {
      return zip(
        this.incidentService.takeIncident(id, userId), 
        of(JSON.parse(localStorage.getItem('user_data') || '{}'))
      ).pipe(
        map(([incident, currentUser]) => {
         
          const enrichedIncident = {
            ...incident,
            assignedTo: currentUser 
          };
          return IncidentActions.updateIncidentSuccess({ incident: enrichedIncident });
        }),
        catchError(error => of(IncidentActions.updateIncidentFailure({ error })))
      );
    })
  ));


loadIncidentsBySensor$ = createEffect(() => this.actions$.pipe(
  ofType(IncidentActions.loadIncidentsBySensor),
  mergeMap(({ sensorId }) => 
    this.incidentService.findBySensor(sensorId).pipe(
      map(incidents => IncidentActions.loadIncidentsSuccess({ incidents })),
      catchError(error => of(IncidentActions.loadIncidentsFailure({ error })))
    )
  )
));

initWebsocketStreams$ = createEffect(() => {
    return this.webSocketService.listenToIncidents().pipe(
      tap(data => console.log('STIGAO NOVI INCIDENT PREKO SOKETA:', data)),
      map(incident => IncidentActions.socketIncidentReceived({ incident }))
    );
  });

  // ISPRAVLJENO: Koristi se this.webSocketService
  initWebsocketUpdates$ = createEffect(() => {
    return this.webSocketService.listenToIncidentUpdates().pipe(
      tap(data => console.log('STIGAO UPDATE PREKO SOKETA:', data)),
      map(incident => IncidentActions.socketIncidentReceived({ incident }))
    );
  });
}

