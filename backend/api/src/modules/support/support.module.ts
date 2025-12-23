import { Module } from '@nestjs/common';
import { PrismaService } from '../common';
import { AuthModule } from '../auth/auth.module';
import { SupportController } from './support.controller';
import { SupportService } from './support.service';

@Module({
  imports: [AuthModule],
  controllers: [SupportController],
  providers: [SupportService, PrismaService],
  exports: [SupportService],
})
export class SupportModule {}

