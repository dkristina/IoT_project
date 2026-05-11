import { createReducer, on } from '@ngrx/store';
import { EntityState, EntityAdapter, createEntityAdapter } from '@ngrx/entity';

import { IncidentActions } from './incident.actions';
import { Incident } from '../../core/models/incident.model';

export interface IncidentState extends EntityState<Incident> {
  loading: boolean;
  error: any;
}

export const adapter: EntityAdapter<Incident> = createEntityAdapter<Incident>();

export const initialState: IncidentState = adapter.getInitialState({
  loading: false,
  error: null
});

export const incidentReducer = createReducer(
  initialState,
  on(IncidentActions.loadIncidents, (state) => ({ ...state, loading: true })),
  
  on(IncidentActions.loadIncidentsSuccess, (state, { incidents }) => 
    adapter.setAll(incidents, { ...state, loading: false })),

  on(IncidentActions.updateIncidentSuccess, (state, { incident }) => 
    adapter.upsertOne(incident, { ...state, loading: false })),

  on(IncidentActions.socketIncidentReceived, (state, { incident }) => 
    adapter.upsertOne(incident, { ...state, loading: false })),

  on(IncidentActions.loadIncidentsFailure, (state, { error }) => ({ ...state, error, loading: false })),

  on(IncidentActions.createIncidentSuccess, (state, { incident }) => 
    adapter.upsertOne(incident, { ...state, loading: false }))

  
);