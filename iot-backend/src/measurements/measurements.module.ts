import { Module } from '@nestjs/common';
import { MeasurementsService } from './measurements.service';
import { MeasurementsController } from './measurements.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Measurement } from './entities/measurement.entity';
import { AlarmsModule } from 'src/alarms/alarms.module';
import { IncidentsModule } from 'src/incidents/incidents.module';
import { IotGateway } from 'src/gateways/iot.gateway';
import { GatewaysModule } from 'src/gateways/gateways.module';
import { SensorsModule } from 'src/sensors/sensors.module';
import { SimulatorService } from 'src/simulator.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([Measurement]),
    AlarmsModule, 
    IncidentsModule, 
    SensorsModule,
    GatewaysModule,
  ],
  controllers: [MeasurementsController],
  providers: [MeasurementsService /*, SimulatorService*/],
  exports: [MeasurementsService],
})
export class MeasurementsModule {}
