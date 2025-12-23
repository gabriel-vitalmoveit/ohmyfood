import { Body, Controller, ForbiddenException, Get, Param, Post, Put, Query, UseGuards } from '@nestjs/common';
import { ApiQuery, ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { OrderStatus, Role } from '@prisma/client';
import { CreateOrderDto } from './dto/create-order.dto';
import { OrdersService } from './orders.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser, CurrentUserPayload } from '../auth/decorators/current-user.decorator';

@ApiTags('orders')
@Controller('orders')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Get('user/:userId')
  @Roles(Role.CUSTOMER, Role.ADMIN)
  @UseGuards(RolesGuard)
  listForUser(@Param('userId') userId: string, @CurrentUser() user: CurrentUserPayload) {
    // Cliente só pode ver seus próprios pedidos (exceto admin)
    if (user.role !== Role.ADMIN && user.userId !== userId) {
      throw new ForbiddenException('Acesso negado');
    }
    return this.ordersService.listForUser(userId);
  }

  @Get('restaurant/:restaurantId')
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @UseGuards(RolesGuard)
  @ApiQuery({ name: 'status', required: false })
  listForRestaurant(
    @Param('restaurantId') restaurantId: string,
    @Query('status') status?: string,
    @CurrentUser() user?: CurrentUserPayload,
  ) {
    // Restaurant só pode ver seus próprios pedidos (exceto admin)
    // TODO: Validar se user.restaurantId === restaurantId
    return this.ordersService.listForRestaurant(restaurantId, status as OrderStatus);
  }

  @Get('available/courier')
  @Roles(Role.COURIER, Role.ADMIN)
  @UseGuards(RolesGuard)
  @ApiQuery({ name: 'lat', required: false, type: Number })
  @ApiQuery({ name: 'lng', required: false, type: Number })
  @ApiQuery({ name: 'maxDistance', required: false, type: Number })
  listAvailableForCourier(
    @Query('lat') lat?: number,
    @Query('lng') lng?: number,
    @Query('maxDistance') maxDistance?: number,
  ) {
    return this.ordersService.listAvailableForCourier(
      lat ? Number(lat) : undefined,
      lng ? Number(lng) : undefined,
      maxDistance ? Number(maxDistance) : 10,
    );
  }

  @Get(':id')
  getById(@Param('id') id: string) {
    return this.ordersService.getById(id);
  }

  @Post('user/:userId')
  @Roles(Role.CUSTOMER, Role.ADMIN)
  @UseGuards(RolesGuard)
  create(@Param('userId') userId: string, @Body() dto: CreateOrderDto, @CurrentUser() user: CurrentUserPayload) {
    // Cliente só pode criar pedidos para si mesmo (exceto admin)
    if (user.role !== Role.ADMIN && user.userId !== userId) {
      throw new ForbiddenException('Acesso negado');
    }
    return this.ordersService.create(userId, dto);
  }

  @Put(':id/status')
  @Roles(Role.RESTAURANT, Role.COURIER, Role.ADMIN)
  @UseGuards(RolesGuard)
  updateStatus(@Param('id') id: string, @Body('status') status: OrderStatus) {
    return this.ordersService.updateStatus(id, status);
  }

  @Put(':id/assign-courier')
  @Roles(Role.COURIER, Role.ADMIN)
  @UseGuards(RolesGuard)
  assignCourier(@Param('id') id: string, @Body('courierId') courierId: string, @CurrentUser() user: CurrentUserPayload) {
    // Courier só pode atribuir a si mesmo (exceto admin)
    if (user.role !== Role.ADMIN && user.userId !== courierId) {
      throw new ForbiddenException('Acesso negado');
    }
    return this.ordersService.assignCourier(id, courierId);
  }
}
