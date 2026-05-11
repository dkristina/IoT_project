import { inject, Injectable } from '@angular/core';
import { Actions, createEffect, ofType } from '@ngrx/effects';

import * as SensorActions from './sensor.actions';
import { map, exhaustMap, catchError, switchMap } from 'rxjs/operators';
import { forkJoin, of } from 'rxjs';
import { SensorsService } from '../../core/services/sensor.service';

@Injectable()
export class SensorEffects {
  private actions$ = inject(Actions);
  private sensorsService = inject(SensorsService);

  loadSensors$ = createEffect(() => this.actions$.pipe(
    ofType(SensorActions.loadSensors),
    switchMap(() => this.sensorsService.getSensors().pipe(
      map(sensors => SensorActions.loadSensorsSuccess({ sensors })),
      catchError(error => of(SensorActions.loadSensorsFailure({ error: error.message })))
    ))
  ));

  addSensor$ = createEffect(() => this.actions$.pipe(
    ofType(SensorActions.addSensor),
    switchMap((action) => this.sensorsService.createSensor(action.sensor).pipe(
      map(sensor => SensorActions.addSensorSuccess({ sensor })),
      catchError(error => of(SensorActions.loadSensorsFailure({ error: error.message })))
    ))
  ));

  deleteSensor$ = createEffect(() => this.actions$.pipe(
    ofType(SensorActions.deleteSensor),
    switchMap((action) => this.sensorsService.deleteSensor(action.id).pipe(
        map(() => SensorActions.deleteSensorSuccess({ id: action.id })), 
        catchError(error => of(SensorActions.deleteSensorFailure({ error: error.message })))
    ))
  ))

  
  loadSensorById$ = createEffect(() => this.actions$.pipe(
    ofType(SensorActions.loadSensorById),
    switchMap(({ id }) =>
      this.sensorsService.getSensorById(id).pipe(
        map(sensor => SensorActions.loadSensorByIdSuccess({ sensor })),
        catchError(error =>
          of(SensorActions.loadSensorByIdFailure({ error: error.message }))
        )
      )
    )
  ));

  updateSensor$ = createEffect(() =>
    this.actions$.pipe(
      ofType(SensorActions.updateSensor),
      switchMap(({ id, sensor }) =>
        this.sensorsService.updateSensor(id, sensor).pipe(
          map(updated =>
            SensorActions.updateSensorSuccess({ sensor: updated })
          ),
          catchError(error =>
            of(SensorActions.updateSensorFailure({ error: error.message }))
          )
        )
      )
    )
  );

  
  
}