import { Module } from '@nestjs/common';
import { AlarmsService } from './alarms.service';
import { AlarmsController } from './alarms.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Alarm } from './entities/alarm.entity';
import { Sensor } from 'src/sensors/entities/sensor.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Alarm, Sensor])],
  controllers: [AlarmsController],
  providers: [AlarmsService],
  exports: [AlarmsService],
})
export class AlarmsModule {}
