import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateIncidentDto } from './dto/create-incident.dto';
import { UpdateIncidentDto } from './dto/update-incident.dto';
import { Not, Repository } from 'typeorm';
import { Incident, IncidentStatus } from './entities/incident.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { IotGateway } from 'src/gateways/iot.gateway';

@Injectable()
export class IncidentsService {
  constructor(
    @InjectRepository(Incident)
    private readonly incidentsRepository: Repository<Incident>,
    private readonly iotGateway: IotGateway,
  ){}

  async create(createIncidentDto: CreateIncidentDto): Promise<Incident> {
    const incident = this.incidentsRepository.create({
      ...createIncidentDto, 
      sensor: {id: createIncidentDto.sensorId} as any, 
      assignedTo: createIncidentDto.assignedToId ? { id: createIncidentDto.assignedToId } as any : null,
    }); 

    return await this.incidentsRepository.save(incident); 
  }

  async findAll(): Promise<Incident[]> {
    return await this.incidentsRepository.find({
      relations: ['sensor', 'assignedTo'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Incident> {
    const incident = await this.incidentsRepository.findOne({
      where: { id },
      relations: ['sensor', 'assignedTo'],
    }); 

    if (!incident) {
      throw new NotFoundException(`Incident with ID ${id} not found`);
    }
    return incident;
  }

  async update(id: number, updateIncidentDto: UpdateIncidentDto): Promise<Incident> {
    const incident = await this.findOne(id);

    //ako se status menja u RESOLVED, automatski postavljamp i vreme resavanja
    if(updateIncidentDto.status === IncidentStatus.RESOLVED && !incident.resolvedAt) {
      incident.resolvedAt = new Date(); 
    }

    if(updateIncidentDto.assignedToId){
      incident.assignedTo = {id: updateIncidentDto.assignedToId} as any;
    }

    Object.assign(incident, updateIncidentDto); 
    const updated = await this.incidentsRepository.save(incident); 

    this.iotGateway.sendIncidentAlert(updated);
    
    return updated; 
  }

  async remove(id: number): Promise<{ message: string }> {
    const incident = await this.findOne(id);
    await this.incidentsRepository.remove(incident);
    return { message: `Incident #${id} successfully removed` };
  }

  //automatsko kreiranje incidenata ( sistem )
  async createFromMeasurement(measurement: any, alarm: any): Promise<Incident> {
    const incident = this.incidentsRepository.create({
      description: `System generated alarm: Value ${measurement.value} is out of range (${alarm.lowThreshold} - ${alarm.highThreshold}).`,
      severity: alarm.severity, 
      status: IncidentStatus.NEW, 
      sensor: {id: measurement.sensorId} as any,
    })

    return await this.incidentsRepository.save(incident);
  }

  async findActiveBySensor(sensorId: number): Promise<Incident | null> {
  return await this.incidentsRepository.findOne({
    where: {
      sensor: { id: sensorId },
      status: Not(IncidentStatus.RESOLVED) //sve sto nije "reseno" se smatra aktivnim
    },
    relations: ['sensor'],
    order: { id: 'DESC' }
  });
}
}
