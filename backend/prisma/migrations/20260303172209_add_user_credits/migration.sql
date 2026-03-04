/*
  Warnings:

  - A unique constraint covering the columns `[treatyId]` on the table `ChatRoom` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateEnum
CREATE TYPE "TreatyStatus" AS ENUM ('DRAFT', 'NEGOTIATION', 'LOCKED', 'PENDING_ACCEPTANCE', 'ACTIVE', 'EXPIRED');

-- CreateEnum
CREATE TYPE "TreatyType" AS ENUM ('EXCHANGE', 'NON_EXCHANGE');

-- CreateEnum
CREATE TYPE "ParticipantType" AS ENUM ('ROOM', 'USER');

-- CreateEnum
CREATE TYPE "ParticipantStatus" AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED');

-- CreateEnum
CREATE TYPE "ExchangeType" AS ENUM ('TASK_FOR_BOUNTY', 'NOTES_OR_RESOURCES_FOR_BOUNTY', 'ITEMS_FOR_BOUNTY');

-- CreateEnum
CREATE TYPE "ExchangeStatus" AS ENUM ('OPEN', 'ACCEPTED', 'DELIVERED', 'APPROVED', 'REJECTED');

-- CreateEnum
CREATE TYPE "BreachCaseStatus" AS ENUM ('OPEN', 'RESOLVED');

-- AlterEnum
ALTER TYPE "ChatRoomType" ADD VALUE 'TREATY_GROUP';

-- AlterTable
ALTER TABLE "ChatRoom" ADD COLUMN     "treatyId" TEXT;

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "credits" INTEGER NOT NULL DEFAULT 100;

-- CreateTable
CREATE TABLE "Treaty" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "type" "TreatyType" NOT NULL DEFAULT 'NON_EXCHANGE',
    "status" "TreatyStatus" NOT NULL DEFAULT 'DRAFT',
    "departmentId" TEXT NOT NULL,
    "createdById" TEXT NOT NULL,
    "endsAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Treaty_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TreatyClause" (
    "id" TEXT NOT NULL,
    "treatyId" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "orderIndex" INTEGER NOT NULL DEFAULT 0,
    "createdById" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TreatyClause_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TreatyParticipant" (
    "id" TEXT NOT NULL,
    "treatyId" TEXT NOT NULL,
    "type" "ParticipantType" NOT NULL,
    "status" "ParticipantStatus" NOT NULL DEFAULT 'PENDING',
    "roomId" TEXT,
    "userId" TEXT,
    "respondedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TreatyParticipant_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Exchange" (
    "id" TEXT NOT NULL,
    "treatyId" TEXT NOT NULL,
    "type" "ExchangeType" NOT NULL,
    "status" "ExchangeStatus" NOT NULL DEFAULT 'OPEN',
    "title" TEXT NOT NULL,
    "description" TEXT,
    "bounty" INTEGER NOT NULL,
    "sellerId" TEXT NOT NULL,
    "buyerId" TEXT,
    "deliveryNotes" TEXT,
    "deliveredAt" TIMESTAMP(3),
    "reviewedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Exchange_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BreachCase" (
    "id" TEXT NOT NULL,
    "treatyId" TEXT NOT NULL,
    "status" "BreachCaseStatus" NOT NULL DEFAULT 'OPEN',
    "filerId" TEXT NOT NULL,
    "accusedUserId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "exchangeId" TEXT,
    "resolutionNote" TEXT,
    "resolvedById" TEXT,
    "resolvedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "BreachCase_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BreachCaseClause" (
    "id" TEXT NOT NULL,
    "breachCaseId" TEXT NOT NULL,
    "clauseId" TEXT NOT NULL,

    CONSTRAINT "BreachCaseClause_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Treaty_departmentId_idx" ON "Treaty"("departmentId");

-- CreateIndex
CREATE INDEX "Treaty_createdById_idx" ON "Treaty"("createdById");

-- CreateIndex
CREATE INDEX "Treaty_status_idx" ON "Treaty"("status");

-- CreateIndex
CREATE INDEX "TreatyClause_treatyId_orderIndex_idx" ON "TreatyClause"("treatyId", "orderIndex");

-- CreateIndex
CREATE INDEX "TreatyParticipant_treatyId_idx" ON "TreatyParticipant"("treatyId");

-- CreateIndex
CREATE UNIQUE INDEX "TreatyParticipant_treatyId_roomId_key" ON "TreatyParticipant"("treatyId", "roomId");

-- CreateIndex
CREATE UNIQUE INDEX "TreatyParticipant_treatyId_userId_key" ON "TreatyParticipant"("treatyId", "userId");

-- CreateIndex
CREATE INDEX "Exchange_treatyId_idx" ON "Exchange"("treatyId");

-- CreateIndex
CREATE INDEX "Exchange_sellerId_idx" ON "Exchange"("sellerId");

-- CreateIndex
CREATE INDEX "Exchange_status_idx" ON "Exchange"("status");

-- CreateIndex
CREATE INDEX "BreachCase_treatyId_idx" ON "BreachCase"("treatyId");

-- CreateIndex
CREATE INDEX "BreachCase_accusedUserId_idx" ON "BreachCase"("accusedUserId");

-- CreateIndex
CREATE INDEX "BreachCase_status_idx" ON "BreachCase"("status");

-- CreateIndex
CREATE UNIQUE INDEX "BreachCaseClause_breachCaseId_clauseId_key" ON "BreachCaseClause"("breachCaseId", "clauseId");

-- CreateIndex
CREATE UNIQUE INDEX "ChatRoom_treatyId_key" ON "ChatRoom"("treatyId");

-- AddForeignKey
ALTER TABLE "ChatRoom" ADD CONSTRAINT "ChatRoom_treatyId_fkey" FOREIGN KEY ("treatyId") REFERENCES "Treaty"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Treaty" ADD CONSTRAINT "Treaty_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES "Department"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Treaty" ADD CONSTRAINT "Treaty_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TreatyClause" ADD CONSTRAINT "TreatyClause_treatyId_fkey" FOREIGN KEY ("treatyId") REFERENCES "Treaty"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TreatyClause" ADD CONSTRAINT "TreatyClause_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TreatyParticipant" ADD CONSTRAINT "TreatyParticipant_treatyId_fkey" FOREIGN KEY ("treatyId") REFERENCES "Treaty"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TreatyParticipant" ADD CONSTRAINT "TreatyParticipant_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES "Room"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TreatyParticipant" ADD CONSTRAINT "TreatyParticipant_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Exchange" ADD CONSTRAINT "Exchange_treatyId_fkey" FOREIGN KEY ("treatyId") REFERENCES "Treaty"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Exchange" ADD CONSTRAINT "Exchange_sellerId_fkey" FOREIGN KEY ("sellerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Exchange" ADD CONSTRAINT "Exchange_buyerId_fkey" FOREIGN KEY ("buyerId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BreachCase" ADD CONSTRAINT "BreachCase_treatyId_fkey" FOREIGN KEY ("treatyId") REFERENCES "Treaty"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BreachCase" ADD CONSTRAINT "BreachCase_filerId_fkey" FOREIGN KEY ("filerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BreachCase" ADD CONSTRAINT "BreachCase_accusedUserId_fkey" FOREIGN KEY ("accusedUserId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BreachCase" ADD CONSTRAINT "BreachCase_resolvedById_fkey" FOREIGN KEY ("resolvedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BreachCaseClause" ADD CONSTRAINT "BreachCaseClause_breachCaseId_fkey" FOREIGN KEY ("breachCaseId") REFERENCES "BreachCase"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BreachCaseClause" ADD CONSTRAINT "BreachCaseClause_clauseId_fkey" FOREIGN KEY ("clauseId") REFERENCES "TreatyClause"("id") ON DELETE CASCADE ON UPDATE CASCADE;
