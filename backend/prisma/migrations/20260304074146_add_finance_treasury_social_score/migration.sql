-- CreateEnum
CREATE TYPE "TreasuryTransactionType" AS ENUM ('DEPT_ALLOCATE_TO_ROOM', 'DEPT_RECALL_FROM_ROOM', 'ROOM_TASK_SPEND', 'USER_BUY_SOCIAL_SCORE');

-- CreateEnum
CREATE TYPE "SocialScorePurchaseStatus" AS ENUM ('REQUESTED', 'OFFERED', 'ACCEPTED', 'REJECTED', 'CANCELLED');

-- AlterTable
ALTER TABLE "Department" ADD COLUMN     "financeMinisterId" TEXT,
ADD COLUMN     "treasuryCredits" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "Room" ADD COLUMN     "treasuryCredits" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "Task" ADD COLUMN     "fundAmount" INTEGER NOT NULL DEFAULT 0;

-- CreateTable
CREATE TABLE "TreasuryTransaction" (
    "id" TEXT NOT NULL,
    "type" "TreasuryTransactionType" NOT NULL,
    "amount" INTEGER NOT NULL,
    "departmentId" TEXT,
    "roomId" TEXT,
    "taskId" TEXT,
    "userId" TEXT,
    "createdById" TEXT NOT NULL,
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TreasuryTransaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SocialScorePurchaseRequest" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "departmentId" TEXT NOT NULL,
    "status" "SocialScorePurchaseStatus" NOT NULL DEFAULT 'REQUESTED',
    "requestNote" TEXT,
    "offeredById" TEXT,
    "offeredPriceCredits" INTEGER,
    "offeredSocialScore" INTEGER,
    "offeredAt" TIMESTAMP(3),
    "respondedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SocialScorePurchaseRequest_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "TreasuryTransaction_departmentId_createdAt_idx" ON "TreasuryTransaction"("departmentId", "createdAt");

-- CreateIndex
CREATE INDEX "TreasuryTransaction_roomId_createdAt_idx" ON "TreasuryTransaction"("roomId", "createdAt");

-- CreateIndex
CREATE INDEX "TreasuryTransaction_type_createdAt_idx" ON "TreasuryTransaction"("type", "createdAt");

-- CreateIndex
CREATE INDEX "TreasuryTransaction_createdById_idx" ON "TreasuryTransaction"("createdById");

-- CreateIndex
CREATE INDEX "SocialScorePurchaseRequest_status_createdAt_idx" ON "SocialScorePurchaseRequest"("status", "createdAt");

-- CreateIndex
CREATE INDEX "SocialScorePurchaseRequest_departmentId_idx" ON "SocialScorePurchaseRequest"("departmentId");

-- CreateIndex
CREATE INDEX "SocialScorePurchaseRequest_userId_idx" ON "SocialScorePurchaseRequest"("userId");

-- CreateIndex
CREATE INDEX "Department_financeMinisterId_idx" ON "Department"("financeMinisterId");

-- AddForeignKey
ALTER TABLE "Department" ADD CONSTRAINT "Department_financeMinisterId_fkey" FOREIGN KEY ("financeMinisterId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TreasuryTransaction" ADD CONSTRAINT "TreasuryTransaction_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES "Department"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TreasuryTransaction" ADD CONSTRAINT "TreasuryTransaction_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES "Room"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TreasuryTransaction" ADD CONSTRAINT "TreasuryTransaction_taskId_fkey" FOREIGN KEY ("taskId") REFERENCES "Task"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TreasuryTransaction" ADD CONSTRAINT "TreasuryTransaction_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialScorePurchaseRequest" ADD CONSTRAINT "SocialScorePurchaseRequest_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialScorePurchaseRequest" ADD CONSTRAINT "SocialScorePurchaseRequest_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES "Department"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialScorePurchaseRequest" ADD CONSTRAINT "SocialScorePurchaseRequest_offeredById_fkey" FOREIGN KEY ("offeredById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
