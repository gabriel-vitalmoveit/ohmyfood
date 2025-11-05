import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../common';
import { StripeIntegrationService } from '../../integrations/stripe.service';

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
    private readonly stripe: StripeIntegrationService,
  ) {}

  async createIntent(orderId: string, amountCents: number) {
    this.logger.log(`↗️ Criar PaymentIntent para pedido ${orderId} (${amountCents} cêntimos)`);

    await this.stripe.createPaymentIntent({
      amount: amountCents,
      currency: 'eur',
      metadata: { orderId },
      payment_method_types: ['card'],
    });

    return this.prisma.payment.create({
      data: {
        order: { connect: { id: orderId } },
        provider: 'stripe',
        status: 'requires_payment_method',
        amount: amountCents,
      },
    });
  }

  async handleStripeWebhook(payload: Buffer, signature: string | undefined) {
    this.logger.log(`📩 Webhook Stripe recebido (${payload.length} bytes)`);
    const secret = this.configService.get<string>('stripe.webhookSecret');
    if (!secret) {
      this.logger.warn('Stripe webhook secret não configurado');
      return;
    }

    const parsed = JSON.parse(payload.toString('utf8'));
    const orderId = parsed?.data?.object?.metadata?.orderId;
    if (!orderId) {
      this.logger.warn('Webhook Stripe sem orderId na metadata. Guardando raw payload.');
      await this.prisma.payment.create({
        data: {
          provider: 'stripe',
          status: parsed?.type ?? 'unknown',
          amount: parsed?.data?.object?.amount_received ?? 0,
          rawPayload: parsed,
        },
      });
      return;
    }

    await this.prisma.payment.upsert({
      where: { orderId },
      update: {
        status: parsed?.type ?? 'completed',
        providerRef: parsed?.data?.object?.id,
        amount: parsed?.data?.object?.amount_received ?? undefined,
        rawPayload: parsed,
      },
      create: {
        order: { connect: { id: orderId } },
        provider: 'stripe',
        status: parsed?.type ?? 'completed',
        providerRef: parsed?.data?.object?.id,
        amount: parsed?.data?.object?.amount_received ?? 0,
        rawPayload: parsed,
      },
    });

    if (parsed?.type === 'payment_intent.succeeded') {
      await this.prisma.order.update({
        where: { id: orderId },
        data: { status: 'AWAITING_ACCEPTANCE' },
      });
    }
  }
}
