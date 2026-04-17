import { Sensor } from './sensor.model';

export interface Measurement {
  id: number;
  value: number;
  timestamp: Date;
  sensorId: number;
  sensor?: Sensor;
}