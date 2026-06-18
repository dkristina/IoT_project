import { createActionGroup, emptyProps, props } from '@ngrx/store';
import { Incident } from '../../core/models/incident.model';


export const IncidentActions = createActionGroup({
  source: 'Incident API',
  events: {
    'Load Incidents': emptyProps(),
    'Load Incidents Success': props<{ incidents: Incident[] }>(),
    'Load Incidents Failure': props<{ error: any }>(),

    'Load Incidents By Sensor': props<{ sensorId: number }>(),
    
    'Take Incident': props<{ id: number; userId: number }>(),

    'Update Incident': props<{ id: number; changes: any }>(),
    'Update Incident Success': props<{ incident: Incident }>(),
    'Update Incident Failure': props<{ error: any }>(),

    // WebSocket akcija
    'Socket Incident Received': props<{ incident: Incident }>(),
    'Socket New Incident Notification Only': props<{ incident: Incident }>(),
    
    'Create Incident': props<{ incident: Partial<Incident> }>(),
    'Create Incident Success': props<{ incident: Incident }>(),
    'Create Incident Failure': props<{ error: any }>(),
  }
});