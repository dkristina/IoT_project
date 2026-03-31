import { Module } from '@nestjs/common';
import { MeasurementsService } from './measurements.service';
import { MeasurementsController } from './measurements.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Measurement } from './entities/measurement.entity';
import { AlarmsModule } from 'src/alarms/alarms.module';
import { IncidentsModule } from 'src/incidents/incidents.module';
import { IotGateway } from 'src/gateways/iot.gateway';

@Module({
  imports: [
    TypeOrmModule.forFeature([Measurement]),
    AlarmsModule, 
    IncidentsModule,
  ],
  controllers: [MeasurementsController],
  providers: [MeasurementsService, IotGateway],
  exports: [IotGateway],
})
export class MeasurementsModule {}
