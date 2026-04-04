import { Injectable, NotFoundException, UseGuards } from '@nestjs/common';
import { CreateMeasurementDto } from './dto/create-measurement.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Measurement } from './entities/measurement.entity';
import { Repository } from 'typeorm';
import { AlarmsService } from 'src/alarms/alarms.service';
import { IncidentsService } from 'src/incidents/incidents.service';
import { AlarmSeverity } from 'src/alarms/entities/alarm.entity';
import { IotGateway } from 'src/gateways/iot.gateway';
import { Sensor } from 'src/sensors/entities/sensor.entity';

@Injectable()
export class MeasurementsService {
  constructor(
    @InjectRepository(Measurement)
    private readonly measurementsRepository: Repository<Measurement>, 

    @InjectRepository(Sensor)
    private readonly sensorsRepository: Repository<Sensor>,

    private readonly alarmsService: AlarmsService, //da proveri da li merenje krsi neko pravilo
    private readonly incidentsService: IncidentsService, //da prijavi problem
    private readonly iotGateway: IotGateway,
  ){}

  async create(createMeasurementDto: CreateMeasurementDto): Promise<Measurement> {
    //provera da li postoj senzor
    const sensor = await this.sensorsRepository.findOne({
      where: { id: createMeasurementDto.sensorId },
    });

    if (!sensor) {
      throw new NotFoundException(`Sensor with ID ${createMeasurementDto.sensorId} not found.`);
    }

    //snimanje merenja u bazu
    const measurement = this.measurementsRepository.create(createMeasurementDto);
    const saved = await this.measurementsRepository.save(measurement);

    //posalji merenje na WebSocket cim se sacuva
    this.iotGateway.sendMeasurementUpdate(saved);

    //OPTIMIZACIJA: Uzimamo poslednja 3 merenja SAMO JEDNOM ovde
    const lastThree = await this.measurementsRepository.find({
      where: { sensorId: createMeasurementDto.sensorId },
      order: { timestamp: 'DESC' },
      take: 3,
    });

    //dobavljanje alarma za taj senzor
    const alarms = await this.alarmsService.findBySensor(createMeasurementDto.sensorId);

    for (const alarm of alarms) {
      const isOutOfBounds = saved.value > alarm.highThreshold || saved.value < alarm.lowThreshold;

      if (isOutOfBounds) {
        //ANTI-SPAM: proveravamo da li vec postoji otvoren incident
        //ako postoji, ne idemo dalje u kreiranje novog
        const activeIncident = await this.incidentsService.findActiveBySensor(createMeasurementDto.sensorId);
        
        if (activeIncident) {
          console.log(`[INFO] An active incident already exists for sensor ${createMeasurementDto.sensorId}. I'm skipping.`);
          continue; 
        }

        //LOGIKA: Critical (odmah) vs Ostali (3 u nizu)
        if (alarm.severity === AlarmSeverity.CRITICAL) {
          console.log(`[ALERT] Critical alarm detected!`);
          const newIncident = await this.incidentsService.createFromMeasurement(saved, alarm); 

          //posalji incident na WebSocket
          this.iotGateway.sendIncidentAlert(newIncident); 
        } else {
          // Provera 3 u nizu koristeci 'lastThree' koji smo gore izvukli
          const allThreeBad = lastThree.length === 3 && lastThree.every(m => 
            m.value > alarm.highThreshold || m.value < alarm.lowThreshold
          );

          if (allThreeBad) {
            console.log(`[ALERT] 3-in-a-row alarm detected!`);
            const newIncident = await this.incidentsService.createFromMeasurement(saved, alarm);

            this.iotGateway.sendIncidentAlert(newIncident); 
          }
        }
      }
    }

    return saved;
  }

  async findAll(): Promise<Measurement[]> {
    return await this.measurementsRepository.find({
      relations: ['sensor'],
      order: { timestamp: 'DESC' }
    });
  }

  async findOne(id: number): Promise<Measurement> {
   const measurement = await this.measurementsRepository.findOne({
      where: { id },
      relations: ['sensor']
    });
    if (!measurement) throw new NotFoundException(`Measurement #${id} does not exist.`);
    return measurement;
  }

  
}
