import { createAction, props } from '@ngrx/store';
import { Sensor } from '../../core/models/sensor.model';


// Load Sensors
export const loadSensors = createAction('[Sensor List] Load Sensors');
export const loadSensorsSuccess = createAction('[Sensor API] Load Success', props<{ sensors: Sensor[] }>());
export const loadSensorsFailure = createAction('[Sensor API] Load Failure', props<{ error: string }>());

// Add Sensor
export const addSensor = createAction('[Sensor Admin] Add Sensor', props<{ sensor: Partial<Sensor> }>());
export const addSensorSuccess = createAction('[Sensor API] Add Success', props<{ sensor: Sensor }>());
export const addSensorFailure = createAction( '[Sensor API] Add Failure',  props<{ error: string }>());
// Delete Sensor
export const deleteSensor = createAction('[Sensor Admin] Delete Sensor', props<{ id: number }>());
export const deleteSensorSuccess = createAction('[Sensor API] Delete Success', props<{ id: number }>());
export const deleteSensorFailure = createAction('[Sensor API] Delete Failure', props<{ error: string }>());

export const loadSensorById = createAction('[Sensor Detail] Load Sensor By Id', props<{ id: number }>());
export const loadSensorByIdSuccess = createAction('[Sensor API] Load Sensor By Id Success', props<{ sensor: Sensor }>());
export const loadSensorByIdFailure = createAction('[Sensor API] Load Sensor By Id Failure', props<{ error: string }>());

export const updateSensor = createAction('[Sensor Edit] Update Sensor', props<{ id: number; sensor: Partial<Sensor> }>());
export const updateSensorSuccess = createAction('[Sensor API] Update Success', props<{ sensor: Sensor }>());
export const updateSensorFailure = createAction('[Sensor API] Update Failure', props<{ error: string }>());