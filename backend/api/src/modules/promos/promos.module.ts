import { Module } from '@nestjs/common';
import { PrismaService } from '../common';
import { PromosController } from './promos.controller';
import { PromosService } from './promos.service';

@Module({
  controllers: [PromosController],
  providers: [PromosService, PrismaService],
  exports: [PromosService],
})
export class PromosModule {}
