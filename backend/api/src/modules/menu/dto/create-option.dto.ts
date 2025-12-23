import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsInt, IsOptional, IsString, Min } from 'class-validator';

export class CreateOptionDto {
  @ApiProperty()
  @IsString()
  name!: string;

  @ApiProperty({ default: 0 })
  @IsInt()
  @Min(0)
  priceCents!: number;

  @ApiProperty({ required: false, default: true })
  @IsOptional()
  @IsBoolean()
  available?: boolean;
}

