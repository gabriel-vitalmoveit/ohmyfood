import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../common';

@Injectable()
export class MenuService {
  constructor(private readonly prisma: PrismaService) {}

  async validateRestaurantOwnership(restaurantId: string, userId: string): Promise<void> {
    const restaurant = await this.prisma.restaurant.findUnique({
      where: { id: restaurantId },
      select: { userId: true },
    });

    if (!restaurant) {
      throw new NotFoundException('Restaurante não encontrado');
    }

    if (restaurant.userId !== userId) {
      throw new ForbiddenException('Acesso negado: este restaurante não pertence ao utilizador autenticado');
    }
  }

  async validateMenuItemOwnership(menuItemId: string, userId: string): Promise<string> {
    const menuItem = await this.prisma.menuItem.findUnique({
      where: { id: menuItemId },
      include: { restaurant: { select: { userId: true } } },
    });

    if (!menuItem) {
      throw new NotFoundException('Item de menu não encontrado');
    }

    if (menuItem.restaurant.userId !== userId) {
      throw new ForbiddenException('Acesso negado: este item não pertence ao restaurante do utilizador');
    }

    return menuItem.restaurantId;
  }

  listByRestaurant(restaurantId: string) {
    return this.prisma.menuItem.findMany({
      where: { restaurantId, available: true },
      include: { optionGroups: { include: { options: true } } },
      orderBy: { name: 'asc' },
    });
  }

  async create(restaurantId: string, data: Prisma.MenuItemCreateWithoutRestaurantInput, userId?: string) {
    // Validar ownership se userId fornecido
    if (userId) {
      await this.validateRestaurantOwnership(restaurantId, userId);
    }

    return this.prisma.menuItem.create({
      data: {
        ...data,
        restaurant: { connect: { id: restaurantId } },
      },
      include: { optionGroups: { include: { options: true } } },
    });
  }

  async update(id: string, data: Prisma.MenuItemUpdateInput, userId?: string) {
    // Validar ownership se userId fornecido
    if (userId) {
      await this.validateMenuItemOwnership(id, userId);
    }

    return this.prisma.menuItem.update({
      where: { id },
      data,
      include: { optionGroups: { include: { options: true } } },
    });
  }

  async delete(id: string, userId?: string) {
    // Validar ownership se userId fornecido
    if (userId) {
      await this.validateMenuItemOwnership(id, userId);
    }

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
  async createOptionGroup(menuItemId: string, data: { name: string; minSelect: number; maxSelect: number }, userId?: string) {
    // Validar ownership se userId fornecido
    if (userId) {
      await this.validateMenuItemOwnership(menuItemId, userId);
    }

    return this.prisma.optionGroup.create({
      data: {
        ...data,
        menuItem: { connect: { id: menuItemId } },
      },
      include: { options: true },
    });
  }

  async updateOptionGroup(optionGroupId: string, data: { name?: string; minSelect?: number; maxSelect?: number }, userId?: string) {
    // Validar ownership se userId fornecido
    if (userId) {
      const optionGroup = await this.prisma.optionGroup.findUnique({
        where: { id: optionGroupId },
        include: { menuItem: { include: { restaurant: { select: { userId: true } } } } },
      });

      if (!optionGroup) {
        throw new NotFoundException('Grupo de opções não encontrado');
      }

      if (optionGroup.menuItem.restaurant.userId !== userId) {
        throw new ForbiddenException('Acesso negado');
      }
    }

    return this.prisma.optionGroup.update({
      where: { id: optionGroupId },
      data,
      include: { options: true },
    });
  }

  async deleteOptionGroup(optionGroupId: string, userId?: string) {
    // Validar ownership se userId fornecido
    if (userId) {
      const optionGroup = await this.prisma.optionGroup.findUnique({
        where: { id: optionGroupId },
        include: { menuItem: { include: { restaurant: { select: { userId: true } } } } },
      });

      if (!optionGroup) {
        throw new NotFoundException('Grupo de opções não encontrado');
      }

      if (optionGroup.menuItem.restaurant.userId !== userId) {
        throw new ForbiddenException('Acesso negado');
      }
    }

    return this.prisma.optionGroup.delete({
      where: { id: optionGroupId },
    });
  }

  // Options
  async createOption(optionGroupId: string, data: { name: string; priceCents: number; available?: boolean }, userId?: string) {
    // Validar ownership se userId fornecido
    if (userId) {
      const optionGroup = await this.prisma.optionGroup.findUnique({
        where: { id: optionGroupId },
        include: { menuItem: { include: { restaurant: { select: { userId: true } } } } },
      });

      if (!optionGroup) {
        throw new NotFoundException('Grupo de opções não encontrado');
      }

      if (optionGroup.menuItem.restaurant.userId !== userId) {
        throw new ForbiddenException('Acesso negado');
      }
    }

    return this.prisma.option.create({
      data: {
        ...data,
        available: data.available ?? true,
        optionGroup: { connect: { id: optionGroupId } },
      },
    });
  }

  async updateOption(optionId: string, data: { name?: string; priceCents?: number; available?: boolean }, userId?: string) {
    // Validar ownership se userId fornecido
    if (userId) {
      const option = await this.prisma.option.findUnique({
        where: { id: optionId },
        include: { optionGroup: { include: { menuItem: { include: { restaurant: { select: { userId: true } } } } } } },
      });

      if (!option) {
        throw new NotFoundException('Opção não encontrada');
      }

      if (option.optionGroup.menuItem.restaurant.userId !== userId) {
        throw new ForbiddenException('Acesso negado');
      }
    }

    return this.prisma.option.update({
      where: { id: optionId },
      data,
    });
  }

  async deleteOption(optionId: string, userId?: string) {
    // Validar ownership se userId fornecido
    if (userId) {
      const option = await this.prisma.option.findUnique({
        where: { id: optionId },
        include: { optionGroup: { include: { menuItem: { include: { restaurant: { select: { userId: true } } } } } } },
      });

      if (!option) {
        throw new NotFoundException('Opção não encontrada');
      }

      if (option.optionGroup.menuItem.restaurant.userId !== userId) {
        throw new ForbiddenException('Acesso negado');
      }
    }

    return this.prisma.option.delete({
      where: { id: optionId },
    });
  }
}
