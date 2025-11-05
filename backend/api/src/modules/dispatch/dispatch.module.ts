import { Module } from '@nestjs/common';
import { PrismaService } from '../common';
import { DispatchService } from './dispatch.service';

@Module({
  providers: [DispatchService, PrismaService],
  exports: [DispatchService],
})
export class DispatchModule {}
