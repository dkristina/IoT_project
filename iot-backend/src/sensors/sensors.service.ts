import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateSensorDto } from './dto/create-sensor.dto';
import { UpdateSensorDto } from './dto/update-sensor.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Sensor } from './entities/sensor.entity';
import { Repository } from 'typeorm';

@Injectable()
export class SensorsService {
  constructor(
    @InjectRepository(Sensor)
    private sensorsRepository: Repository<Sensor>
  ){}

  //1.
  async create(createSensorDto: CreateSensorDto): Promise <Sensor> {
    const sensor = this.sensorsRepository.create(createSensorDto); 
    return await this.sensorsRepository.save(sensor); 
  }

  //2. 
  //lista svih senzora sa njihovim alarmima (da vidimo pravila)
  async findAll(): Promise<Sensor[]> {
    return await this.sensorsRepository.find({ relations: ['alarms']}); 
  }

  async findOne(id: number): Promise<Sensor> {
    const sensor = await this.sensorsRepository.findOne({ where: { id }, relations: ['measurements'] });
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
