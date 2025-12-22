import { Logger, ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import * as bodyParser from 'body-parser';
import { AppModule } from './modules/app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  const corsConfig = configService.get('cors');
  app.enableCors({
    origin: corsConfig?.allowedOrigins || corsConfig?.origin || '*',
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  app.use('/payments/stripe/webhook', bodyParser.raw({ type: 'application/json' }));

  const swaggerConfig = new DocumentBuilder()
    .setTitle('OhMyFood API')
    .setDescription('MVP API para plataforma de entregas OhMyFood')
    .setVersion('0.1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('docs', app, document);

  const port = configService.get<number>('PORT', 3000);
  await app.listen(port);
  Logger.log(`🚀 OhMyFood API pronta em http://localhost:${port}`, 'Bootstrap');
}

bootstrap();
