import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateIncidentDto } from './dto/create-incident.dto';
import { UpdateIncidentDto } from './dto/update-incident.dto';
import { Repository } from 'typeorm';
import { Incident, IncidentStatus } from './entities/incident.entity';
import { InjectRepository } from '@nestjs/typeorm';

@Injectable()
export class IncidentsService {
  constructor(
    @InjectRepository(Incident)
    private readonly incidentsRepository: Repository<Incident>,
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
    await this.incidentsRepository.save(incident); 
    
    return await this.findOne(id); 
  }

  async remove(id: number): Promise<{ message: string }> {
    const incident = await this.findOne(id);
    await this.incidentsRepository.remove(incident);
    return { message: `Incident #${id} successfully removed` };
  }
}
