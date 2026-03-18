import { Alarm } from "src/alarms/entities/alarm.entity";
import { Incident } from "src/incidents/entities/incident.entity";
import { Measurement } from "src/measurements/entities/measurement.entity";
import { Column, Entity, OneToMany, PrimaryColumn, PrimaryGeneratedColumn } from "typeorm";

export enum SensorUnit {
  CELSIUS = '°C',
  PERCENTAGE = '%',
  BAR = 'bar',
  VOLTAGE = 'V',
}

@Entity()
export class Sensor {
    @PrimaryGeneratedColumn()
    id: number; 

    @Column()
    name: string; 

    @Column()
    location: string; 

    @Column({
        type: 'enum', 
        enum: SensorUnit,
    })
    unit: SensorUnit; 

    @OneToMany(() => Measurement, (m) => m.sensor)
    measurements: Measurement[]; 

    @OneToMany(() => Alarm, (a) => a.sensor)
    alarms: Alarm[];

    @OneToMany(() => Incident, (i) => i.sensor)
    incidents: Incident[];
    
}
