import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common';

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

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
      include: { restaurant: true, courier: true },
      orderBy: { createdAt: 'desc' },
      take: 20,
    });
  }
}
