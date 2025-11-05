import { Controller, Headers, Post, Req } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { PaymentsService } from './payments.service';

@ApiTags('payments')
@Controller('payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post('stripe/webhook')
  async handleStripeWebhook(
    @Req() request: Request,
    @Headers('stripe-signature') signature?: string,
  ) {
    const body = request.body as Buffer;
    await this.paymentsService.handleStripeWebhook(body, signature);
    return { received: true };
  }
}
