-- CreateEnum
CREATE TYPE "ViolationStatus" AS ENUM ('ACTIVE', 'ARCHIVED', 'OVERTURNED', 'CLOSED');

-- AlterTable
ALTER TABLE "Violation" ADD COLUMN     "archivedAt" TIMESTAMP(3),
ADD COLUMN     "expiresAt" TIMESTAMP(3),
ADD COLUMN     "pointsRefunded" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "refundedAt" TIMESTAMP(3),
ADD COLUMN     "status" "ViolationStatus" NOT NULL DEFAULT 'ACTIVE';

-- CreateIndex
CREATE INDEX "Violation_status_expiresAt_idx" ON "Violation"("status", "expiresAt");
