import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsOptional, IsString } from 'class-validator';
import { SupportTicketStatus } from '@prisma/client';

export class UpdateSupportTicketDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsEnum(SupportTicketStatus)
  status?: SupportTicketStatus;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  adminNotes?: string;
}

