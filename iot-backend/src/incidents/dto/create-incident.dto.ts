import { IsEnum, IsNotEmpty, IsNumber, IsOptional, IsString } from "class-validator";
import { AlarmSeverity } from "src/alarms/entities/alarm.entity";
import { IncidentStatus } from "../entities/incident.entity";

export class CreateIncidentDto {

  @IsString()
  @IsNotEmpty()
  description: string;

  @IsEnum(AlarmSeverity)
  @IsNotEmpty()
  severity: AlarmSeverity;

  @IsEnum(IncidentStatus)
  @IsOptional()
  status?: IncidentStatus;

  @IsNumber()
  @IsNotEmpty()
  sensorId: number;

  //opciono, ako odmah znamo ko resava
  @IsNumber()
  @IsOptional()
  assignedToId?: number;
}
