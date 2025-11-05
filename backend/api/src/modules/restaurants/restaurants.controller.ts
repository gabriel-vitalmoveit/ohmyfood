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
  list(@Query('category') category?: string) {
    return this.restaurantsService.list({ category });
  }

  @Get(':id')
  getById(@Param('id') id: string) {
    return this.restaurantsService.getById(id);
  }

  @Post()
  create(@Body() data: Prisma.RestaurantCreateInput) {
    return this.restaurantsService.create(data);
  }
}
