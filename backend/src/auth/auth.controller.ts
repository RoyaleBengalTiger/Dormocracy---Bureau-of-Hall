import { Body, Controller, Post, Req, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';

/**
 * NOTE:
 * For refresh, we expect the client to send refreshToken in body.
 * Later, when frontend is ready, you can move refreshToken to httpOnly cookie.
 */
@Controller('auth')
export class AuthController {
    constructor(private readonly auth: AuthService) { }

    @Post('register')
    register(@Body() dto: RegisterDto) {
        return this.auth.register(dto);
    }

    @Post('login')
    login(@Body() dto: LoginDto) {
        return this.auth.login(dto);
    }

    @Post('refresh')
    async refresh(@Body('userId') userId: string, @Body('refreshToken') refreshToken: string) {
        return this.auth.refresh(userId, refreshToken);
    }

    @UseGuards(JwtAuthGuard)
    @Post('logout')
    logout(@Req() req: any) {
        return this.auth.logout(req.user.sub);
    }
}
