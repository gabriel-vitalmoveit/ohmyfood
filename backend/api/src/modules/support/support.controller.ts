import { Body, Controller, Get, Param, Post, Put, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Role } from '@prisma/client';
import { SupportService } from './support.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser, CurrentUserPayload } from '../auth/decorators/current-user.decorator';
import { CreateSupportTicketDto } from './dto/create-support-ticket.dto';
import { UpdateSupportTicketDto } from './dto/update-support-ticket.dto';

@ApiTags('support')
@Controller('support')
export class SupportController {
  constructor(private readonly supportService: SupportService) {}

  @Post('tickets')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  createTicket(@CurrentUser() user: CurrentUserPayload, @Body() dto: CreateSupportTicketDto) {
    return this.supportService.createTicket(user.userId, dto);
  }

  @Get('tickets')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  listTickets(@CurrentUser() user: CurrentUserPayload) {
    // Admin vê todos, cliente vê apenas os seus
    return this.supportService.listTickets(user.role === Role.ADMIN ? undefined : user.userId);
  }

  @Get('tickets/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  getTicket(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string) {
    return this.supportService.getTicketById(id, user.role === Role.ADMIN ? undefined : user.userId);
  }

  @Put('tickets/:id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  updateTicket(@Param('id') id: string, @Body() dto: UpdateSupportTicketDto) {
    return this.supportService.updateTicket(id, dto);
  }
}

