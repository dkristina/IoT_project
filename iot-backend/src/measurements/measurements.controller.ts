import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { MeasurementsService } from './measurements.service';
import { CreateMeasurementDto } from './dto/create-measurement.dto';
import { UpdateMeasurementDto } from './dto/update-measurement.dto';

@Controller('measurements')
export class MeasurementsController {
  constructor(private readonly measurementsService: MeasurementsService) {}

  @Post()
  async create(@Body() createMeasurementDto: CreateMeasurementDto) {
    return await this.measurementsService.create(createMeasurementDto);
  }

  @Get()
  async findAll() {
    return await this.measurementsService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return await this.measurementsService.findOne(+id);
  }

}
