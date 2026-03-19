import { Sensor } from "src/sensors/entities/sensor.entity";
import { User } from "src/users/entities/user.entity";
import { Column, CreateDateColumn, Entity, ManyToOne, PrimaryGeneratedColumn } from "typeorm";

export enum IncidentStatus {
  NEW = 'NEW',
  IN_PROGRESS = 'IN_PROGRESS',
  RESOLVED = 'RESOLVED',
}

@Entity()
export class Incident {
    @PrimaryGeneratedColumn()
    id: number; 

    @Column()
    description: string;

    @Column({ type: 'enum', enum: IncidentStatus, default: IncidentStatus.NEW })
    status: IncidentStatus;

    @CreateDateColumn()
    createdAt: Date;

    @Column({ nullable: true, type: 'timestamptz' })
    resolvedAt: Date;

    @ManyToOne(() => User, (u) => u.incidents, {nullable: true})
    assignedTo: User; 

    @ManyToOne(() => Sensor, (s) => s.incidents)
    sensor: Sensor; 
}
