import { Body, Controller, Delete, Get, Param, Post, Put } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { Prisma } from '@prisma/client';
import { MenuService } from './menu.service';

@ApiTags('menu')
@Controller('restaurants/:restaurantId/menu')
export class MenuController {
  constructor(private readonly menuService: MenuService) {}

  @Get()
  list(@Param('restaurantId') restaurantId: string) {
    return this.menuService.listByRestaurant(restaurantId);
  }

  @Get(':id')
  getById(@Param('id') id: string) {
    return this.menuService.getById(id);
  }

  @Post()
  create(
    @Param('restaurantId') restaurantId: string,
    @Body() data: Prisma.MenuItemCreateWithoutRestaurantInput,
  ) {
    return this.menuService.create(restaurantId, data);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() data: Prisma.MenuItemUpdateInput) {
    return this.menuService.update(id, data);
  }

  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.menuService.delete(id);
  }
}
