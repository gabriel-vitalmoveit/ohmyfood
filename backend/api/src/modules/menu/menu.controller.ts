import { Body, Controller, Delete, Get, Param, Post, Put, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { Prisma, Role } from '@prisma/client';
import { MenuService } from './menu.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';

@ApiTags('menu')
@Controller('restaurants/:restaurantId/menu')
export class MenuController {
  constructor(private readonly menuService: MenuService) {}

  @Get()
  // Menu público - sem auth
  list(@Param('restaurantId') restaurantId: string) {
    return this.menuService.listByRestaurant(restaurantId);
  }

  @Get(':id')
  // Item público - sem auth
  getById(@Param('id') id: string) {
    return this.menuService.getById(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  create(
    @Param('restaurantId') restaurantId: string,
    @Body() data: Prisma.MenuItemCreateWithoutRestaurantInput,
  ) {
    return this.menuService.create(restaurantId, data);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  update(@Param('id') id: string, @Body() data: Prisma.MenuItemUpdateInput) {
    return this.menuService.update(id, data);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  delete(@Param('id') id: string) {
    return this.menuService.delete(id);
  }

  // OptionGroups
  @Post(':menuItemId/option-groups')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  createOptionGroup(@Param('menuItemId') menuItemId: string, @Body() data: any) {
    return this.menuService.createOptionGroup(menuItemId, data);
  }

  @Put('option-groups/:optionGroupId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  updateOptionGroup(@Param('optionGroupId') optionGroupId: string, @Body() data: any) {
    return this.menuService.updateOptionGroup(optionGroupId, data);
  }

  @Delete('option-groups/:optionGroupId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  deleteOptionGroup(@Param('optionGroupId') optionGroupId: string) {
    return this.menuService.deleteOptionGroup(optionGroupId);
  }

  // Options
  @Post('option-groups/:optionGroupId/options')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  createOption(@Param('optionGroupId') optionGroupId: string, @Body() data: any) {
    return this.menuService.createOption(optionGroupId, data);
  }

  @Put('options/:optionId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  updateOption(@Param('optionId') optionId: string, @Body() data: any) {
    return this.menuService.updateOption(optionId, data);
  }

  @Delete('options/:optionId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  deleteOption(@Param('optionId') optionId: string) {
    return this.menuService.deleteOption(optionId);
  }
}
