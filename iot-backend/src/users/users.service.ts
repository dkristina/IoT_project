import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { User, UserRole } from './entities/user.entity';
import { ILike, Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ){}

  //1.
  async create(createUserDto: CreateUserDto) : Promise<User> {
    const { username, password, email } = createUserDto;

    //Provera duplikata (da ne "pukne" baza ako email vec postoji)
    const existingUser = await this.usersRepository.findOne({
      where: [{ username }, { email }],
    });
    if (existingUser) {
      throw new ConflictException('User with this email or username already exists!');
    }

    //Hesiranje lozinke
    const salt = await bcrypt.genSalt(); 
    const hashedPassword = await bcrypt.hash(password, salt);

    const newUser = this.usersRepository.create({
      ...createUserDto,
      password: hashedPassword,
    });

    const savedUser = await this.usersRepository.save(newUser);
    //izvuci password, a sve ostalo stavi u result
    //nazovi password _ da ne pravi problem 
    const {password: _, ...result} = savedUser; 

    return result as User; 
  }
  
  //2.
  async findAll(): Promise<User[]> {
    return await this.usersRepository.find(); 
  }

  //3.
  async findOperators(): Promise<User[]> {
    return await this.usersRepository.find({
      where: { role: UserRole.OPERATOR}
    });
  }  

  //4.
  //Pretraga po imenu (ILike- nebitna mala/velika slova)
  async searchByName(name: string): Promise<User[]> {
    return await this.usersRepository.find({
      where: { fullName: ILike(`%${name}%`) }
    });
  }

  //5.
  async findOne(id: number): Promise<User> {
    const user = await this.usersRepository.findOne({where: { id }}); 
    if(!user){
      throw new NotFoundException(`User with ID ${id} not found.`); 
    }
    return user; 
  }

  //6.
  //metoda za login
  //posto je password na "select:false", moramo ga eksplicitno traziti 
  async findByUsername(username: string): Promise<User | null> {
    return await this.usersRepository.createQueryBuilder('user')
      .addSelect('user.password')
      .where('user.username = :username', { username })
      .getOne(); 
  }

  //7.
  async update(id: number, updateUserDto: UpdateUserDto, requesterRole: UserRole): Promise <User> {
    const user = await this.findOne(id); 

    if (requesterRole !== UserRole.ADMIN && updateUserDto.role) {
      delete updateUserDto.role; 
  }
    //provera jedinstvenosti
    if (updateUserDto.email || updateUserDto.username) {
      const existing = await this.usersRepository.findOne({
        where: [
          { email: updateUserDto.email },
          { username: updateUserDto.username }
        ]
      });

      if (existing && existing.id !== id) {
        throw new ConflictException('Email or username already in use by another user');
      }
    }

    //Ako se menja lozinka, moramo i nju da hesiramo
    if (updateUserDto.password) {
      const salt = await bcrypt.genSalt();
      updateUserDto.password = await bcrypt.hash(updateUserDto.password, salt);
    }

    Object.assign(user, updateUserDto); 
    const updatedUser = await this.usersRepository.save(user);
    const { password: _, ...result } = updatedUser;
    return result as User;
  }

  //8.
  async remove(id: number): Promise<{message: string}> {
    const user = await this.findOne(id); 
    await this.usersRepository.remove(user); 
    return { message: `User ${user.username} was successfully deleted.`}
  }

 
}
