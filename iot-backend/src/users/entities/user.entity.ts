import { Incident } from "src/incidents/entities/incident.entity";
import { Column, Entity, OneToMany, PrimaryGeneratedColumn } from "typeorm";

export enum UserRole {
    ADMIN = 'ADMIN', 
    OPERATOR = 'OPERATOR'
}

@Entity()
export class User {
    @PrimaryGeneratedColumn()
    id: number; 

    @Column({unique: true})
    username: string; 

    @Column({ select: false }) //da se ne salje u GET odgovorima
    password: string; 

    @Column({unique: true})
    email: string; 

    @Column({nullable: true})
    fullName: string;

    @Column({
        default: 'https://cdn-icons-png.flaticon.com/512/149/149071.png'
    })
    avatarUrl: string; 

    @Column({
        type: 'enum', 
        enum: UserRole, 
        default: UserRole.OPERATOR, 
    })
    role: UserRole; 

    @OneToMany(() => Incident, (i) => i.assignedTo)
    incidents: Incident[]; 
}
