import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateSensorDto } from './dto/create-sensor.dto';
import { UpdateSensorDto } from './dto/update-sensor.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Sensor } from './entities/sensor.entity';
import { Repository } from 'typeorm';
import { Alarm } from 'src/alarms/entities/alarm.entity';

@Injectable()
export class SensorsService {
  constructor(
    @InjectRepository(Sensor)
    private sensorsRepository: Repository<Sensor>,

    @InjectRepository(Alarm)
    private alarmsRepository: Repository<Alarm>
  ){}

  //1.
  async create(createSensorDto: CreateSensorDto): Promise <Sensor> {
  
    // Odvajamo niz alarma/pravila od osnovnih polja senzora
    const { alarms, ...sensorFields } = createSensorDto;

    // 1. Kreiramo i spasavamo senzor da bismo dobili ID
    const sensor = this.sensorsRepository.create(sensorFields); 
    const savedSensor = await this.sensorsRepository.save(sensor); 

    // 2. Ako je administrator poslao pravila, vezujemo ih za ovaj senzor i upisujemo u bazu
    if (alarms && alarms.length > 0) {
      const alarmEntities = alarms.map(alarm => this.alarmsRepository.create({
        lowThreshold: alarm.lowThreshold,
        highThreshold: alarm.highThreshold,
        severity: alarm.severity,
        sensor: savedSensor // Povezivanje preko relacije
      }));

      // Masovni upis svih pravila odjednom
      await this.alarmsRepository.save(alarmEntities);
    }

    // Vraćamo kompletiran senzor
    return savedSensor;
  }

  //2. 
  //lista svih senzora sa njihovim alarmima (da vidimo pravila)
  async findAll(): Promise<Sensor[]> {
    return await this.sensorsRepository.find({ relations: ['alarms']}); 
  }

  async findOne(id: number): Promise<Sensor> {
    const sensor = await this.sensorsRepository.findOne({ where: { id }, relations: ['measurements', 'alarms'] });
    if (!sensor) throw new NotFoundException(`Sensor with ID ${id} not found.`);
    return sensor;
  }

  async update(id: number, updateSensorDto: UpdateSensorDto): Promise<Sensor> {
    const sensor = await this.findOne(id);
    Object.assign(sensor, updateSensorDto);
    return await this.sensorsRepository.save(sensor);
  }

  async remove(id: number): Promise<{message: string}> {
    const sensor = await this.findOne(id);
    await this.sensorsRepository.remove(sensor);
    return { message: `Sensor ${sensor.name} was successfully deleted.` };
  }
}
