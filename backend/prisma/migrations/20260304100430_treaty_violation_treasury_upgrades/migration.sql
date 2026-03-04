-- CreateEnum
CREATE TYPE "ViolationPenaltyMode" AS ENUM ('BOTH_MANDATORY', 'EITHER_CHOICE');

-- CreateEnum
CREATE TYPE "ViolationOffenderChoice" AS ENUM ('CREDITS', 'SOCIAL_SCORE');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "TreasuryTransactionType" ADD VALUE 'BREACH_COMPENSATION';
ALTER TYPE "TreasuryTransactionType" ADD VALUE 'BREACH_FINE_INCOME';
ALTER TYPE "TreasuryTransactionType" ADD VALUE 'VIOLATION_FINE_INCOME';
ALTER TYPE "TreasuryTransactionType" ADD VALUE 'VIOLATION_REFUND';

-- AlterTable
ALTER TABLE "TreasuryTransaction" ADD COLUMN     "breachCaseId" TEXT,
ADD COLUMN     "violationId" TEXT;

-- AlterTable
ALTER TABLE "Violation" ADD COLUMN     "creditFine" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "creditsDeducted" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "creditsRefunded" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "offenderChoice" "ViolationOffenderChoice",
ADD COLUMN     "penaltyMode" "ViolationPenaltyMode",
ADD COLUMN     "pointsDeducted" INTEGER NOT NULL DEFAULT 0;

-- CreateIndex
CREATE INDEX "TreasuryTransaction_breachCaseId_idx" ON "TreasuryTransaction"("breachCaseId");

-- CreateIndex
CREATE INDEX "TreasuryTransaction_violationId_idx" ON "TreasuryTransaction"("violationId");

-- AddForeignKey
ALTER TABLE "TreasuryTransaction" ADD CONSTRAINT "TreasuryTransaction_breachCaseId_fkey" FOREIGN KEY ("breachCaseId") REFERENCES "BreachCase"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TreasuryTransaction" ADD CONSTRAINT "TreasuryTransaction_violationId_fkey" FOREIGN KEY ("violationId") REFERENCES "Violation"("id") ON DELETE SET NULL ON UPDATE CASCADE;
