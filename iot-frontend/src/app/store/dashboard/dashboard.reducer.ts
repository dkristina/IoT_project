import { createReducer, on } from '@ngrx/store';
import * as DashboardActions from './dashboard.actions';

export interface DashboardState {
  sensors: any[];
  incidents: any[];
  loading: boolean;
  error: any;
}

export const initialState: DashboardState = {
  sensors: [],
  incidents: [],
  loading: false,
  error: null
};

export const dashboardReducer = createReducer(
  initialState,
  on(DashboardActions.loadDashboard, state => ({ ...state, loading: true })),
  on(DashboardActions.loadDashboardSuccess, (state, { sensors, incidents }) => ({
    ...state,
    sensors,
    incidents,
    loading: false
  })),
  on(DashboardActions.loadDashboardFailure, (state, { error }) => ({
    ...state,
    error,
    loading: false
  }))
);