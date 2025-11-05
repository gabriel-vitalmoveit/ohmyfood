import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsInt, IsOptional, IsString, Min, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

class CreateOrderItemDto {
  @ApiProperty()
  @IsString()
  menuItemId!: string;

  @ApiProperty({ minimum: 1 })
  @IsInt()
  @Min(1)
  quantity!: number;

  @ApiProperty({ type: [String], required: false })
  @IsOptional()
  @IsArray()
  addons?: string[];
}

export class CreateOrderDto {
  @ApiProperty()
  @IsString()
  restaurantId!: string;

  @ApiProperty({ type: [CreateOrderItemDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateOrderItemDto)
  items!: CreateOrderItemDto[];

  @ApiProperty()
  @IsInt()
  itemsTotalCents!: number;

  @ApiProperty()
  @IsInt()
  deliveryFeeCents!: number;

  @ApiProperty()
  @IsInt()
  serviceFeeCents!: number;
}
