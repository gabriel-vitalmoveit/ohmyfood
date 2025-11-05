import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaService } from '../common';
import { StripeIntegrationService } from '../../integrations/stripe.service';
import { PaymentsController } from './payments.controller';
import { PaymentsService } from './payments.service';

@Module({
  imports: [ConfigModule],
  controllers: [PaymentsController],
  providers: [PaymentsService, PrismaService, StripeIntegrationService],
  exports: [PaymentsService],
})
export class PaymentsModule {}
