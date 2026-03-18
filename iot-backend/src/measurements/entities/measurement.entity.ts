import { Sensor } from "src/sensors/entities/sensor.entity";
import { Column, CreateDateColumn, Entity, ManyToOne, PrimaryGeneratedColumn } from "typeorm";

@Entity()
export class Measurement {
  @PrimaryGeneratedColumn()
  id: number;

  @Column('float')
  value: number;

  @CreateDateColumn({ type: 'timestamptz' })
  timestamp: Date;

  @ManyToOne(() => Sensor, (s) => s.measurements, { onDelete: 'CASCADE'})
  sensor: Sensor; 
}
