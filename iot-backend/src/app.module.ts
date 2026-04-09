import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersModule } from './users/users.module';
import { AlarmsModule } from './alarms/alarms.module';
import { SensorsModule } from './sensors/sensors.module';
import { MeasurementsModule } from './measurements/measurements.module';
import { IncidentsModule } from './incidents/incidents.module';
import { User } from './users/entities/user.entity';
import { Sensor } from './sensors/entities/sensor.entity';
import { Alarm } from './alarms/entities/alarm.entity';
import { Measurement } from './measurements/entities/measurement.entity';
import { Incident } from './incidents/entities/incident.entity';
import { AuthModule } from './auth/auth.module';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres', 
      host: 'localhost', 
      port: 5432, 
      username: 'kristina', 
      password: 'kristina96', 
      database: 'iot_system', 
      entities: [User, Sensor, Alarm, Measurement, Incident], 
      synchronize: true,

    }),
    UsersModule,
    AuthModule,
    AlarmsModule,
    SensorsModule,
    MeasurementsModule,
    IncidentsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
