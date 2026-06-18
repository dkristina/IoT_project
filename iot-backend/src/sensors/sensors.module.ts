import { Module } from '@nestjs/common';
import { SensorsService } from './sensors.service';
import { SensorsController } from './sensors.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Sensor } from './entities/sensor.entity';
import { Alarm } from 'src/alarms/entities/alarm.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Sensor, Alarm])],
  controllers: [SensorsController],
  providers: [SensorsService],
  exports: [SensorsService, TypeOrmModule]
})
export class SensorsModule {}
