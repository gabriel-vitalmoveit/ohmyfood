import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class CreateSupportTicketDto {
  @ApiProperty()
  @IsString()
  type!: string; // "order_issue", "payment", "general", etc.

  @ApiProperty()
  @IsString()
  subject!: string;

  @ApiProperty()
  @IsString()
  description!: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  orderId?: string;
}

