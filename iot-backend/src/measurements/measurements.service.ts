import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateMeasurementDto } from './dto/create-measurement.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Measurement } from './entities/measurement.entity';
import { Repository } from 'typeorm';
import { AlarmsService } from 'src/alarms/alarms.service';
import { IncidentsService } from 'src/incidents/incidents.service';
import { AlarmSeverity } from 'src/alarms/entities/alarm.entity';

@Injectable()
export class MeasurementsService {
  constructor(
    @InjectRepository(Measurement)
    private readonly measurementsRepository: Repository<Measurement>, 

    private readonly alarmsService: AlarmsService, //da proveri da li merenje krsi neko pravilo
    private readonly incidentsService: IncidentsService, //da prijavi problem
  ){}

  async create(createMeasurementDto: CreateMeasurementDto): Promise<Measurement> {
    const sensor = await this.measurementsRepository.manager.findOne('Sensor', {
      where: { id: createMeasurementDto.sensorId }
    });

    if (!sensor) {
      throw new NotFoundException(`Sensor with ID ${createMeasurementDto.sensorId} not found.`);
    }
    
    //snimanje novog merenja
    const measurement = this.measurementsRepository.create(createMeasurementDto);
    const saved = await this.measurementsRepository.save(measurement);

    //dobavljenje definisahin pravila (alarma) za taj senzor
    const alarms = await this.alarmsService.findBySensor(createMeasurementDto.sensorId);

    //iteracija kroz svaki alarm
    for (const alarm of alarms)
    {
      const isOutOfBounds = saved.value > alarm.highThreshold || saved.value < alarm.lowThreshold;

      if(isOutOfBounds) {
        //ako je CRITICAL -> odmah incident 
        if(alarm.severity === AlarmSeverity.CRITICAL)
        {
          await this.incidentsService.createFromMeasurement(saved, alarm); 
        }
        //logika za LOW, MEDIUM, HIGH -> provera 3 u nizu
        else {
          const lastThree = await this.measurementsRepository.find({
            where: {sensorId: createMeasurementDto.sensorId}, 
            order: {timestamp: 'DESC'}, 
            take: 3,
          }); 

          const allThreeBad = lastThree.length === 3 && lastThree.every(m => 
            m.value > alarm.highThreshold || m.value < alarm.lowThreshold
          );

          if (allThreeBad) {
            await this.incidentsService.createFromMeasurement(saved, alarm);
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
