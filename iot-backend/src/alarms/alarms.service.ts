import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { CreateAlarmDto } from './dto/create-alarm.dto';
import { UpdateAlarmDto } from './dto/update-alarm.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { Alarm } from './entities/alarm.entity';
import { Repository } from 'typeorm';
import { Sensor } from 'src/sensors/entities/sensor.entity';

@Injectable()
export class AlarmsService {
  constructor(
    @InjectRepository(Alarm)
    private alarmsRepository: Repository<Alarm>,
    @InjectRepository(Sensor)
    private sensorsRepository: Repository<Sensor>,
  ){}

  async create(createAlarmDto: CreateAlarmDto): Promise<Alarm> {
    //provera da li senzor uopste postoji (ne mogu da "nakacim" alarm ako nema senzora)
    const sensor = await this.sensorsRepository.findOne({
      where: { id: createAlarmDto.sensorId }
    });
    if (!sensor){
      throw new NotFoundException(`Sensor with ID ${createAlarmDto.sensorId} not found. `)
    }

    //provera pragova (da ne bude low > high)
    if (createAlarmDto.lowThreshold >= createAlarmDto.highThreshold){
      throw new BadRequestException('The lower limit (LOW) must be less than the upper limit (HIGH).')
    }

    const alarm = this.alarmsRepository.create({
      ...createAlarmDto, 
      sensor: {id: createAlarmDto.sensorId }
    });

    return await this.alarmsRepository.save(alarm); 
  }

  async findAll(): Promise<Alarm[]> {
    return await this.alarmsRepository.find({ relations: ['sensor'] });
  }

  async findOne(id: number): Promise<Alarm> {
    const alarm = await this.alarmsRepository.findOne({ 
      where: { id }, 
      relations: ['sensor'] 
    });

    if (!alarm) throw new NotFoundException(`Alarm ${id} does not exist.`);
    return alarm; 
  }

  //metoda koju ce measurement da zove da proveri pravila 
  async findBySensor(sensorId: number): Promise<Alarm[]>{
    return await this.alarmsRepository.find({
      where: {sensor: { id: sensorId }},
    });
  }

  async update(id: number, dto: UpdateAlarmDto): Promise<Alarm> {
    const alarm = await this.findOne(id);

    //"probna" verzija alarma sa novim vrednostima
    //koristimo ga da proverimo logiku pre cuvanja u bazi 
    const updatedLow = dto.lowThreshold ?? alarm.lowThreshold;
    const updatedHigh = dto.highThreshold ?? alarm.highThreshold;
    if (updatedLow >= updatedHigh) {
      throw new BadRequestException(`Invalid edit: The lower limit (${updatedLow}) cannot be greater than or equal to the upper limit (${updatedHigh}).`)
    }

    Object.assign(alarm, dto);
    return await this.alarmsRepository.save(alarm);
  }

  async remove(id: number): Promise<{ message: string }>{
    const alarm = await this.findOne(id);
    await this.alarmsRepository.remove(alarm);
    return { message: `Alarm with ID ${id} was successfully deleted.`};
  }
}
