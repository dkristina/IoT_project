import { PartialType } from '@nestjs/mapped-types';
import { CreateIncidentDto } from './create-incident.dto';
import { IsDateString, IsEnum, IsOptional } from 'class-validator';
import { IncidentStatus } from '../entities/incident.entity';

export class UpdateIncidentDto extends PartialType(CreateIncidentDto) {
  
  @IsEnum(IncidentStatus)
  @IsOptional()
  status?: IncidentStatus;

  @IsDateString()
  @IsOptional()
  resolvedAt?: Date;
}
