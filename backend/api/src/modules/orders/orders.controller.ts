import { Body, Controller, Get, Param, Post, Put, Query } from '@nestjs/common';
import { ApiQuery, ApiTags } from '@nestjs/swagger';
import { OrderStatus } from '@prisma/client';
import { CreateOrderDto } from './dto/create-order.dto';
import { OrdersService } from './orders.service';

@ApiTags('orders')
@Controller('orders')
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Get('user/:userId')
  listForUser(@Param('userId') userId: string) {
    return this.ordersService.listForUser(userId);
  }

  @Get('restaurant/:restaurantId')
  @ApiQuery({ name: 'status', required: false })
  listForRestaurant(@Param('restaurantId') restaurantId: string, @Query('status') status?: string) {
    return this.ordersService.listForRestaurant(restaurantId, status as OrderStatus);
  }

  @Get('available/courier')
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
  create(@Param('userId') userId: string, @Body() dto: CreateOrderDto) {
    return this.ordersService.create(userId, dto);
  }

  @Put(':id/status')
  updateStatus(@Param('id') id: string, @Body('status') status: OrderStatus) {
    return this.ordersService.updateStatus(id, status);
  }

  @Put(':id/assign-courier')
  assignCourier(@Param('id') id: string, @Body('courierId') courierId: string) {
    return this.ordersService.assignCourier(id, courierId);
  }
}
