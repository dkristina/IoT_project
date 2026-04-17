import { Sensor } from './sensor.model';

export enum AlarmSeverity {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  CRITICAL = 'CRITICAL',
}

export interface Alarm {
  id: number;
  lowThreshold: number;
  highThreshold: number;
  severity: AlarmSeverity;
  sensor?: Sensor; // Opciono, zavisi da li ga backend salje u Join-u
}