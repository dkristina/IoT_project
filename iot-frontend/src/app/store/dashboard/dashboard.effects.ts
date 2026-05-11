import { Injectable, inject } from '@angular/core';
import { Actions, createEffect, ofType } from '@ngrx/effects';
import { forkJoin, of } from 'rxjs';
import { map, switchMap, catchError } from 'rxjs/operators';
import { SensorsService } from '../../core/services/sensor.service';
import { IncidentService } from '../../core/services/incident.service';
import * as DashboardActions from './dashboard.actions';

@Injectable()
export class DashboardEffects {
  private actions$ = inject(Actions);
  private sensorsService = inject(SensorsService);
  private incidentService = inject(IncidentService);

  loadDashboard$ = createEffect(() => this.actions$.pipe(
    ofType(DashboardActions.loadDashboard),
    switchMap(() => forkJoin({
      sensors: this.sensorsService.getSensors(),
      incidents: this.incidentService.findAll()
    }).pipe(
      map(data => DashboardActions.loadDashboardSuccess({ 
        sensors: data.sensors, 
        incidents: data.incidents 
      })),
      catchError(error => of(DashboardActions.loadDashboardFailure({ error })))
    ))
  ));
}