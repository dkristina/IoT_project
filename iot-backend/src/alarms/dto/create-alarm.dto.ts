import { IsEnum, IsNotEmpty, IsNumber } from "class-validator";
import { AlarmSeverity } from "../entities/alarm.entity";

export class CreateAlarmDto {
  @IsNumber()
  @IsNotEmpty()
  lowThreshold: number;

  @IsNumber()
  @IsNotEmpty()
  highThreshold: number;

  @IsEnum(AlarmSeverity)
  @IsNotEmpty()
  severity: AlarmSeverity;

  @IsNumber()
  @IsNotEmpty()
  sensorId: number;
}
