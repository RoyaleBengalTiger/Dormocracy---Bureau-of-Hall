/*
  Warnings:

  - You are about to drop the column `hostForeignMinisterId` on the `Treaty` table. All the data in the column will be lost.
  - You are about to drop the column `mode` on the `Treaty` table. All the data in the column will be lost.
  - You are about to drop the column `isLocked` on the `TreatyClause` table. All the data in the column will be lost.
  - You are about to drop the column `lockedAt` on the `TreatyClause` table. All the data in the column will be lost.
  - You are about to drop the column `lockedById` on the `TreatyClause` table. All the data in the column will be lost.
  - You are about to drop the `BreachVerdict` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `BreachVerdictVote` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `TreatyDepartment` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "BreachVerdict" DROP CONSTRAINT "BreachVerdict_breachCaseId_fkey";

-- DropForeignKey
ALTER TABLE "BreachVerdict" DROP CONSTRAINT "BreachVerdict_proposedById_fkey";

-- DropForeignKey
ALTER TABLE "BreachVerdict" DROP CONSTRAINT "BreachVerdict_treatyId_fkey";

-- DropForeignKey
ALTER TABLE "BreachVerdictVote" DROP CONSTRAINT "BreachVerdictVote_verdictId_fkey";

-- DropForeignKey
ALTER TABLE "BreachVerdictVote" DROP CONSTRAINT "BreachVerdictVote_voterDepartmentId_fkey";

-- DropForeignKey
ALTER TABLE "BreachVerdictVote" DROP CONSTRAINT "BreachVerdictVote_voterUserId_fkey";

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
DROP INDEX "Treaty_mode_idx";

-- AlterTable
ALTER TABLE "Treaty" DROP COLUMN "hostForeignMinisterId",
DROP COLUMN "mode";

-- AlterTable
ALTER TABLE "TreatyClause" DROP COLUMN "isLocked",
DROP COLUMN "lockedAt",
DROP COLUMN "lockedById";

-- DropTable
DROP TABLE "BreachVerdict";

-- DropTable
DROP TABLE "BreachVerdictVote";

-- DropTable
DROP TABLE "TreatyDepartment";

-- DropEnum
DROP TYPE "BreachVerdictStatus";

-- DropEnum
DROP TYPE "TreatyDepartmentStatus";

-- DropEnum
DROP TYPE "TreatyMode";

-- DropEnum
DROP TYPE "VerdictVoteValue";
