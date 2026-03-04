import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';

import { DepartmentsModule } from './departments/departments.module';
import { RoomsModule } from './rooms/rooms.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { TasksModule } from './tasks/tasks.module';
import { ChatModule } from './chat/chat.module';
import { ViolationsModule } from './violations/violations.module';
import { TreatiesModule } from './treaties/treaties.module';
import { FinanceModule } from './finance/finance.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,

    DepartmentsModule,
    RoomsModule,
    UsersModule,
    ChatModule,
    AuthModule,

    TasksModule,
    ViolationsModule,
    TreatiesModule,
    FinanceModule,
  ],
})
export class AppModule { }

