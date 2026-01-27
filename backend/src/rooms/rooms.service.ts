import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateRoomDto } from './dto/create-room.dto';
import { UpdateRoomDto } from './dto/update-room.dto';

@Injectable()
export class RoomsService {
  constructor(private readonly prisma: PrismaService) { }

  async create(dto: CreateRoomDto) {
    // ensure department exists (better error than raw FK)
    const dept = await this.prisma.department.findUnique({ where: { id: dto.departmentId } });
    if (!dept) throw new NotFoundException('Department not found');

    try {
      return await this.prisma.room.create({ data: dto });
    } catch (e: any) {
      // unique([departmentId, roomNumber])
      if (e?.code === 'P2002') throw new ConflictException('Room number already exists in this department');
      throw e;
    }
  }

  async findAll() {
    return this.prisma.room.findMany({
      orderBy: { createdAt: 'desc' },
      include: { department: true, users: true },
    });
  }

  async findOne(id: string) {
    const room = await this.prisma.room.findUnique({
      where: { id },
      include: { department: true, users: true },
    });
    if (!room) throw new NotFoundException('Room not found');
    return room;
  }

  async update(id: string, dto: UpdateRoomDto) {
    if (dto.departmentId) {
      const dept = await this.prisma.department.findUnique({ where: { id: dto.departmentId } });
      if (!dept) throw new NotFoundException('Department not found');
    }

    try {
      return await this.prisma.room.update({
        where: { id },
        data: dto,
      });
    } catch (e: any) {
      if (e?.code === 'P2025') throw new NotFoundException('Room not found');
      if (e?.code === 'P2002') throw new ConflictException('Duplicate roomNumber in this department');
      throw e;
    }
  }

  async remove(id: string) {
    try {
      return await this.prisma.room.delete({ where: { id } });
    } catch (e: any) {
      if (e?.code === 'P2025') throw new NotFoundException('Room not found');
      throw e;
    }
  }
}
