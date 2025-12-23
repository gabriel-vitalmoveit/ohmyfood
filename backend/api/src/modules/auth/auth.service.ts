import { Injectable, InternalServerErrorException, Logger, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { PrismaClientKnownRequestError, Role } from '@prisma/client';
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
    } catch (error) {
      this.logger.error('Erro ao registrar usuário', error);
      
      if (error instanceof PrismaClientKnownRequestError) {
        // Erro P2002 = Unique constraint violation (email já existe)
        if (error.code === 'P2002') {
          throw new UnauthorizedException('Este email já está registado');
        }
        // Erro P2025 = Record not found (não deveria acontecer em create)
        // Outros erros do Prisma
        this.logger.error(`Prisma error code: ${error.code}`, error.meta);
        throw new InternalServerErrorException('Erro ao criar conta. Verifique a conexão com a base de dados.');
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
    } catch (error) {
      this.logger.error('Erro ao fazer login', error);
      
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      
      if (error instanceof PrismaClientKnownRequestError) {
        this.logger.error(`Prisma error code: ${error.code}`, error.meta);
        throw new InternalServerErrorException('Erro ao fazer login. Verifique a conexão com a base de dados.');
      }
      
      throw new InternalServerErrorException('Erro ao fazer login');
    }
  }

  async refresh(userId: string, role: Role) {
    const tokens = await this.issueTokens(userId, role);
    return { tokens };
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
