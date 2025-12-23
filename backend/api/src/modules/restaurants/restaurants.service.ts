import { ForbiddenException, Injectable } from '@nestjs/common';
import { Prisma, Restaurant } from '@prisma/client';
import { PrismaService } from '../common';

@Injectable()
export class RestaurantsService {
  constructor(private readonly prisma: PrismaService) {}

  list(params?: { take?: number; skip?: number; category?: string; search?: string }) {
    const where: Prisma.RestaurantWhereInput = {
      active: true,
      ...(params?.category ? { categories: { has: params.category } } : {}),
      ...(params?.search
        ? {
            OR: [
              { name: { contains: params.search, mode: 'insensitive' } },
              { description: { contains: params.search, mode: 'insensitive' } },
              { categories: { has: params.search } },
            ],
          }
        : {}),
    };

    return this.prisma.restaurant.findMany({
      take: params?.take ?? 50,
      skip: params?.skip ?? 0,
      where,
      include: {
        menuItems: {
          where: { available: true },
          take: 10,
        },
      },
      orderBy: { name: 'asc' },
    });
  }

  getById(id: string) {
    return this.prisma.restaurant.findUnique({
      where: { id },
      include: { menuItems: { include: { optionGroups: { include: { options: true } } } } },
    });
  }

  async create(data: Prisma.RestaurantCreateInput, userId?: string): Promise<Restaurant> {
    // Se userId fornecido, garantir que restaurant.userId seja preenchido
    if (userId) {
      data.user = { connect: { id: userId } };
    }
    return this.prisma.restaurant.create({ data });
  }

  async validateRestaurantOwnership(restaurantId: string, userId: string): Promise<void> {
    const restaurant = await this.prisma.restaurant.findUnique({
      where: { id: restaurantId },
      select: { userId: true },
    });

    if (!restaurant) {
      throw new ForbiddenException('Restaurante não encontrado');
    }

    if (restaurant.userId !== userId) {
      throw new ForbiddenException('Acesso negado: este restaurante não pertence ao utilizador autenticado');
    }
  }

  async getStats(restaurantId: string, userId?: string) {
    // Se userId fornecido, validar ownership
    if (userId) {
      await this.validateRestaurantOwnership(restaurantId, userId);
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    // Pedidos entregues hoje
    const deliveredToday = await this.prisma.order.findMany({
      where: {
        restaurantId,
        status: 'DELIVERED',
        createdAt: {
          gte: today,
          lt: tomorrow,
        },
      },
      include: {
        items: true,
      },
    });

    // Pedidos cancelados hoje
    const cancelledToday = await this.prisma.order.count({
      where: {
        restaurantId,
        status: 'CANCELLED',
        createdAt: {
          gte: today,
          lt: tomorrow,
        },
      },
    });

    // Calcular tempo médio de preparação
    const prepTimes: number[] = [];
    deliveredToday.forEach((order) => {
      if (order.statusHistory && typeof order.statusHistory === 'object') {
        const history = order.statusHistory as any;
        if (history.preparingAt && history.pickupAt) {
          const prepTime = new Date(history.pickupAt).getTime() - new Date(history.preparingAt).getTime();
          prepTimes.push(prepTime / 1000 / 60); // minutos
        }
      }
    });
    const avgPrepMin = prepTimes.length > 0
      ? Math.round(prepTimes.reduce((a, b) => a + b, 0) / prepTimes.length)
      : 15;

    // Ticket médio
    const avgTicket = deliveredToday.length > 0
      ? Math.round(deliveredToday.reduce((sum, order) => sum + order.total, 0) / deliveredToday.length)
      : 0;

    // Itens mais vendidos hoje
    const itemCounts = new Map<string, { name: string; count: number }>();
    deliveredToday.forEach((order) => {
      order.items.forEach((item) => {
        const current = itemCounts.get(item.menuItemId) || { name: item.name, count: 0 };
        itemCounts.set(item.menuItemId, { name: item.name, count: current.count + item.quantity });
      });
    });
    const topItems = Array.from(itemCounts.values())
      .sort((a, b) => b.count - a.count)
      .slice(0, 5);

    // Pedidos por hora (últimas 12 horas)
    const hourlyOrders = new Array(12).fill(0);
    const now = new Date();
    deliveredToday.forEach((order) => {
      const hourDiff = Math.floor((now.getTime() - order.createdAt.getTime()) / (1000 * 60 * 60));
      if (hourDiff >= 0 && hourDiff < 12) {
        hourlyOrders[11 - hourDiff]++;
      }
    });

    return {
      ordersToday: deliveredToday.length,
      cancelledToday,
      avgPrepMin,
      avgTicket,
      revenueToday: deliveredToday.reduce((sum, order) => sum + order.total, 0),
      topItems,
      hourlyOrders,
    };
  }

  async getOrders(restaurantId: string, status?: string, userId?: string) {
    // Se userId fornecido, validar ownership
    if (userId) {
      await this.validateRestaurantOwnership(restaurantId, userId);
    }

    const where: Prisma.OrderWhereInput = {
      restaurantId,
      ...(status ? { status: status as any } : {}),
    };

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
        courier: {
          select: {
            id: true,
            displayName: true,
            phone: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }
}
