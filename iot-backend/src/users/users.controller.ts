import { Controller, Get, Post, Body, Patch, Param, Delete, ParseIntPipe, Query, UseGuards, Req, ForbiddenException } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { RolesGuard } from 'src/auth/guards/roles.guard';
import { Roles } from 'src/auth/decorators/roles.decorator';
import { UserRole } from './entities/user.entity';

@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @Roles(UserRole.ADMIN) //samo admin sme da pravi nove korisnike
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @Get()
  @Roles(UserRole.ADMIN, UserRole.OPERATOR)
  findAll() {
    return this.usersService.findAll();
  }

  @Get('operators')
  @Roles(UserRole.ADMIN, UserRole.OPERATOR)
  findOperators() {
    return this.usersService.findOperators();
  }

  @Get('search')
  @Roles(UserRole.ADMIN, UserRole.OPERATOR)
  search(@Query('name') name: string) {
    return this.usersService.searchByName(name);
  }
  
  @Get(':id')
  @Roles(UserRole.ADMIN, UserRole.OPERATOR)
  findOne(@Param('id', ParseIntPipe) id: number) {
    return this.usersService.findOne(id);
  }

  @Patch(':id')
  @Roles(UserRole.ADMIN, UserRole.OPERATOR) //Dozvoljeno svima, ali uz proveru unutra
  update(@Param('id', ParseIntPipe) id: number, @Body() updateUserDto: UpdateUserDto, @Req() req: any) {
    const loggedInUser = req.user;

    if (loggedInUser.role !== UserRole.ADMIN && loggedInUser.userId !== id) {
      throw new ForbiddenException('You can only update your own profile!');
    }

    return this.usersService.update(id, updateUserDto, loggedInUser.role);
  }

  @Delete(':id')
  @Roles(UserRole.ADMIN)
  remove(@Param('id', ParseIntPipe) id: number) {
    return this.usersService.remove(id);
  }


}