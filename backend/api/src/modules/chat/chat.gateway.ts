import {
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { Server } from 'socket.io';
import { ChatService } from './chat.service';

@WebSocketGateway({ namespace: '/chat', cors: true })
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  private readonly logger = new Logger(ChatGateway.name);

  @WebSocketServer()
  server!: Server;

  constructor(private readonly chatService: ChatService) {}

  handleConnection(client: any) {
    this.logger.debug(`Cliente conectado ao chat: ${client.id}`);
  }

  handleDisconnect(client: any) {
    this.logger.debug(`Cliente desconectado do chat: ${client.id}`);
  }

  @SubscribeMessage('message')
  async handleMessage(
    @MessageBody()
    payload: { orderId: string; senderId: string; content: string },
  ) {
    const message = await this.chatService.saveMessage(payload);
    this.server.emit(`order:${payload.orderId}`, message);
  }
}
