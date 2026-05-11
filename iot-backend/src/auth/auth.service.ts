
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { User } from 'src/users/entities/user.entity';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService
  ) {}

  //provera korisnika 
  async validateUser(username: string, pass: string): Promise<Omit<User,'password'> | null> {
    const user = await this.usersService.findByUsername(username);

    if (user && await bcrypt.compare(pass, user.password)) {
      const { password, ...result} = user; 
      return result; 
    }
    return null;
  }

  //generisanje tokena nakon uspesne provere
  async login(username: string, pass: string) {
    const user = await this.validateUser(username, pass);

    if(!user){
        throw new UnauthorizedException('Incorrect username or password');
    }

    const payload = {
        username: user.username,
        sub: user.id, 
        role: user.role
    }; 

    return {
        access_token: this.jwtService.sign(payload),
        user: {
            id: user.id,
            username: user.username,
            email: user.email,
            role: user.role, 
            avatarUrl: user.avatarUrl,
            fullName: user.fullName
        }
    }
  };
};
