import { Body, Controller, Get, Param, Put, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { AdminService } from './admin.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';

@ApiTags('admin')
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN)
@ApiBearerAuth()
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('summary')
  summary() {
    return this.adminService.dashboardSummary();
  }

  @Get('live-orders')
  liveOrders() {
    return this.adminService.liveOrders();
  }

  @Get('restaurants')
  listRestaurants() {
    return this.adminService.listRestaurants();
  }

  @Put('restaurants/:id/approve')
  approveRestaurant(@Param('id') id: string) {
    return this.adminService.approveRestaurant(id);
  }

  @Put('restaurants/:id/suspend')
  suspendRestaurant(@Param('id') id: string) {
    return this.adminService.suspendRestaurant(id);
  }

  @Get('couriers')
  listCouriers() {
    return this.adminService.listCouriers();
  }

  @Put('couriers/:id/approve')
  approveCourier(@Param('id') id: string) {
    return this.adminService.approveCourier(id);
  }

  @Put('couriers/:id/suspend')
  suspendCourier(@Param('id') id: string) {
    return this.adminService.suspendCourier(id);
  }

  @Get('orders')
  listOrders() {
    return this.adminService.listOrders();
  }

  @Put('orders/:id/cancel')
  cancelOrder(@Param('id') id: string, @Body('reason') reason?: string) {
    return this.adminService.cancelOrder(id, reason);
  }

  @Put('orders/:id/reassign-courier')
  reassignCourier(@Param('id') id: string, @Body('courierId') courierId: string) {
    return this.adminService.reassignCourier(id, courierId);
  }
}
