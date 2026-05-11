import { EntityState, EntityAdapter, createEntityAdapter } from '@ngrx/entity';
import { createReducer, on } from '@ngrx/store';
import { Alarm } from '../../core/models/alarm.model';
import { AlarmActions } from './alarm.action';


export interface State extends EntityState<Alarm> {
  loading: boolean;
  error: any;
}

export const adapter: EntityAdapter<Alarm> = createEntityAdapter<Alarm>();

export const initialState: State = adapter.getInitialState({
  loading: false,
  error: null
});

export const alarmReducer = createReducer(
  initialState,
  on(AlarmActions.loadAlarms, (state) => ({ ...state, loading: true })),
  on(AlarmActions.alarmsLoadedSuccess, (state, { alarms }) => adapter.setAll(alarms, { ...state, loading: false })),
  on(AlarmActions.addAlarmSuccess, (state, { alarm }) => adapter.addOne(alarm, state)),
  on(AlarmActions.updateAlarmSuccess, (state, { alarm }) => adapter.updateOne(alarm, state)),
  on(AlarmActions.deleteAlarmSuccess, (state, { id }) => adapter.removeOne(id, state))
);

// Selektori
export const { selectAll, selectEntities } = adapter.getSelectors();