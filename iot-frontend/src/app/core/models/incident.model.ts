import { AlarmSeverity } from './alarm.model';
import { Sensor } from './sensor.model';
import { User } from './user.model';


export enum IncidentStatus {
  NEW = 'NEW',
  IN_PROGRESS = 'IN_PROGRESS',
  RESOLVED = 'RESOLVED',
}

export interface Incident {
  id: number;
  description: string;
  severity: AlarmSeverity;
  status: IncidentStatus;
  createdAt: Date;
  resolvedAt?: Date;
  pickedUpAt?: Date;
  assignedTo?: User;
  sensor?: Sensor;
  historyLogs?: string;
}