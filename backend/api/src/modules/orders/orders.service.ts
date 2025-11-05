import { Injectable, NotFoundException } from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { PrismaService } from '../common';
import { PaymentsService } from '../payments/payments.service';
import { CreateOrderDto } from './dto/create-order.dto';

@Injectable()
export class OrdersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly paymentsService: PaymentsService,
  ) {}

  async listForUser(userId: string) {
    return this.prisma.order.findMany({
      where: { userId },
      include: { restaurant: true, items: true, payment: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getById(id: string) {
    const order = await this.prisma.order.findUnique({
      where: { id },
      include: { restaurant: true, items: true, payment: true, chat: { include: { messages: true } } },
    });
    if (!order) {
      throw new NotFoundException('Pedido não encontrado');
    }
    return order;
  }

  async create(userId: string, dto: CreateOrderDto) {
    const menuItems = await this.prisma.menuItem.findMany({
      where: { id: { in: dto.items.map((item) => item.menuItemId) } },
    });

    const order = await this.prisma.order.create({
      data: {
        user: { connect: { id: userId } },
        restaurant: { connect: { id: dto.restaurantId } },
        status: OrderStatus.DRAFT,
        itemsTotal: dto.itemsTotalCents,
        deliveryFee: dto.deliveryFeeCents,
        serviceFee: dto.serviceFeeCents,
        total: dto.itemsTotalCents + dto.deliveryFeeCents + dto.serviceFeeCents,
        items: {
          create: dto.items.map((item) => {
            const menuItem = menuItems.find((mi) => mi.id === item.menuItemId);
            return {
              menuItem: { connect: { id: item.menuItemId } },
              name: menuItem?.name ?? 'Item',
              quantity: item.quantity,
              unitPrice: menuItem?.priceCents ?? 0,
              addons: item.addons,
            };
          }),
        },
      },
    });

    await this.paymentsService.createIntent(order.id, order.total);

    return order;
  }

  async markAwaitingAcceptance(orderId: string) {
    return this.prisma.order.update({
      where: { id: orderId },
      data: { status: OrderStatus.AWAITING_ACCEPTANCE },
    });
  }
}
