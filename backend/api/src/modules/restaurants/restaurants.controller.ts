import { Body, Controller, ForbiddenException, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { ApiQuery, ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { Prisma, Role } from '@prisma/client';
import { RestaurantsService } from './restaurants.service';
import { AuthService } from '../auth/auth.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser, CurrentUserPayload } from '../auth/decorators/current-user.decorator';

@ApiTags('restaurants')
@Controller('restaurants')
export class RestaurantsController {
  constructor(
    private readonly restaurantsService: RestaurantsService,
    private readonly authService: AuthService,
  ) {}

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
  @Roles(Role.ADMIN, Role.RESTAURANT)
  @ApiBearerAuth()
  create(@Body() data: Prisma.RestaurantCreateInput, @CurrentUser() user: CurrentUserPayload) {
    // Se user é RESTAURANT, garantir que userId seja preenchido
    const userId = user.role === Role.RESTAURANT ? user.userId : undefined;
    return this.restaurantsService.create(data, userId);
  }

  @Get(':id/stats')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  getStats(@Param('id') id: string, @CurrentUser() user: CurrentUserPayload) {
    // Admin pode ver qualquer restaurant, Restaurant só pode ver o seu
    const userId = user.role === Role.ADMIN ? undefined : user.userId;
    return this.restaurantsService.getStats(id, userId);
  }

  @Get('me/stats')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT)
  @ApiBearerAuth()
  async getMyStats(@CurrentUser() user: CurrentUserPayload) {
    // Buscar restaurantId do user
    const userWithRestaurant = await this.restaurantsService['prisma'].user.findUnique({
      where: { id: user.userId },
      include: { restaurant: { select: { id: true } } },
    });

    if (!userWithRestaurant?.restaurant?.id) {
      throw new ForbiddenException('Utilizador não tem restaurante associado');
    }

    return this.restaurantsService.getStats(userWithRestaurant.restaurant.id, user.userId);
  }

  @Get(':id/orders')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  @ApiQuery({ name: 'status', required: false })
  getOrders(@Param('id') id: string, @Query('status') status?: string, @CurrentUser() user?: CurrentUserPayload) {
    // Admin pode ver qualquer restaurant, Restaurant só pode ver o seu
    const userId = user?.role === Role.ADMIN ? undefined : user?.userId;
    return this.restaurantsService.getOrders(id, status, userId);
  }

  @Get('me/orders')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT)
  @ApiBearerAuth()
  @ApiQuery({ name: 'status', required: false })
  async getMyOrders(@Query('status') status?: string, @CurrentUser() user?: CurrentUserPayload) {
    // Usar auth service para buscar user completo
    const me = await this.authService.getMe(user!.userId);
    if (!me.restaurantId) {
      throw new ForbiddenException('Utilizador não tem restaurante associado');
    }

    return this.restaurantsService.getOrders(me.restaurantId, status, user!.userId);
  }
}
