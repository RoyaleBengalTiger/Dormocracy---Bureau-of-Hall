-- CreateEnum
CREATE TYPE "TreatyMode" AS ENUM ('DEPT_SCOPE', 'INTER_DEPT');

-- CreateEnum
CREATE TYPE "TreatyDepartmentStatus" AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED', 'LEFT');

-- CreateEnum
CREATE TYPE "BreachVerdictStatus" AS ENUM ('PROPOSED', 'ACCEPTED', 'REJECTED');

-- CreateEnum
CREATE TYPE "VerdictVoteValue" AS ENUM ('ACCEPT', 'REJECT');

-- AlterTable
ALTER TABLE "Treaty" ADD COLUMN     "hostForeignMinisterId" TEXT,
ADD COLUMN     "mode" "TreatyMode" NOT NULL DEFAULT 'DEPT_SCOPE';

-- AlterTable
ALTER TABLE "TreatyClause" ADD COLUMN     "isLocked" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "lockedAt" TIMESTAMP(3),
ADD COLUMN     "lockedById" TEXT;

-- CreateTable
CREATE TABLE "TreatyDepartment" (
    "id" TEXT NOT NULL,
    "treatyId" TEXT NOT NULL,
    "departmentId" TEXT NOT NULL,
    "status" "TreatyDepartmentStatus" NOT NULL DEFAULT 'PENDING',
    "invitedById" TEXT NOT NULL,
    "respondedById" TEXT,
    "respondedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TreatyDepartment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BreachVerdict" (
    "id" TEXT NOT NULL,
    "breachCaseId" TEXT NOT NULL,
    "treatyId" TEXT NOT NULL,
    "proposedById" TEXT NOT NULL,
    "status" "BreachVerdictStatus" NOT NULL DEFAULT 'PROPOSED',
    "ruledAgainst" "BreachRulingType" NOT NULL,
    "creditFine" INTEGER NOT NULL DEFAULT 0,
    "socialPenalty" INTEGER NOT NULL DEFAULT 0,
    "penaltyMode" "BreachPenaltyMode" NOT NULL DEFAULT 'NONE',
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finalizedAt" TIMESTAMP(3),

    CONSTRAINT "BreachVerdict_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BreachVerdictVote" (
    "id" TEXT NOT NULL,
    "verdictId" TEXT NOT NULL,
    "voterUserId" TEXT NOT NULL,
    "voterDepartmentId" TEXT NOT NULL,
    "vote" "VerdictVoteValue" NOT NULL,
    "comment" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "BreachVerdictVote_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "TreatyDepartment_treatyId_idx" ON "TreatyDepartment"("treatyId");

-- CreateIndex
CREATE INDEX "TreatyDepartment_departmentId_idx" ON "TreatyDepartment"("departmentId");

-- CreateIndex
CREATE UNIQUE INDEX "TreatyDepartment_treatyId_departmentId_key" ON "TreatyDepartment"("treatyId", "departmentId");

-- CreateIndex
CREATE INDEX "BreachVerdict_breachCaseId_idx" ON "BreachVerdict"("breachCaseId");

-- CreateIndex
CREATE INDEX "BreachVerdict_treatyId_idx" ON "BreachVerdict"("treatyId");

-- CreateIndex
CREATE INDEX "BreachVerdictVote_verdictId_idx" ON "BreachVerdictVote"("verdictId");

-- CreateIndex
CREATE UNIQUE INDEX "BreachVerdictVote_verdictId_voterUserId_key" ON "BreachVerdictVote"("verdictId", "voterUserId");

-- CreateIndex
CREATE INDEX "Treaty_mode_idx" ON "Treaty"("mode");

-- AddForeignKey
ALTER TABLE "Treaty" ADD CONSTRAINT "Treaty_hostForeignMinisterId_fkey" FOREIGN KEY ("hostForeignMinisterId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TreatyClause" ADD CONSTRAINT "TreatyClause_lockedById_fkey" FOREIGN KEY ("lockedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TreatyDepartment" ADD CONSTRAINT "TreatyDepartment_treatyId_fkey" FOREIGN KEY ("treatyId") REFERENCES "Treaty"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TreatyDepartment" ADD CONSTRAINT "TreatyDepartment_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES "Department"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TreatyDepartment" ADD CONSTRAINT "TreatyDepartment_invitedById_fkey" FOREIGN KEY ("invitedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TreatyDepartment" ADD CONSTRAINT "TreatyDepartment_respondedById_fkey" FOREIGN KEY ("respondedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BreachVerdict" ADD CONSTRAINT "BreachVerdict_breachCaseId_fkey" FOREIGN KEY ("breachCaseId") REFERENCES "BreachCase"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BreachVerdict" ADD CONSTRAINT "BreachVerdict_treatyId_fkey" FOREIGN KEY ("treatyId") REFERENCES "Treaty"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BreachVerdict" ADD CONSTRAINT "BreachVerdict_proposedById_fkey" FOREIGN KEY ("proposedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BreachVerdictVote" ADD CONSTRAINT "BreachVerdictVote_verdictId_fkey" FOREIGN KEY ("verdictId") REFERENCES "BreachVerdict"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BreachVerdictVote" ADD CONSTRAINT "BreachVerdictVote_voterUserId_fkey" FOREIGN KEY ("voterUserId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BreachVerdictVote" ADD CONSTRAINT "BreachVerdictVote_voterDepartmentId_fkey" FOREIGN KEY ("voterDepartmentId") REFERENCES "Department"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
