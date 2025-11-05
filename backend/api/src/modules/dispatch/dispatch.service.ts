import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../common';

@Injectable()
export class DispatchService {
  private readonly logger = new Logger(DispatchService.name);

  constructor(private readonly prisma: PrismaService) {}

  async findEligibleCouriers(orderId: string) {
    this.logger.log(`🔄 Procurar estafetas para pedido ${orderId}`);
    return this.prisma.courier.findMany({
      where: { isVerified: true, online: true },
      take: 5,
    });
  }
}
