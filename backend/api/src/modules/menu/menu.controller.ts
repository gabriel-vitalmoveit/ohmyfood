import { Body, Controller, Delete, Get, Param, Post, Put, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { Prisma, Role } from '@prisma/client';
import { MenuService } from './menu.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser, CurrentUserPayload } from '../auth/decorators/current-user.decorator';

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
    @CurrentUser() user: CurrentUserPayload,
  ) {
    // Admin pode criar em qualquer restaurant, Restaurant só no seu
    const userId = user.role === Role.ADMIN ? undefined : user.userId;
    return this.menuService.create(restaurantId, data, userId);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  update(@Param('id') id: string, @Body() data: Prisma.MenuItemUpdateInput, @CurrentUser() user: CurrentUserPayload) {
    // Admin pode editar qualquer item, Restaurant só os seus
    const userId = user.role === Role.ADMIN ? undefined : user.userId;
    return this.menuService.update(id, data, userId);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  delete(@Param('id') id: string, @CurrentUser() user: CurrentUserPayload) {
    // Admin pode deletar qualquer item, Restaurant só os seus
    const userId = user.role === Role.ADMIN ? undefined : user.userId;
    return this.menuService.delete(id, userId);
  }

  // OptionGroups
  @Post(':menuItemId/option-groups')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  createOptionGroup(@Param('menuItemId') menuItemId: string, @Body() data: any, @CurrentUser() user: CurrentUserPayload) {
    const userId = user.role === Role.ADMIN ? undefined : user.userId;
    return this.menuService.createOptionGroup(menuItemId, data, userId);
  }

  @Put('option-groups/:optionGroupId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  updateOptionGroup(@Param('optionGroupId') optionGroupId: string, @Body() data: any, @CurrentUser() user: CurrentUserPayload) {
    const userId = user.role === Role.ADMIN ? undefined : user.userId;
    return this.menuService.updateOptionGroup(optionGroupId, data, userId);
  }

  @Delete('option-groups/:optionGroupId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  deleteOptionGroup(@Param('optionGroupId') optionGroupId: string, @CurrentUser() user: CurrentUserPayload) {
    const userId = user.role === Role.ADMIN ? undefined : user.userId;
    return this.menuService.deleteOptionGroup(optionGroupId, userId);
  }

  // Options
  @Post('option-groups/:optionGroupId/options')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  createOption(@Param('optionGroupId') optionGroupId: string, @Body() data: any, @CurrentUser() user: CurrentUserPayload) {
    const userId = user.role === Role.ADMIN ? undefined : user.userId;
    return this.menuService.createOption(optionGroupId, data, userId);
  }

  @Put('options/:optionId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  updateOption(@Param('optionId') optionId: string, @Body() data: any, @CurrentUser() user: CurrentUserPayload) {
    const userId = user.role === Role.ADMIN ? undefined : user.userId;
    return this.menuService.updateOption(optionId, data, userId);
  }

  @Delete('options/:optionId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.RESTAURANT, Role.ADMIN)
  @ApiBearerAuth()
  deleteOption(@Param('optionId') optionId: string, @CurrentUser() user: CurrentUserPayload) {
    const userId = user.role === Role.ADMIN ? undefined : user.userId;
    return this.menuService.deleteOption(optionId, userId);
  }
}
