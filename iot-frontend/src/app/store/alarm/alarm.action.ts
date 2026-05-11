import { createActionGroup, emptyProps, props } from '@ngrx/store';

import { Update } from '@ngrx/entity';
import { Alarm } from '../../core/models/alarm.model';

export const AlarmActions = createActionGroup({
  source: 'Alarm/API',
  events: {
    'Load Alarms': emptyProps(),
    'Alarms Loaded Success': props<{ alarms: Alarm[] }>(),
    'Alarms Loaded Failure': props<{ error: any }>(),
    
    'Add Alarm': props<{ alarm: Partial<Alarm> }>(),
    'Add Alarm Success': props<{ alarm: Alarm }>(),
    
    'Update Alarm': props<{ id: number, changes: Partial<Alarm> }>(),
    'Update Alarm Success': props<{ alarm: Update<Alarm> }>(),
    
    'Delete Alarm': props<{ id: number }>(),
    'Delete Alarm Success': props<{ id: number }>(),
  }
});