import { Module } from '@nestjs/common';
import { JwtModule } from "@nestjs/jwt";
import { PassportModule } from "@nestjs/passport";
import { UsersModule } from "src/users/users.module";
import { jwtConstants } from "./constants";
import { AuthService } from './auth.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { AuthController } from './auth.controller';

@Module({
    imports: [
        UsersModule, 
        PassportModule, 
        JwtModule.register({
            secret: jwtConstants.secret, 
            signOptions: {expiresIn: '1d'}, 
        }),
    ],
    providers: [AuthService, JwtStrategy], 
    controllers: [AuthController], 
    exports: [AuthService], 
})

export class AuthModule{}