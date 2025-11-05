import { Controller, Get } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { PromosService } from './promos.service';

@ApiTags('promos')
@Controller('promos')
export class PromosController {
  constructor(private readonly promosService: PromosService) {}

  @Get()
  list() {
    return this.promosService.listActive();
  }
}
