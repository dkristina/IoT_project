import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,         // Brise polja koja nisu definisana u DTO-u
    forbidNonWhitelisted: true, // Bacaj gresku ako neko posalje "visak" podataka
    transform: true,         // Automatski pretvara tipove (npr. string u number)
  }));

  
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
