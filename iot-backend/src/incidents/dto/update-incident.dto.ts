import { IsDateString, IsEnum, IsOptional, IsString, IsNumber, ValidateIf } from 'class-validator';
import { IncidentStatus } from '../entities/incident.entity';
import { AlarmSeverity } from 'src/alarms/entities/alarm.entity';

export class UpdateIncidentDto {
  @IsString()
  @IsOptional()
  description?: string;

  @IsEnum(AlarmSeverity)
  @IsOptional()
  severity?: AlarmSeverity;

  @IsEnum(IncidentStatus)
  @IsOptional()
  status?: IncidentStatus;

  @IsNumber()
  @IsOptional()
  sensorId?: number;

  // 🚀 KONAČNO REŠENJE: Potpuno nezavisno polje koje dozvoljava i broj i null!
  @ValidateIf((obj, value) => value !== null)
  @IsNumber()
  @IsOptional()
  assignedToId?: number | null;

  @IsDateString()
  @IsOptional()
  resolvedAt?: Date;

  @IsString()
  @IsOptional()
  historyLogs?: string;
}