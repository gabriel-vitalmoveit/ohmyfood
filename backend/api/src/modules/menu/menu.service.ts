import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../common';

@Injectable()
export class MenuService {
  constructor(private readonly prisma: PrismaService) {}

  listByRestaurant(restaurantId: string) {
    return this.prisma.menuItem.findMany({
      where: { restaurantId, available: true },
      include: { optionGroups: { include: { options: true } } },
      orderBy: { name: 'asc' },
    });
  }

  create(restaurantId: string, data: Prisma.MenuItemCreateWithoutRestaurantInput) {
    return this.prisma.menuItem.create({
      data: {
        ...data,
        restaurant: { connect: { id: restaurantId } },
      },
    });
  }
}
