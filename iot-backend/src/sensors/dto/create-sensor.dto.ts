import { IsArray, IsEnum, IsNotEmpty, IsNumber, IsString, ValidateNested } from "class-validator";
import { SensorUnit } from "../entities/sensor.entity";
import { AlarmSeverity } from "src/alarms/entities/alarm.entity";
import { Transform, Type } from "class-transformer";

class SensorAlarmDto {
  @Transform(({ value }) => Number(value))
  @IsNumber()
  lowThreshold: number;

  @Transform(({ value }) => Number(value))
  @IsNumber()
  highThreshold: number;

  @IsEnum(AlarmSeverity)
  severity: AlarmSeverity;
}

export class CreateSensorDto {
    
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsNotEmpty()
  location: string;

  @IsEnum(SensorUnit)
  unit: SensorUnit;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SensorAlarmDto)
  alarms: SensorAlarmDto[];
}
