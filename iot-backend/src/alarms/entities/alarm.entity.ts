import { Sensor } from "src/sensors/entities/sensor.entity";
import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from "typeorm";

export enum AlarmSeverity {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  CRITICAL = 'CRITICAL',
}

@Entity()
export class Alarm {
    @PrimaryGeneratedColumn()
    id: number;
    
    @Column('float')
    lowThreshold: number; 

    @Column('float')
    highThreshold: number;

    @Column({ type: 'enum', enum: AlarmSeverity, default: AlarmSeverity.CRITICAL })
    severity: AlarmSeverity;
    
    @ManyToOne(() => Sensor, (s) => s.alarms, { onDelete: 'CASCADE' })
    sensor: Sensor;
}
