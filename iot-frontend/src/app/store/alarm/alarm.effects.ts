import { Injectable, inject } from '@angular/core';
import { Actions, createEffect, ofType } from '@ngrx/effects';
// DODAJ 'tap' OVDE U IMPORT
import { switchMap, map, catchError, of, tap } from 'rxjs'; 
import { AlarmsService } from '../../core/services/alarm.service';
import { AlarmActions } from './alarm.action';
import * as SensorActions from '../sensors/sensor.actions';
import { Store } from '@ngrx/store';

@Injectable()
export class AlarmEffects {
  private actions$ = inject(Actions);
  private alarmsService = inject(AlarmsService);
  private store = inject(Store);

  loadAlarms$ = createEffect(() => this.actions$.pipe(
    ofType(AlarmActions.loadAlarms),
    switchMap(() => this.alarmsService.findAll().pipe(
      map(alarms => AlarmActions.alarmsLoadedSuccess({ alarms })),
      catchError(error => of(AlarmActions.alarmsLoadedFailure({ error })))
    ))
  ));

  addAlarm$ = createEffect(() => this.actions$.pipe(
    ofType(AlarmActions.addAlarm),
    switchMap(({ alarm }) => this.alarmsService.create(alarm).pipe(
      map(newAlarm => AlarmActions.addAlarmSuccess({ alarm: newAlarm })),
      catchError(error => of(AlarmActions.alarmsLoadedFailure({ error })))
    ))
  ));

  deleteAlarm$ = createEffect(() => this.actions$.pipe(
    ofType(AlarmActions.deleteAlarm),
    switchMap(({ id }) => this.alarmsService.remove(id).pipe(
      map(() => AlarmActions.deleteAlarmSuccess({ id })),
      catchError(error => of(AlarmActions.alarmsLoadedFailure({ error })))
    ))
  ));

  updateAlarm$ = createEffect(() => 
  this.actions$.pipe(
    ofType(AlarmActions.updateAlarm),
    switchMap(({ id, changes }) => 
      this.alarmsService.update(id, changes).pipe(
        map(updatedAlarm => AlarmActions.updateAlarmSuccess({ 
          alarm: { id: updatedAlarm.id, changes: updatedAlarm } 
        })),
        tap((action) => {
          const sensorId = action.alarm.changes.id; 
          if (sensorId) {
            this.store.dispatch(SensorActions.loadSensorById({ id: sensorId }));
          }
        }),
        catchError(error => of(AlarmActions.alarmsLoadedFailure({ error })))
      )
    )
  )
);
}