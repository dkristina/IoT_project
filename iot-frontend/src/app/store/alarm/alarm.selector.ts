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

// 4. Selektor za dobijanje alarma kao mape (rečnika) po ID-u (za brzi pristup)
export const selectAlarmEntities = createSelector(
  selectAlarmState,
  selectEntities
);

// 5. Selektor za loading status (da prikažeš spiner na frontu)
export const selectAlarmsLoading = createSelector(
  selectAlarmState,
  (state) => state.loading
);

// 6. NAPREDNI SELEKTOR: Filtriranje alarma po ozbiljnosti (koristi map/filter uslov)
export const selectCriticalAlarms = createSelector(
  selectAllAlarms,
  (alarms) => alarms.filter(a => a.severity === 'CRITICAL')
);