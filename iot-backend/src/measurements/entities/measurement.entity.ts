import { Sensor } from "src/sensors/entities/sensor.entity";
import { Column, CreateDateColumn, Entity, Index, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from "typeorm";

@Index(['sensorId', 'timestamp']) //optimizacija za brzu pretragu istorije
@Entity()
export class Measurement {
  @PrimaryGeneratedColumn()
  id: number;

  @Column('float')
  value: number;

  @Column({ type: 'timestamptz', default: () => 'CURRENT_TIMESTAMP' })
  timestamp: Date;

  //eksplicitna kolona za ID senzora
  //omogucava nam brze upite nad tabelom senzora
  //kod spitivanja 3 merenja (smanjuje memorijski overhead)
  @Column()
  sensorId: number;

  @ManyToOne(() => Sensor, (s) => s.measurements, { onDelete: 'CASCADE'})
  @JoinColumn({ name: 'sensorId' }) 
  sensor: Sensor; 
}
