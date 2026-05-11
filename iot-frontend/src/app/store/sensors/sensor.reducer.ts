import { createEntityAdapter, EntityAdapter, EntityState } from '@ngrx/entity';
import { createReducer, on } from '@ngrx/store';
import { Sensor } from '../../core/models/sensor.model'; // Proveri putanju!
import * as SensorActions from './sensor.actions';

// 1. Definisemo interfejs stanja
export interface SensorState extends EntityState<Sensor> {
  loading: boolean;
  error: string | null;
}

// 2. Kreiramo adapter
export const adapter: EntityAdapter<Sensor> = createEntityAdapter<Sensor>();

// 3. Definisemo pocetno stanje
export const initialState: SensorState = adapter.getInitialState({
  loading: false,
  error: null
});

export const sensorReducer = createReducer(
  initialState,
  on(SensorActions.loadSensors, state => ({ ...state, loading: true })),
  on(SensorActions.loadSensorsSuccess, (state, { sensors }) => 
    adapter.setAll(sensors, { ...state, loading: false })),
  on(SensorActions.addSensorSuccess, (state, { sensor }) => 
    adapter.addOne(sensor, state)),
  on(SensorActions.deleteSensorSuccess, (state, { id }) => 
    adapter.removeOne(id, state)),
  on(SensorActions.loadSensorsFailure,
    SensorActions.addSensorFailure, 
    SensorActions.deleteSensorFailure, 
    (state, { error }) => ({ ...state, error, loading: false })),
  
  on(SensorActions.loadSensorById, state => ({ ...state, loading: true })),
  on(SensorActions.loadSensorByIdSuccess, (state, { sensor }) => 
    adapter.upsertOne(sensor, { ...state, loading: false })), // upsertOne menja postojeći ili dodaje novi
  on(SensorActions.loadSensorByIdFailure, (state, { error }) => 
    ({ ...state, error, loading: false })),
  
  on(SensorActions.updateSensorSuccess, (state, { sensor }) =>
    adapter.upsertOne(sensor, { ...state, loading: false })),
);