import { Body, Controller, Get, Param, Post } from '@nestjs/common';
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

  @Post()
  create(
    @Param('restaurantId') restaurantId: string,
    @Body() data: Prisma.MenuItemCreateWithoutRestaurantInput,
  ) {
    return this.menuService.create(restaurantId, data);
  }
}
