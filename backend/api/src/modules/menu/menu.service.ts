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
      include: { optionGroups: { include: { options: true } } },
    });
  }

  update(id: string, data: Prisma.MenuItemUpdateInput) {
    return this.prisma.menuItem.update({
      where: { id },
      data,
      include: { optionGroups: { include: { options: true } } },
    });
  }

  delete(id: string) {
    return this.prisma.menuItem.delete({
      where: { id },
    });
  }

  getById(id: string) {
    return this.prisma.menuItem.findUnique({
      where: { id },
      include: { optionGroups: { include: { options: true } } },
    });
  }
}
