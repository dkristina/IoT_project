import { createFeatureSelector, createSelector } from '@ngrx/store';
import { State, adapter } from './alarm.reducer';

// 1. Glavni selektor za ceo "alarm" state
export const selectAlarmState = createFeatureSelector<State>('alarms');

// 2. Automatski selektori koje nudi Entity Adapter
// Oni nam daju: selectAll, selectEntities, selectIds, selectTotal
const {
  selectAll,
  selectEntities,
} = adapter.getSelectors();

// 3. Selektor za dobijanje SVIH alarma u obliku niza (za liste)
export const selectAllAlarms = createSelector(
  selectAlarmState,
  selectAll
);

// 4. Selektor za dobijanje alarma kao mape po ID-u 
export const selectAlarmEntities = createSelector(
  selectAlarmState,
  selectEntities
);

// 5. Selektor za loading status 
export const selectAlarmsLoading = createSelector(
  selectAlarmState,
  (state) => state.loading
);

// 6. NAPREDNI SELEKTOR: Filtriranje alarma po ozbiljnosti 
export const selectCriticalAlarms = createSelector(
  selectAllAlarms,
  (alarms) => alarms.filter(a => a.severity === 'CRITICAL')
);

//7. iltriranje alarma za specifican senzor prema njegovom ID-u
export const selectAlarmsBySensorId = (sensorId: number) => createSelector(
  selectAllAlarms,
  (alarms) => {
    if (!alarms) return [];
    // Pokrivamo obe varijante (ako backend vraća ravan sensorId ILI objekat sensor: { id })
    return alarms.filter(alarm => 
      Number(alarm.sensor?.id) === Number(sensorId)
    );
  }
);