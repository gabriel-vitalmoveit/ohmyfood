import { Injectable, InternalServerErrorException, Logger, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Role } from '@prisma/client';
import * as argon2 from 'argon2';
import { PrismaService } from '../common';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async register(dto: RegisterDto) {
    try {
      const passwordHash = await argon2.hash(dto.password);
      const user = await this.prisma.user.create({
        data: {
          email: dto.email,
          passwordHash,
          role: dto.role ?? Role.CUSTOMER,
          displayName: dto.displayName,
        },
      });

      const tokens = await this.issueTokens(user.id, user.role);
      return { user, tokens };
    } catch (error: any) {
      this.logger.error('Erro ao registrar usuário', error);
      
      // Verificar se é um erro do Prisma (tem código que começa com 'P')
      if (error?.code && typeof error.code === 'string' && error.code.startsWith('P')) {
        // Erro P2002 = Unique constraint violation (email já existe)
        if (error.code === 'P2002') {
          throw new UnauthorizedException('Este email já está registado');
        }
        // Erro P2021 = Table does not exist (migrations não executadas)
        if (error.code === 'P2021') {
          this.logger.error('Tabela não existe! Migrations não foram executadas.', error.meta);
          throw new InternalServerErrorException('Base de dados não configurada. Execute as migrations primeiro.');
        }
        // Erro P2025 = Record not found (não deveria acontecer em create)
        // Outros erros do Prisma
        this.logger.error(`Prisma error code: ${error.code}`, error.meta);
        throw new InternalServerErrorException(`Erro ao criar conta (${error.code}). Verifique a conexão com a base de dados.`);
      }
      
      throw error;
    }
  }

  async login({ email, password }: LoginDto) {
    try {
      const user = await this.prisma.user.findUnique({ where: { email } });
      if (!user) {
        throw new UnauthorizedException('Credenciais inválidas');
      }

      const isValid = await argon2.verify(user.passwordHash, password);
      if (!isValid) {
        throw new UnauthorizedException('Credenciais inválidas');
      }

      const tokens = await this.issueTokens(user.id, user.role);
      return { user, tokens };
    } catch (error: any) {
      this.logger.error('Erro ao fazer login', error);
      
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      
      // Verificar se é um erro do Prisma (tem código que começa com 'P')
      if (error?.code && typeof error.code === 'string' && error.code.startsWith('P')) {
        // Erro P2021 = Table does not exist (migrations não executadas)
        if (error.code === 'P2021') {
          this.logger.error('Tabela não existe! Migrations não foram executadas.', error.meta);
          throw new InternalServerErrorException('Base de dados não configurada. Execute as migrations primeiro.');
        }
        this.logger.error(`Prisma error code: ${error.code}`, error.meta);
        throw new InternalServerErrorException(`Erro ao fazer login (${error.code}). Verifique a conexão com a base de dados.`);
      }
      
      throw new InternalServerErrorException('Erro ao fazer login');
    }
  }

  async refresh(userId: string, role: Role) {
    const tokens = await this.issueTokens(userId, role);
    return { tokens };
  }

  async refreshFromToken(refreshToken: string) {
    try {
      // Verificar e decodificar o refresh token
      const payload = await this.jwtService.verifyAsync(refreshToken, {
        secret: this.configService.get<string>('jwt.refreshSecret'),
      });

      if (payload.type !== 'refresh') {
        throw new UnauthorizedException('Token inválido');
      }

      // Buscar usuário para garantir que ainda existe
      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub },
      });

      if (!user) {
        throw new UnauthorizedException('Usuário não encontrado');
      }

      // Emitir novos tokens
      const tokens = await this.issueTokens(user.id, user.role);
      return { tokens };
    } catch (error) {
      this.logger.error('Erro ao renovar token', error);
      throw new UnauthorizedException('Token de refresh inválido ou expirado');
    }
  }

  async getMe(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        restaurant: {
          select: { id: true },
        },
        courier: {
          select: { id: true },
        },
      },
    });

    if (!user) {
      throw new UnauthorizedException('Usuário não encontrado');
    }

    return {
      id: user.id,
      email: user.email,
      role: user.role,
      displayName: user.displayName,
      restaurantId: user.restaurant?.id ?? null,
      courierId: user.courier?.id ?? null,
    };
  }

  private async issueTokens(userId: string, role: Role): Promise<AuthTokens> {
    const accessToken = await this.jwtService.signAsync(
      { sub: userId, role },
      {
        secret: this.configService.get<string>('jwt.accessSecret'),
        expiresIn: this.configService.get<string>('jwt.accessTtl'),
      },
    );

    const refreshToken = await this.jwtService.signAsync(
      { sub: userId, role, type: 'refresh' },
      {
        secret: this.configService.get<string>('jwt.refreshSecret'),
        expiresIn: this.configService.get<string>('jwt.refreshTtl'),
      },
    );

    return { accessToken, refreshToken };
  }
}
