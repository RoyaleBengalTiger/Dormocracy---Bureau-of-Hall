import { IsEmail, IsEnum, IsInt, IsOptional, IsString, Min } from 'class-validator';
import { Role } from '@prisma/client';

/**
 * UpdateUserDto
 *
 * Admin-focused update DTO:
 * - Can change role, roomId, socialScore, username/email (optional)
 * - Does NOT include password (password is handled by Auth module only)
 */
export class UpdateUserDto {
    @IsOptional()
    @IsString()
    username?: string;

    @IsOptional()
    @IsEmail()
    email?: string;

    @IsOptional()
    @IsEnum(Role)
    role?: Role;

    @IsOptional()
    @IsString()
    roomId?: string;

    @IsOptional()
    @IsInt()
    @Min(0)
    socialScore?: number;
}
