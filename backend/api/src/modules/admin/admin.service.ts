import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { OrderStatus } from '@prisma/client';
import { PrismaService } from '../common';
import { OrdersService } from '../orders/orders.service';

@Injectable()
export class AdminService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly ordersService: OrdersService,
  ) {}

  dashboardSummary() {
    return Promise.all([
      this.prisma.order.count(),
      this.prisma.user.count(),
      this.prisma.restaurant.count(),
      this.prisma.courier.count(),
    ]).then(([orders, users, restaurants, couriers]) => ({
      orders,
      users,
      restaurants,
      couriers,
    }));
  }

  liveOrders() {
    return this.prisma.order.findMany({
      where: { status: { notIn: ['DELIVERED', 'CANCELLED'] } },
      include: {
        restaurant: { select: { id: true, name: true } },
        courier: { select: { id: true, email: true, displayName: true } },
        user: { select: { id: true, email: true, displayName: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }

  listRestaurants() {
    return this.prisma.restaurant.findMany({
      include: { user: { select: { id: true, email: true } } },
      orderBy: { createdAt: 'desc' },
    });
  }

  async approveRestaurant(id: string) {
    return this.prisma.restaurant.update({
      where: { id },
      data: { active: true },
    });
  }

  async suspendRestaurant(id: string) {
    return this.prisma.restaurant.update({
      where: { id },
      data: { active: false },
    });
  }

  listCouriers() {
    return this.prisma.courier.findMany({
      include: {
        user: { select: { id: true, email: true, displayName: true } },
        location: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async approveCourier(id: string) {
    return this.prisma.courier.update({
      where: { id },
      data: { isVerified: true },
    });
  }

  async suspendCourier(id: string) {
    return this.prisma.courier.update({
      where: { id },
      data: { isVerified: false },
    });
  }

  listOrders() {
    return this.prisma.order.findMany({
      include: {
        restaurant: { select: { id: true, name: true } },
        user: { select: { id: true, email: true, displayName: true } },
        courier: { select: { id: true, email: true, displayName: true } },
      },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
  }

  async cancelOrder(id: string, reason?: string) {
    const order = await this.prisma.order.findUnique({ where: { id } });
    if (!order) {
      throw new NotFoundException('Pedido não encontrado');
    }

    if (order.status === 'DELIVERED' || order.status === 'CANCELLED') {
      throw new BadRequestException('Não é possível cancelar um pedido entregue ou já cancelado');
    }

    return this.ordersService.updateStatus(id, OrderStatus.CANCELLED);
  }

  async reassignCourier(orderId: string, courierId: string) {
    return this.ordersService.assignCourier(orderId, courierId);
  }
}
