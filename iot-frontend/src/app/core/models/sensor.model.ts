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
    alarms?: any[]; 
    measurements?: any[]; 
}