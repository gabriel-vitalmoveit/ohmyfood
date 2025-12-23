import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsString, Min } from 'class-validator';

export class CreateOptionGroupDto {
  @ApiProperty()
  @IsString()
  name!: string;

  @ApiProperty({ default: 0 })
  @IsInt()
  @Min(0)
  minSelect!: number;

  @ApiProperty({ default: 1 })
  @IsInt()
  @Min(0)
  maxSelect!: number;
}

