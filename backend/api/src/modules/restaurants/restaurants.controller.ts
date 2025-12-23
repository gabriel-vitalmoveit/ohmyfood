import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { ApiQuery, ApiTags } from '@nestjs/swagger';
import { Prisma } from '@prisma/client';
import { RestaurantsService } from './restaurants.service';

@ApiTags('restaurants')
@Controller('restaurants')
export class RestaurantsController {
  constructor(private readonly restaurantsService: RestaurantsService) {}

  @Get()
  @ApiQuery({ name: 'category', required: false })
  @ApiQuery({ name: 'search', required: false })
  @ApiQuery({ name: 'take', required: false, type: Number })
  @ApiQuery({ name: 'skip', required: false, type: Number })
  list(
    @Query('category') category?: string,
    @Query('search') search?: string,
    @Query('take') take?: number,
    @Query('skip') skip?: number,
  ) {
    return this.restaurantsService.list({ category, search, take, skip });
  }

  @Get(':id')
  getById(@Param('id') id: string) {
    return this.restaurantsService.getById(id);
  }

  @Post()
  create(@Body() data: Prisma.RestaurantCreateInput) {
    return this.restaurantsService.create(data);
  }

  @Get(':id/stats')
  getStats(@Param('id') id: string) {
    return this.restaurantsService.getStats(id);
  }

  @Get(':id/orders')
  @ApiQuery({ name: 'status', required: false })
  getOrders(@Param('id') id: string, @Query('status') status?: string) {
    return this.restaurantsService.getOrders(id, status);
  }
}
