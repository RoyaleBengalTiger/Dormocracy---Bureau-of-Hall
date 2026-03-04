import { IsEnum } from 'class-validator';

export enum ViolationOffenderChoiceDto {
    CREDITS = 'CREDITS',
    SOCIAL_SCORE = 'SOCIAL_SCORE',
}

export class ChooseViolationPenaltyDto {
    @IsEnum(ViolationOffenderChoiceDto)
    choice: ViolationOffenderChoiceDto;
}
