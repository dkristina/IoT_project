import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Sensor } from './sensors/entities/sensor.entity';
import { MeasurementsService } from './measurements/measurements.service';

@Injectable()
export class SimulatorService implements OnModuleInit {
  private readonly logger = new Logger(SimulatorService.name);

  constructor(
    @InjectRepository(Sensor)
    private readonly sensorsRepository: Repository<Sensor>,
    private readonly measurementsService: MeasurementsService,
  ) {}

  onModuleInit() {
    this.logger.log('🔥 Pure Random IoT Simulator started...');
    this.startSimulation();
  }

  private startSimulation() {
    setInterval(async () => {
      try {
        const sensors = await this.sensorsRepository.find({ relations: ['alarms'] });

        for (const sensor of sensors) {
          const value = this.generateTrulyRandomValue(sensor);

          await this.measurementsService.create({
            sensorId: sensor.id,
            value: value,
            timestamp: new Date().toISOString()
          });
        }
      } catch (error: any) {
        this.logger.error('Simulation error:', error.message);
      }
    }, 5000);
  }

  private generateTrulyRandomValue(sensor: Sensor): number {
    const hasRules = sensor.alarms && sensor.alarms.length > 0;
    const isIncidentTime = Math.random() < 0.20; // 20% šanse da bude problem

    if (hasRules && isIncidentTime) {
      // MOD ZA INCIDENT: Namerno kršimo jedno pravilo
      const rule = sensor.alarms[Math.floor(Math.random() * sensor.alarms.length)];
      const triggerLow = Math.random() < 0.5;

      if (triggerLow && rule.lowThreshold != null) {
        // Vrednost ispod donjeg praga
        return this.getRandom(rule.lowThreshold - 20, rule.lowThreshold - 0.1);
      } else if (rule.highThreshold != null) {
        // Vrednost iznad gornjeg praga
        return this.getRandom(rule.highThreshold + 0.1, rule.highThreshold + 20);
      }
    }

    // NORMALAN MOD (80%): Šaljemo random, ali gledamo da bude unutar granica ako postoje
    if (hasRules) {
      const rule = sensor.alarms[0]; // Uzmemo prvo pravilo kao referencu za "normalno"
      const min = rule.lowThreshold ?? 0;
      const max = rule.highThreshold ?? 100;
      return this.getRandom(min + 0.1, max - 0.1);
    }

    // TOTALNI RANDOM: Ako nema nikakvih pravila u bazi
    return this.getRandom(0, 100);
  }

  private getRandom(min: number, max: number): number {
    const val = Math.random() * (max - min) + min;
    return parseFloat(val.toFixed(2));
  }
}