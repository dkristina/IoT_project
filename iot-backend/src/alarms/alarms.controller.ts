import { Controller, Get, Post, Body, Patch, Param, Delete, Query, ParseIntPipe } from '@nestjs/common';
import { AlarmsService } from './alarms.service';
import { CreateAlarmDto } from './dto/create-alarm.dto';
import { UpdateAlarmDto } from './dto/update-alarm.dto';

@Controller('alarms')
export class AlarmsController {
  constructor(private readonly alarmsService: AlarmsService) {}

  @Post()
  async create(@Body() createAlarmDto: CreateAlarmDto) {
    return this.alarmsService.create(createAlarmDto);
  }

  @Get()
  async findAll(@Query('sensorId') sensorId?: string) {
    if (sensorId) return this.alarmsService.findBySensor(+sensorId);
    return this.alarmsService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.alarmsService.findOne(id);
  }

  @Patch(':id')
  async update(@Param('id', ParseIntPipe) id: number, @Body() updateAlarmDto: UpdateAlarmDto) {
    return this.alarmsService.update(id, updateAlarmDto);
  }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.alarmsService.remove(id);
  }
}
