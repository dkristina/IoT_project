import { Alarm } from "./alarm.model";
import { Incident } from "./incident.model";
import { Measurement } from "./measurement.model";

export enum SensorUnit {
  CELSIUS = '°C',
  PERCENTAGE = '%',
  BAR = 'bar',
  VOLTAGE = 'V',
}

export interface Sensor {
    id: number; 
    name: string; 
    location: string; 
    unit: SensorUnit; 
    measurements?: Measurement[];
    alarms?: Alarm[];
    incidents?: Incident[];
}