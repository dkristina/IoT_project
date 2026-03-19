import { IsEnum, IsNotEmpty, IsString } from "class-validator";
import { SensorUnit } from "../entities/sensor.entity";

export class CreateSensorDto {
    
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsNotEmpty()
  location: string;

  @IsEnum(SensorUnit)
  unit: SensorUnit;
}
