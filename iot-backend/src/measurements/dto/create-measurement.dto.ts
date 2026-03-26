import { IsDateString, IsNotEmpty, IsNumber, IsOptional } from "class-validator";

export class CreateMeasurementDto {
  @IsNumber()
  @IsNotEmpty()
  value: number;

  @IsNumber()
  @IsNotEmpty()
  sensorId: number;
  
  @IsDateString()
  @IsOptional()
  timestamp?: string;

}
