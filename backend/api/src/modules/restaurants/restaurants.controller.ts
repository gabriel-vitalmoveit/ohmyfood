import { Body, Controller, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { ApiQuery, ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { Prisma, Role } from '@prisma/client';
import { RestaurantsService } from './restaurants.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';

@ApiTags('restaurants')
@Controller('restaurants')
export class RestaurantsController {
  constructor(private readonly restaurantsService: RestaurantsService) {}

  @Get()
  // Lista pública - sem auth
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
  // Detalhe público - sem auth
  getById(@Param('id') id: string) {
    return this.restaurantsService.getById(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  create(@Body() data: Prisma.RestaurantCreateInput) {
    return this.restaurantsService.create(data);
  }

  @Get(':id/stats')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  getStats(@Param('id') id: string) {
    return this.restaurantsService.getStats(id);
  }

  @Get(':id/orders')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  @ApiQuery({ name: 'status', required: false })
  getOrders(@Param('id') id: string, @Query('status') status?: string) {
    return this.restaurantsService.getOrders(id, status);
  }
}
