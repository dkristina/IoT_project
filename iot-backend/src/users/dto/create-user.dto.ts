import { IsEmail, IsEnum, IsNotEmpty, IsOptional, IsString, MinLength } from "class-validator";
import { UserRole } from "../entities/user.entity";


export class CreateUserDto {
    @IsNotEmpty()
    @IsString()
    username: string; 

    @IsNotEmpty()
    @IsString()
    @MinLength(6, { message: 'Password must be at least 6 characters long!'})
    password: string; 

    @IsNotEmpty()
    @IsEmail()
    email: string; 

    @IsNotEmpty()
    @IsString()
    fullName: string; 

    @IsOptional()
    @IsEnum(UserRole)
    role: UserRole; 

}
