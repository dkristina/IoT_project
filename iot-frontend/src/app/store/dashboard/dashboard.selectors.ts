import { createFeatureSelector, createSelector } from '@ngrx/store';
import { DashboardState } from './dashboard.reducer';

export interface DashboardStats {
  totalSensors: number;
  activeIncidents: number;
  criticalIncidents: number;
  stableSystems: number;
  loading: boolean;
}

export const selectDashboardState = createFeatureSelector<DashboardState>('dashboard');

export const selectDashboardStats = createSelector(
  selectDashboardState,
  (state: DashboardState): DashboardStats => {
    const active = state.incidents ? state.incidents.filter(i => i.status !== 'RESOLVED') : [];
    const sensorsWithIncidents = new Set(
      active.filter(i => i.sensor?.id != null).map(i => i.sensor!.id)
    );

    return {
      totalSensors: state.sensors?.length || 0,
      activeIncidents: active.length,
      criticalIncidents: active.filter(i => i.severity === 'CRITICAL').length,
      stableSystems: Math.max((state.sensors?.length || 0) - sensorsWithIncidents.size, 0),
      loading: state.loading
    };
  }
);

// 1. Selektujemo samo niz incidenata iz state-a
export const selectAllIncidents = createSelector(
  selectDashboardState,
  (state: DashboardState) => state.incidents || []
);

// 2. Selektujemo poslednjih 5 incidenata, sortirano po datumu 
export const selectRecentIncidents = createSelector(
  selectAllIncidents,
  (incidents) => {
    return [...incidents]
      .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
      .slice(0, 5);
  }
);