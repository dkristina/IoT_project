import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from '@nestjs/common';
import { MeasurementsService } from './measurements.service';
import { CreateMeasurementDto } from './dto/create-measurement.dto';
import { UpdateMeasurementDto } from './dto/update-measurement.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { RolesGuard } from 'src/auth/guards/roles.guard';
import { Roles } from 'src/auth/decorators/roles.decorator';
import { UserRole } from 'src/users/entities/user.entity';

@Controller('measurements')
@UseGuards(JwtAuthGuard, RolesGuard)
export class MeasurementsController {
  constructor(private readonly measurementsService: MeasurementsService) {}

  @Post()
  @Roles(UserRole.ADMIN, UserRole.OPERATOR)
  async create(@Body() createMeasurementDto: CreateMeasurementDto) {
    return await this.measurementsService.create(createMeasurementDto);
  }

  @Get()
  @Roles(UserRole.ADMIN, UserRole.OPERATOR)
  async findAll() {
    return await this.measurementsService.findAll();
  }

  @Get(':id')
  @Roles(UserRole.ADMIN, UserRole.OPERATOR)
  async findOne(@Param('id') id: string) {
    return await this.measurementsService.findOne(+id);
  }

}
