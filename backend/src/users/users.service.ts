import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateUserDto } from './dto/update-user.dto';

/**
 * UsersService
 *
 * Admin / internal user management operations.
 * NOTE: User creation is done via AuthService.register().
 */
@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) { }

  /**
   * Returns all users with their room and department.
   */
  async findAll() {
    return this.prisma.user.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        room: {
          include: { department: true },
        },
      },
    });
  }

  /**
   * Returns one user by id with room and department.
   */
  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: {
        room: {
          include: { department: true },
        },
      },
    });

    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  /**
   * Admin update:
   * - role, roomId, socialScore, username, email
   */
  async update(id: string, dto: UpdateUserDto) {
    // If roomId is being updated, validate it exists (better than FK error).
    if (dto.roomId) {
      const room = await this.prisma.room.findUnique({ where: { id: dto.roomId } });
      if (!room) throw new NotFoundException('Room not found');
    }

    try {
      return await this.prisma.user.update({
        where: { id },
        data: dto,
      });
    } catch (e: any) {
      if (e?.code === 'P2025') throw new NotFoundException('User not found');
      throw e;
    }
  }

  /**
   * Deletes a user by id.
   */
  async remove(id: string) {
    try {
      return await this.prisma.user.delete({ where: { id } });
    } catch (e: any) {
      if (e?.code === 'P2025') throw new NotFoundException('User not found');
      throw e;
    }
  }

  /**
   * Returns the "me" profile by userId from JWT.
   * (This will be used by /users/me)
   */
  async getMe(userId: string) {
    return this.findOne(userId);
  }

  /**
   * Allows a user to update their own profile fields.
   * Keep it minimal to avoid privilege escalation.
   */
  async updateMe(userId: string, dto: Pick<UpdateUserDto, 'username' | 'email'>) {
    try {
      return await this.prisma.user.update({
        where: { id: userId },
        data: dto,
      });
    } catch (e: any) {
      if (e?.code === 'P2025') throw new NotFoundException('User not found');
      throw e;
    }
  }
}
