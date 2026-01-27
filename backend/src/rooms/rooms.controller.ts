import { Body, Controller, Delete, Get, Param, Patch, Post } from '@nestjs/common';
import { RoomsService } from './rooms.service';
import { CreateRoomDto } from './dto/create-room.dto';
import { UpdateRoomDto } from './dto/update-room.dto';

/**
 * RoomsController
 *
 * REST endpoints for Rooms.
 * NOTE: Public for now; later we protect with Auth + Roles.
 */
@Controller('rooms')
export class RoomsController {
  constructor(private readonly roomsService: RoomsService) { }

  /**
   * Create a room under a department.
   */
  @Post()
  create(@Body() dto: CreateRoomDto) {
    return this.roomsService.create(dto);
  }

  /**
   * List all rooms (with department + users).
   */
  @Get()
  findAll() {
    return this.roomsService.findAll();
  }

  /**
   * Get a single room by id.
   */
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.roomsService.findOne(id);
  }

  /**
   * Update room details (roomNumber or departmentId).
   */
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateRoomDto) {
    return this.roomsService.update(id, dto);
  }

  /**
   * Delete a room.
   */
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.roomsService.remove(id);
  }
}
