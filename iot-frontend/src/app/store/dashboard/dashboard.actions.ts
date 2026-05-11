import { createAction, props } from '@ngrx/store';

export const loadDashboard = createAction('[Dashboard] Load Data');
export const loadDashboardSuccess = createAction(
  '[Dashboard] Load Data Success',
  props<{ sensors: any[], incidents: any[] }>()
);
export const loadDashboardFailure = createAction(
  '[Dashboard] Load Data Failure',
  props<{ error: any }>()
);