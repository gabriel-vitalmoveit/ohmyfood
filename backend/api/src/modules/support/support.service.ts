import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../common';
import { CreateSupportTicketDto } from './dto/create-support-ticket.dto';
import { UpdateSupportTicketDto } from './dto/update-support-ticket.dto';

@Injectable()
export class SupportService {
  constructor(private readonly prisma: PrismaService) {}

  async createTicket(userId: string, dto: CreateSupportTicketDto) {
    return this.prisma.supportTicket.create({
      data: {
        userId,
        orderId: dto.orderId,
        type: dto.type,
        subject: dto.subject,
        description: dto.description,
      },
    });
  }

  async listTickets(userId?: string) {
    if (userId) {
      // Cliente vê apenas seus tickets
      return this.prisma.supportTicket.findMany({
        where: { userId },
        include: { order: { select: { id: true, status: true } } },
        orderBy: { createdAt: 'desc' },
      });
    }
    // Admin vê todos
    return this.prisma.supportTicket.findMany({
      include: {
        user: { select: { id: true, email: true, displayName: true } },
        order: { select: { id: true, status: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getTicketById(ticketId: string, userId?: string) {
    const ticket = await this.prisma.supportTicket.findUnique({
      where: { id: ticketId },
      include: {
        user: { select: { id: true, email: true, displayName: true } },
        order: { select: { id: true, status: true } },
      },
    });

    if (!ticket) {
      throw new NotFoundException('Ticket não encontrado');
    }

    // Cliente só pode ver seus próprios tickets
    if (userId && ticket.userId !== userId) {
      throw new NotFoundException('Ticket não encontrado');
    }

    return ticket;
  }

  async updateTicket(ticketId: string, dto: UpdateSupportTicketDto) {
    const ticket = await this.prisma.supportTicket.findUnique({
      where: { id: ticketId },
    });

    if (!ticket) {
      throw new NotFoundException('Ticket não encontrado');
    }

    return this.prisma.supportTicket.update({
      where: { id: ticketId },
      data: {
        ...dto,
        resolvedAt: dto.status === 'RESOLVED' || dto.status === 'CLOSED' ? new Date() : null,
      },
    });
  }
}

