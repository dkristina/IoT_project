import { Sensor } from "src/sensors/entities/sensor.entity";
import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from "typeorm";

export enum AlarmSeverity {
  CRITICAL = 'CRITICAL',
  WARNING = 'WARNING',
}

@Entity()
export class Alarm {
    @PrimaryGeneratedColumn()
    id: number;
    
    @Column('float')
    lowThreshold: number; 

    @Column()
    highThreshold: number;

    @Column({ type: 'enum', enum: AlarmSeverity, default: AlarmSeverity.CRITICAL })
    severity: AlarmSeverity;
    
    @ManyToOne(() => Sensor, (s) => s.alarms, { onDelete: 'CASCADE' })
    sensor: Sensor;
}
