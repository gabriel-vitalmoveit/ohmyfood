import { Body, Controller, Delete, Get, Param, Post, Put, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { Prisma, Role } from '@prisma/client';
import { MenuService } from './menu.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';

@ApiTags('menu')
@Controller('restaurants/:restaurantId/menu')
export class MenuController {
  constructor(private readonly menuService: MenuService) {}

  @Get()
  // Menu público - sem auth
  list(@Param('restaurantId') restaurantId: string) {
    return this.menuService.listByRestaurant(restaurantId);
  }

  @Get(':id')
  // Item público - sem auth
  getById(@Param('id') id: string) {
    return this.menuService.getById(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  create(
    @Param('restaurantId') restaurantId: string,
    @Body() data: Prisma.MenuItemCreateWithoutRestaurantInput,
  ) {
    return this.menuService.create(restaurantId, data);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  update(@Param('id') id: string, @Body() data: Prisma.MenuItemUpdateInput) {
    return this.menuService.update(id, data);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  delete(@Param('id') id: string) {
    return this.menuService.delete(id);
  }
}
