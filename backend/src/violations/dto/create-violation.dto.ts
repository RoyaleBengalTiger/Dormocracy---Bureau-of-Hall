import { IsString, IsInt, Min, MinLength, IsOptional, IsDateString } from 'class-validator';

export class CreateViolationDto {
    @IsString()
    offenderId: string;

    @IsString()
    @MinLength(2)
    title: string;

    @IsOptional()
    @IsString()
    description?: string;

    @IsInt()
    @Min(0)
    points: number;

    /** Optional ISO date string; if set, violation auto-expires after this time. */
    @IsOptional()
    @IsDateString()
    expiresAt?: string;
}
