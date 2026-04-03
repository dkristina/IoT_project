import { Controller, Get, Post, Body, Patch, Param, Delete, Query, ParseIntPipe, UseGuards } from '@nestjs/common';
import { AlarmsService } from './alarms.service';
import { CreateAlarmDto } from './dto/create-alarm.dto';
import { UpdateAlarmDto } from './dto/update-alarm.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { RolesGuard } from 'src/auth/guards/roles.guard';
import { Roles } from 'src/auth/decorators/roles.decorator';
import { UserRole } from 'src/users/entities/user.entity';

@Controller('alarms')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AlarmsController {
  constructor(private readonly alarmsService: AlarmsService) {}

  @Post()
  @Roles(UserRole.ADMIN)
  async create(@Body() createAlarmDto: CreateAlarmDto) {
    return this.alarmsService.create(createAlarmDto);
  }

  @Get()
  @Roles(UserRole.ADMIN, UserRole.OPERATOR)
  async findAll(@Query('sensorId') sensorId?: string) {
    if (sensorId) return this.alarmsService.findBySensor(+sensorId);
    return this.alarmsService.findAll();
  }

  @Get(':id')
  @Roles(UserRole.ADMIN, UserRole.OPERATOR)
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.alarmsService.findOne(id);
  }

  @Patch(':id')
  @Roles(UserRole.ADMIN)
  async update(@Param('id', ParseIntPipe) id: number, @Body() updateAlarmDto: UpdateAlarmDto) {
    return this.alarmsService.update(id, updateAlarmDto);
  }

  @Delete(':id')
  @Roles(UserRole.ADMIN)
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.alarmsService.remove(id);
  }
}
