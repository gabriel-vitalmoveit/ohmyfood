import { Injectable } from '@nestjs/common';
import { Prisma, Restaurant } from '@prisma/client';
import { PrismaService } from '../common';

@Injectable()
export class RestaurantsService {
  constructor(private readonly prisma: PrismaService) {}

  list(params?: { take?: number; skip?: number; category?: string }) {
    const where: Prisma.RestaurantWhereInput = {
      active: true,
      ...(params?.category ? { categories: { has: params.category } } : {}),
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

  create(data: Prisma.RestaurantCreateInput): Promise<Restaurant> {
    return this.prisma.restaurant.create({ data });
  }
}
