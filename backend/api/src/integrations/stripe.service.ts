import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Stripe from 'stripe';

@Injectable()
export class StripeIntegrationService {
  private readonly logger = new Logger(StripeIntegrationService.name);
  private readonly client: Stripe;

  constructor(configService: ConfigService) {
    const apiKey = configService.get<string>('stripe.apiKey');
    this.client = new Stripe(apiKey ?? '', {
      apiVersion: '2023-10-16',
    });
  }

  async createPaymentIntent(params: Stripe.PaymentIntentCreateParams) {
    this.logger.debug(`Criar PaymentIntent com ${params.amount} cêntimos`);
    return this.client.paymentIntents.create(params);
  }
}
