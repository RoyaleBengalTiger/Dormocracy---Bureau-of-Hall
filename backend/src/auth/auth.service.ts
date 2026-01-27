import { ConflictException, Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as argon2 from 'argon2';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { Role } from '@prisma/client';

type Tokens = { accessToken: string; refreshToken: string };

@Injectable()
export class AuthService {
    constructor(
        private readonly prisma: PrismaService,
        private readonly jwt: JwtService,
        private readonly config: ConfigService,
    ) { }

    private async signTokens(userId: string, email: string, role: Role): Promise<Tokens> {
        const accessSecret = this.config.getOrThrow<string>('JWT_ACCESS_SECRET');
        const refreshSecret = this.config.getOrThrow<string>('JWT_REFRESH_SECRET');

        const accessTtl = Number(this.config.get<string>('JWT_ACCESS_TTL_SECONDS') ?? 900);
        const refreshTtl = Number(this.config.get<string>('JWT_REFRESH_TTL_SECONDS') ?? 2592000);

        const payload = { sub: userId, email, role };

        const [accessToken, refreshToken] = await Promise.all([
            this.jwt.signAsync(payload, { secret: accessSecret, expiresIn: accessTtl }),
            this.jwt.signAsync(payload, { secret: refreshSecret, expiresIn: refreshTtl }),
        ]);

        return { accessToken, refreshToken };
    }

    private async setRefreshTokenHash(userId: string, refreshToken: string) {
        const hash = await argon2.hash(refreshToken);
        await this.prisma.user.update({
            where: { id: userId },
            data: { refreshTokenHash: hash },
        });
    }

    async register(dto: RegisterDto) {
        // ensure room exists
        const room = await this.prisma.room.findUnique({ where: { id: dto.roomId } });
        if (!room) throw new NotFoundException('Room not found');

        const passwordHash = await argon2.hash(dto.password);

        try {
            const user = await this.prisma.user.create({
                data: {
                    username: dto.username,
                    email: dto.email,
                    password: passwordHash,
                    roomId: dto.roomId,
                    role: Role.USER,
                },
            });

            const tokens = await this.signTokens(user.id, user.email, user.role);
            await this.setRefreshTokenHash(user.id, tokens.refreshToken);

            return tokens;
        } catch (e: any) {
            if (e?.code === 'P2002') throw new ConflictException('Username or email already exists');
            throw e;
        }
    }

    async login(dto: LoginDto) {
        const user = await this.prisma.user.findUnique({ where: { email: dto.email } });
        if (!user) throw new UnauthorizedException('Invalid credentials');

        const ok = await argon2.verify(user.password, dto.password);
        if (!ok) throw new UnauthorizedException('Invalid credentials');

        const tokens = await this.signTokens(user.id, user.email, user.role);
        await this.setRefreshTokenHash(user.id, tokens.refreshToken);

        return tokens;
    }

    async refresh(userId: string, refreshToken: string) {
        const user = await this.prisma.user.findUnique({ where: { id: userId } });
        if (!user || !user.refreshTokenHash) throw new UnauthorizedException('Access denied');

        const ok = await argon2.verify(user.refreshTokenHash, refreshToken);
        if (!ok) throw new UnauthorizedException('Access denied');

        const tokens = await this.signTokens(user.id, user.email, user.role);
        await this.setRefreshTokenHash(user.id, tokens.refreshToken); // rotation

        return tokens;
    }

    async logout(userId: string) {
        await this.prisma.user.update({
            where: { id: userId },
            data: { refreshTokenHash: null },
        });
        return { success: true };
    }
}
