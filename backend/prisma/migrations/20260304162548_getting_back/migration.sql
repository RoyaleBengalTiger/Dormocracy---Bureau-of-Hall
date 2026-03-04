/*
  Warnings:

  - The values [BREACH_COMPENSATION,BREACH_FINE_INCOME,VIOLATION_FINE_INCOME,VIOLATION_REFUND] on the enum `TreasuryTransactionType` will be removed. If these variants are still used in the database, this will fail.
  - The values [AWAITING_OFFENDER_CHOICE] on the enum `ViolationStatus` will be removed. If these variants are still used in the database, this will fail.
  - You are about to drop the column `breachCaseId` on the `TreasuryTransaction` table. All the data in the column will be lost.
  - You are about to drop the column `violationId` on the `TreasuryTransaction` table. All the data in the column will be lost.
  - You are about to drop the column `hostForeignMinisterId` on the `Treaty` table. All the data in the column will be lost.
  - You are about to drop the column `mode` on the `Treaty` table. All the data in the column will be lost.
  - You are about to drop the column `isLocked` on the `TreatyClause` table. All the data in the column will be lost.
  - You are about to drop the column `lockedAt` on the `TreatyClause` table. All the data in the column will be lost.
  - You are about to drop the column `lockedById` on the `TreatyClause` table. All the data in the column will be lost.
  - You are about to drop the column `creditFine` on the `Violation` table. All the data in the column will be lost.
  - You are about to drop the column `creditsDeducted` on the `Violation` table. All the data in the column will be lost.
  - You are about to drop the column `creditsRefunded` on the `Violation` table. All the data in the column will be lost.
  - You are about to drop the column `offenderChoice` on the `Violation` table. All the data in the column will be lost.
  - You are about to drop the column `penaltyMode` on the `Violation` table. All the data in the column will be lost.
  - You are about to drop the column `pointsDeducted` on the `Violation` table. All the data in the column will be lost.
  - You are about to drop the `BreachVerdict` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `BreachVerdictVote` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `TreatyDepartment` table. If the table is not empty, all the data it contains will be lost.

*/
-- AlterEnum
BEGIN;
CREATE TYPE "TreasuryTransactionType_new" AS ENUM ('DEPT_ALLOCATE_TO_ROOM', 'DEPT_RECALL_FROM_ROOM', 'ROOM_TASK_SPEND', 'USER_BUY_SOCIAL_SCORE');
ALTER TABLE "TreasuryTransaction" ALTER COLUMN "type" TYPE "TreasuryTransactionType_new" USING ("type"::text::"TreasuryTransactionType_new");
ALTER TYPE "TreasuryTransactionType" RENAME TO "TreasuryTransactionType_old";
ALTER TYPE "TreasuryTransactionType_new" RENAME TO "TreasuryTransactionType";
DROP TYPE "public"."TreasuryTransactionType_old";
COMMIT;

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

-- DropForeignKey
ALTER TABLE "BreachVerdict" DROP CONSTRAINT "BreachVerdict_breachCaseId_fkey";

-- DropForeignKey
ALTER TABLE "BreachVerdict" DROP CONSTRAINT "BreachVerdict_proposedById_fkey";

-- DropForeignKey
ALTER TABLE "BreachVerdictVote" DROP CONSTRAINT "BreachVerdictVote_verdictId_fkey";

-- DropForeignKey
ALTER TABLE "BreachVerdictVote" DROP CONSTRAINT "BreachVerdictVote_voterDepartmentId_fkey";

-- DropForeignKey
ALTER TABLE "BreachVerdictVote" DROP CONSTRAINT "BreachVerdictVote_voterUserId_fkey";

-- DropForeignKey
ALTER TABLE "TreasuryTransaction" DROP CONSTRAINT "TreasuryTransaction_breachCaseId_fkey";

-- DropForeignKey
ALTER TABLE "TreasuryTransaction" DROP CONSTRAINT "TreasuryTransaction_violationId_fkey";

-- DropForeignKey
ALTER TABLE "Treaty" DROP CONSTRAINT "Treaty_hostForeignMinisterId_fkey";

-- DropForeignKey
ALTER TABLE "TreatyClause" DROP CONSTRAINT "TreatyClause_lockedById_fkey";

-- DropForeignKey
ALTER TABLE "TreatyDepartment" DROP CONSTRAINT "TreatyDepartment_departmentId_fkey";

-- DropForeignKey
ALTER TABLE "TreatyDepartment" DROP CONSTRAINT "TreatyDepartment_invitedById_fkey";

-- DropForeignKey
ALTER TABLE "TreatyDepartment" DROP CONSTRAINT "TreatyDepartment_respondedById_fkey";

-- DropForeignKey
ALTER TABLE "TreatyDepartment" DROP CONSTRAINT "TreatyDepartment_treatyId_fkey";

-- DropIndex
DROP INDEX "TreasuryTransaction_breachCaseId_idx";

-- DropIndex
DROP INDEX "TreasuryTransaction_violationId_idx";

-- AlterTable
ALTER TABLE "TreasuryTransaction" DROP COLUMN "breachCaseId",
DROP COLUMN "violationId";

-- AlterTable
ALTER TABLE "Treaty" DROP COLUMN "hostForeignMinisterId",
DROP COLUMN "mode";

-- AlterTable
ALTER TABLE "TreatyClause" DROP COLUMN "isLocked",
DROP COLUMN "lockedAt",
DROP COLUMN "lockedById";

-- AlterTable
ALTER TABLE "Violation" DROP COLUMN "creditFine",
DROP COLUMN "creditsDeducted",
DROP COLUMN "creditsRefunded",
DROP COLUMN "offenderChoice",
DROP COLUMN "penaltyMode",
DROP COLUMN "pointsDeducted";

-- DropTable
DROP TABLE "BreachVerdict";

-- DropTable
DROP TABLE "BreachVerdictVote";

-- DropTable
DROP TABLE "TreatyDepartment";

-- DropEnum
DROP TYPE "BreachVerdictStatus";

-- DropEnum
DROP TYPE "TreatyMode";

-- DropEnum
DROP TYPE "ViolationOffenderChoice";

-- DropEnum
DROP TYPE "ViolationPenaltyMode";
