import { ApplicationConfig, provideBrowserGlobalErrorListeners } from '@angular/core';
import { provideRouter } from '@angular/router';

import { routes } from './app.routes';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { dashboardReducer } from './store/dashboard/dashboard.reducer';
import { DashboardEffects } from './store/dashboard/dashboard.effects';
import { provideState, provideStore } from '@ngrx/store';
import { provideEffects } from '@ngrx/effects';
import { WebsocketService } from './core/services/websocket.service';
import { provideCharts, withDefaultRegisterables } from 'ng2-charts';
import { sensorReducer } from './store/sensors/sensor.reducer';
import { SensorEffects } from './store/sensors/sensor.effects';
import { authInterceptor } from './core/interceptors/auth.interceptor';
import { IncidentEffects } from './store/incident/incident.effects';
import { incidentReducer } from './store/incident/incident.reducer';
import { AlarmEffects } from './store/alarm/alarm.effects';
import { alarmReducer } from './store/alarm/alarm.reducer';
import { userReducer } from './store/user/user.reducer';
import { UserEffects } from './store/user/user.effects';

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(routes),
    provideHttpClient(withInterceptors([authInterceptor])),
    
    provideStore(),

    provideState('dashboard', dashboardReducer),
    provideState('sensors', sensorReducer),
    provideState('incidents', incidentReducer),
    provideState('alarms', alarmReducer),
    provideState('users', userReducer),

    provideEffects([DashboardEffects, SensorEffects, IncidentEffects, AlarmEffects, UserEffects]),

    WebsocketService,
    provideCharts(withDefaultRegisterables()),
  ]
};

