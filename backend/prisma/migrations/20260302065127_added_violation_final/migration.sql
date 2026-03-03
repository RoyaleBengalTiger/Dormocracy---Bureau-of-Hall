/*
  Warnings:

  - The values [ARCHIVED,OVERTURNED,CLOSED] on the enum `ViolationStatus` will be removed. If these variants are still used in the database, this will fail.
  - A unique constraint covering the columns `[violationId]` on the table `ChatRoom` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateEnum
CREATE TYPE "ViolationVerdict" AS ENUM ('UPHELD', 'OVERTURNED', 'PUNISH_MAYOR');

-- AlterEnum
ALTER TYPE "ChatRoomType" ADD VALUE 'VIOLATION_CASE';

-- AlterEnum
BEGIN;
CREATE TYPE "ViolationStatus_new" AS ENUM ('ACTIVE', 'APPEALED', 'IN_EVALUATION', 'CLOSED_UPHELD', 'CLOSED_OVERTURNED', 'EXPIRED');
ALTER TABLE "public"."Violation" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "Violation" ALTER COLUMN "status" TYPE "ViolationStatus_new" USING ("status"::text::"ViolationStatus_new");
ALTER TYPE "ViolationStatus" RENAME TO "ViolationStatus_old";
ALTER TYPE "ViolationStatus_new" RENAME TO "ViolationStatus";
DROP TYPE "public"."ViolationStatus_old";
ALTER TABLE "Violation" ALTER COLUMN "status" SET DEFAULT 'ACTIVE';
COMMIT;

-- DropIndex
DROP INDEX "Violation_status_expiresAt_idx";

-- AlterTable
ALTER TABLE "ChatRoom" ADD COLUMN     "closedAt" TIMESTAMP(3),
ADD COLUMN     "violationId" TEXT;

-- AlterTable
ALTER TABLE "Violation" ADD COLUMN     "appealNote" TEXT,
ADD COLUMN     "appealedAt" TIMESTAMP(3),
ADD COLUMN     "closedById" TEXT,
ADD COLUMN     "evaluationClosedAt" TIMESTAMP(3),
ADD COLUMN     "evaluationStartedAt" TIMESTAMP(3),
ADD COLUMN     "mayorViolationId" TEXT,
ADD COLUMN     "verdict" "ViolationVerdict",
ADD COLUMN     "verdictNote" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "ChatRoom_violationId_key" ON "ChatRoom"("violationId");

-- CreateIndex
CREATE INDEX "Violation_status_idx" ON "Violation"("status");

-- CreateIndex
CREATE INDEX "Violation_expiresAt_idx" ON "Violation"("expiresAt");

-- AddForeignKey
ALTER TABLE "ChatRoom" ADD CONSTRAINT "ChatRoom_violationId_fkey" FOREIGN KEY ("violationId") REFERENCES "Violation"("id") ON DELETE CASCADE ON UPDATE CASCADE;
