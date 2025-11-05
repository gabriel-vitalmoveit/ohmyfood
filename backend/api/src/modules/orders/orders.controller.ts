import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
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

  @Get(':id')
  getById(@Param('id') id: string) {
    return this.ordersService.getById(id);
  }

  @Post('user/:userId')
  create(@Param('userId') userId: string, @Body() dto: CreateOrderDto) {
    return this.ordersService.create(userId, dto);
  }
}
