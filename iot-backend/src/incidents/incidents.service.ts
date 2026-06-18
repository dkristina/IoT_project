import { Injectable, NotFoundException, UseGuards } from '@nestjs/common';
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

    const saved = await this.incidentsRepository.save(incident);
    
    const fullIncident = await this.findOne(saved.id);
    this.iotGateway.sendIncidentAlert(fullIncident); 
    
    return fullIncident;
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
    // 1. Nadji incident u bazi sa trenutnim stanjem
    const incident = await this.findOne(id);

    // 2. Rucna provera statusa i upisivanje vremenskih odrednica
    if (updateIncidentDto.status === IncidentStatus.RESOLVED) {
      incident.status = IncidentStatus.RESOLVED;
      if (!incident.resolvedAt) {
        incident.resolvedAt = new Date();
      }
    } 
    else if (updateIncidentDto.status === IncidentStatus.IN_PROGRESS) {
      incident.status = IncidentStatus.IN_PROGRESS;
      // Kada god status pređe u IN_PROGRESS (bilo prvi put ili nakon odustajanja),
      // postavljamo novo trenutno vreme kako bi se tacno racunalo vreme novog operatera.
      incident.pickedUpAt = new Date();
    } 
    else if (updateIncidentDto.status === IncidentStatus.NEW) {
      incident.status = IncidentStatus.NEW;
    } 
    else if (updateIncidentDto.status) {
      incident.status = updateIncidentDto.status;
    }

    if (updateIncidentDto.description) incident.description = updateIncidentDto.description;

    if (updateIncidentDto.historyLogs !== undefined && updateIncidentDto.historyLogs !== null) {
      const stariLogIzBaze = incident.historyLogs ? incident.historyLogs.trim() : '';
      const noviLogSaFronta = updateIncidentDto.historyLogs.trim();

      if (stariLogIzBaze === '') {
        incident.historyLogs = noviLogSaFronta;
      } else {
        if (!stariLogIzBaze.endsWith(noviLogSaFronta)) {
          incident.historyLogs = `${stariLogIzBaze} | ${noviLogSaFronta}`;
        }
      }
    }

    // 3. Provera za operatora (Preuzmi / Odustani)
    if (updateIncidentDto.hasOwnProperty('assignedToId')) {
      if (updateIncidentDto.assignedToId === null) {
        incident.assignedTo = null as any; 
        incident.status = IncidentStatus.NEW;
      } else {
        incident.assignedTo = { id: updateIncidentDto.assignedToId } as any; 
        
        if (incident.status === IncidentStatus.NEW || incident.status === IncidentStatus.IN_PROGRESS) {
          incident.status = IncidentStatus.IN_PROGRESS;
          incident.pickedUpAt = new Date();
        }
      }
    }

    // 4. Sacuvaj izmene u bazi
    const saved = await this.incidentsRepository.save(incident); 
    
    // 5. Pokupi sve relacije i posalji update kroz WebSocket
    const fullUpdated = await this.findOne(saved.id);
    this.iotGateway.sendIncidentUpdate(fullUpdated);
    
    return fullUpdated;
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

    const saved = await this.incidentsRepository.save(incident);
    
    
    const fullIncident = await this.findOne(saved.id);
    this.iotGateway.sendIncidentAlert(fullIncident);

    return fullIncident;
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

  async findBySensor(sensorId: number): Promise<Incident[]> {
    return await this.incidentsRepository.find({
      where: { sensor: { id: sensorId } },
      relations: ['assignedTo', 'sensor'], 
      order: { createdAt: 'DESC' },
    });
  }


}
