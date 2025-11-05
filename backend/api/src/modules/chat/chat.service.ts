import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common';

@Injectable()
export class ChatService {
  constructor(private readonly prisma: PrismaService) {}

  async saveMessage({ orderId, senderId, content }: { orderId: string; senderId: string; content: string }) {
    const chat = await this.prisma.chat.upsert({
      where: { orderId },
      create: {
        order: { connect: { id: orderId } },
      },
      update: {},
    });

    return this.prisma.message.create({
      data: {
        chat: { connect: { id: chat.id } },
        sender: { connect: { id: senderId } },
        content,
      },
    });
  }
}
