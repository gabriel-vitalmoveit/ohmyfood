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

  // OptionGroups
  async createOptionGroup(menuItemId: string, data: { name: string; minSelect: number; maxSelect: number }) {
    return this.prisma.optionGroup.create({
      data: {
        ...data,
        menuItem: { connect: { id: menuItemId } },
      },
      include: { options: true },
    });
  }

  async updateOptionGroup(optionGroupId: string, data: { name?: string; minSelect?: number; maxSelect?: number }) {
    return this.prisma.optionGroup.update({
      where: { id: optionGroupId },
      data,
      include: { options: true },
    });
  }

  async deleteOptionGroup(optionGroupId: string) {
    return this.prisma.optionGroup.delete({
      where: { id: optionGroupId },
    });
  }

  // Options
  async createOption(optionGroupId: string, data: { name: string; priceCents: number; available?: boolean }) {
    return this.prisma.option.create({
      data: {
        ...data,
        available: data.available ?? true,
        optionGroup: { connect: { id: optionGroupId } },
      },
    });
  }

  async updateOption(optionId: string, data: { name?: string; priceCents?: number; available?: boolean }) {
    return this.prisma.option.update({
      where: { id: optionId },
      data,
    });
  }

  async deleteOption(optionId: string) {
    return this.prisma.option.delete({
      where: { id: optionId },
    });
  }
}
