/*
  Warnings:

  - A unique constraint covering the columns `[breachCaseId]` on the table `ChatRoom` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateEnum
CREATE TYPE "BreachRulingType" AS ENUM ('AGAINST_ACCUSED', 'AGAINST_ACCUSER', 'NONE');

-- CreateEnum
CREATE TYPE "BreachPenaltyMode" AS ENUM ('BOTH_MANDATORY', 'EITHER_CHOICE', 'NONE');

-- CreateEnum
CREATE TYPE "BreachCriminalChoice" AS ENUM ('SOCIAL', 'CREDITS');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "BreachCaseStatus" ADD VALUE 'IN_REVIEW';
ALTER TYPE "BreachCaseStatus" ADD VALUE 'AWAITING_CRIMINAL_CHOICE';

-- AlterEnum
ALTER TYPE "ChatRoomType" ADD VALUE 'BREACH_CASE';

-- AlterTable
ALTER TABLE "BreachCase" ADD COLUMN     "creditFine" INTEGER,
ADD COLUMN     "criminalChoice" "BreachCriminalChoice",
ADD COLUMN     "evaluatedAt" TIMESTAMP(3),
ADD COLUMN     "penaltyMode" "BreachPenaltyMode",
ADD COLUMN     "ruledAt" TIMESTAMP(3),
ADD COLUMN     "ruledById" TEXT,
ADD COLUMN     "rulingTargetUserId" TEXT,
ADD COLUMN     "rulingType" "BreachRulingType",
ADD COLUMN     "socialPenalty" INTEGER;

-- AlterTable
ALTER TABLE "ChatRoom" ADD COLUMN     "breachCaseId" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "ChatRoom_breachCaseId_key" ON "ChatRoom"("breachCaseId");

-- AddForeignKey
ALTER TABLE "ChatRoom" ADD CONSTRAINT "ChatRoom_breachCaseId_fkey" FOREIGN KEY ("breachCaseId") REFERENCES "BreachCase"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BreachCase" ADD CONSTRAINT "BreachCase_ruledById_fkey" FOREIGN KEY ("ruledById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BreachCase" ADD CONSTRAINT "BreachCase_rulingTargetUserId_fkey" FOREIGN KEY ("rulingTargetUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
