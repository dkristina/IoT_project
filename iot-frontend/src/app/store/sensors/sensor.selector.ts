import { createFeatureSelector, createSelector } from '@ngrx/store';
import { SensorState, adapter } from './sensor.reducer'; // OVO NEDOSTAJE
import { selectAllAlarms } from '../alarm/alarm.selector';

export const selectSensorState = createFeatureSelector<SensorState>('sensors');

export const {
  selectAll,
  selectEntities,
  selectIds,
  selectTotal,
} = adapter.getSelectors(selectSensorState);


export const selectSensorsByLocation = (location: string) => createSelector(
  selectAll,
  (sensors) => sensors.filter(s => s.location === location)
);

export const selectSensorStats = createSelector(
  selectAll,
  (sensors) => ({
    total: sensors.length,
    activeIncidents: sensors.reduce((acc, s) => acc + (s.incidents?.filter(i => !i.resolvedAt).length || 0), 0),
    locations: [...new Set(sensors.map(s => s.location))].length
  })
);

export const selectLoading = createSelector(
    selectSensorState, 
    (state) => state.loading
);

export const selectError = createSelector(
  selectSensorState,
  (state) => state.error
);

// Selektor koji prima ID i vraća taj konkretan senzor iz Entities
export const selectSensorById = (sensorId: number) => createSelector(
  selectEntities,
  (entities) => entities[sensorId] || null
);

// Kombinovani selektor koji garantuje najnovije podatke o alarmima
export const selectSensorWithAlarms = (sensorId: number) => createSelector(
  selectSensorById(sensorId), // tvoj postojeći selektor
  selectAllAlarms,            // onaj selektor koji si mi poslala iz alarm.reducera
  (sensor, allAlarms) => {
    if (!sensor) return null;
    // Filtriramo sveže alarme iz Alarm store-a koji pripadaju ovom senzoru
    return {
      ...sensor,
      alarms: allAlarms.filter(alarm => alarm.id === sensorId || sensor.alarms?.some(a => a.id === alarm.id))
    };
  }
);