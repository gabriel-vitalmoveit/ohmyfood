import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
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
      include: {
        restaurant: true,
        items: true,
        payment: true,
        chat: { include: { messages: true } },
      },
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

  async listForRestaurant(restaurantId: string, status?: OrderStatus) {
    const where: any = { restaurantId };
    if (status) {
      where.status = status;
    }

    return this.prisma.order.findMany({
      where,
      include: {
        user: {
          select: {
            id: true,
            email: true,
            displayName: true,
            phone: true,
          },
        },
        items: true,
        payment: true,
      },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
  }

  async listAvailableForCourier(courierLat?: number, courierLng?: number, maxDistanceKm = 10) {
    // Pedidos que estão aguardando aceitação do restaurante ou prontos para pickup
    const where: any = {
      status: {
        in: [OrderStatus.AWAITING_ACCEPTANCE, OrderStatus.PREPARING, OrderStatus.PICKUP],
      },
      courierId: null, // Sem courier atribuído
    };

    const orders = await this.prisma.order.findMany({
      where,
      include: {
        restaurant: {
          select: {
            id: true,
            name: true,
            lat: true,
            lng: true,
            imageUrl: true,
          },
        },
        user: {
          select: {
            id: true,
            displayName: true,
            phone: true,
          },
        },
        items: {
          take: 3,
        },
      },
      orderBy: { createdAt: 'asc' },
      take: 50,
    });

    // Se coordenadas do courier foram fornecidas, filtrar por distância
    if (courierLat && courierLng) {
      return orders.filter((order) => {
        const distance = this.calculateDistance(
          courierLat,
          courierLng,
          order.restaurant.lat,
          order.restaurant.lng,
        );
        return distance <= maxDistanceKm;
      });
    }

    return orders;
  }

  private calculateDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
    const R = 6371; // Raio da Terra em km
    const dLat = this.deg2rad(lat2 - lat1);
    const dLng = this.deg2rad(lng2 - lng1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.deg2rad(lat1)) * Math.cos(this.deg2rad(lat2)) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private deg2rad(deg: number): number {
    return deg * (Math.PI / 180);
  }

  async assignCourier(orderId: string, courierId: string) {
    return this.prisma.order.update({
      where: { id: orderId },
      data: {
        courierId,
        status: OrderStatus.PICKUP,
      },
    });
  }

  async updateStatus(orderId: string, status: OrderStatus) {
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) {
      throw new NotFoundException('Pedido não encontrado');
    }

    // Validar transição de estado
    if (!this.isValidTransition(order.status, status)) {
      throw new BadRequestException(
        `Transição inválida: não é possível mudar de ${order.status} para ${status}`,
      );
    }

    // Atualizar histórico
    const statusHistory = (order.statusHistory as any[]) || [];
    statusHistory.push({
      status,
      timestamp: new Date().toISOString(),
    });

    return this.prisma.order.update({
      where: { id: orderId },
      data: {
        status,
        statusHistory,
      },
    });
  }

  private isValidTransition(currentStatus: OrderStatus, newStatus: OrderStatus): boolean {
    // Definir transições válidas
    const validTransitions: Record<OrderStatus, OrderStatus[]> = {
      [OrderStatus.DRAFT]: [OrderStatus.AWAITING_ACCEPTANCE, OrderStatus.CANCELLED],
      [OrderStatus.AWAITING_ACCEPTANCE]: [OrderStatus.PREPARING, OrderStatus.CANCELLED],
      [OrderStatus.PREPARING]: [OrderStatus.PICKUP, OrderStatus.CANCELLED],
      [OrderStatus.PICKUP]: [OrderStatus.ON_THE_WAY, OrderStatus.CANCELLED],
      [OrderStatus.ON_THE_WAY]: [OrderStatus.DELIVERED, OrderStatus.CANCELLED],
      [OrderStatus.DELIVERED]: [], // Estado final
      [OrderStatus.CANCELLED]: [], // Estado final
    };

    return validTransitions[currentStatus]?.includes(newStatus) ?? false;
  }
}
