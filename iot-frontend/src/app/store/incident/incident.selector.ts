import { createFeatureSelector, createSelector } from '@ngrx/store';
import { IncidentState, adapter } from './incident.reducer';
import { IncidentStatus } from '../../core/models/incident.model';


// 1. Hvatanje celog "incidents" state-a iz Store-a
export const selectIncidentState = createFeatureSelector<IncidentState>('incidents');

// 2. Korišćenje ugrađenih helpera iz EntityAdapter-a
const { selectAll, selectEntities } = adapter.getSelectors();

// 3. Selektor za SVE incidente
export const selectAllIncidents = createSelector(
  selectIncidentState,
  selectAll
);

// 4. Selektor za samo AKTIVNE incidente (oni koji nisu RESOLVED)

export const selectActiveIncidents = createSelector(
  selectAllIncidents,
  (incidents) => incidents.filter(i => i.status !== IncidentStatus.RESOLVED)
);

// 5. Selektor za statistiku
export const selectIncidentStatistics = createSelector(
  selectAllIncidents,
  (incidents) => {
    return {
      total: incidents.length,
      active: incidents.filter(i => i.status !== IncidentStatus.RESOLVED).length,
      critical: incidents.filter(i => i.severity === 'CRITICAL' && i.status !== IncidentStatus.RESOLVED).length,
      unassigned: incidents.filter(i => !i.assignedTo && i.status !== IncidentStatus.RESOLVED).length
    };
  }
);

// 6. Selektor za loading indikator
export const selectIncidentsLoading = createSelector(
  selectIncidentState,
  (state) => state.loading
);

// 7. Selektor za grešku
export const selectIncidentsError = createSelector(
  selectIncidentState,
  (state) => state.error
);


export const selectIncidentsBySensorId = (sensorId: number) => createSelector(
  selectAllIncidents,
  (incidents) => incidents.filter(i => i.id === sensorId && i.status !== IncidentStatus.RESOLVED)
);



export const selectMyIncidents = (user: any) => createSelector(
  selectAllIncidents,
  (incidents) => {
    if (!user) return [];
    const myUsername = user.username.toLowerCase();
    const myId = user.id;

    return incidents.filter(i => {
      // 1. Provera da li je dodeljen meni (preko ID-a ili username-a)
      const isAssigned = 
        i.assignedTo?.id === myId || 
        i.assignedTo?.username?.toLowerCase() === myUsername ||
        (typeof i.assignedTo === 'string' && i.assignedTo === myUsername);

      // 2. Provera da li sam ga ja kreirala (tvoj stari uslov)
      const isCreator = i.description?.toLowerCase().includes(myUsername);

      return isAssigned || isCreator;
    });
  }
);

export const selectFilteredIncidents = (criteria: { severity?: string, creator?: string, sensorId?: number }) => createSelector(
  selectAllIncidents,
  (incidents) => incidents.filter(i => {
    const matchSeverity = criteria.severity ? i.severity === criteria.severity : true;
    const matchCreator = criteria.creator ? i.description.toLowerCase().includes(criteria.creator.toLowerCase()) : true;
    const matchSensor = criteria.sensorId ? i.id === criteria.sensorId : true;
    return matchSeverity && matchCreator && matchSensor;
  })
);

export const selectSensorIncidentHistory = (sensorId: number) => createSelector(
  selectAllIncidents,
  (incidents) => incidents.filter(i => i.sensor?.id === sensorId)
);