import { Injectable } from '@nestjs/common';
import { PrismaService } from '../common';

@Injectable()
export class PromosService {
  constructor(private readonly prisma: PrismaService) {}

  listActive(date: Date = new Date()) {
    return this.prisma.promo.findMany({
      where: {
        startsAt: { lte: date },
        endsAt: { gte: date },
        budgetCents: { gt: 0 },
      },
      orderBy: { startsAt: 'asc' },
    });
  }
}
