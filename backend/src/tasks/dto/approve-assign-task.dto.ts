import { IsInt, IsOptional, IsString, Min } from 'class-validator';

export class ApproveAssignTaskDto {
    @IsString()
    assignedToId: string;

    @IsOptional()
    @IsInt()
    @Min(0)
    fundAmount?: number;
}
