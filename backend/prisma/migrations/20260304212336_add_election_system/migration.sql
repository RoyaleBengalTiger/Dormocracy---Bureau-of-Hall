/*
  Warnings:

  - A unique constraint covering the columns `[departmentSenateId]` on the table `ChatRoom` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateEnum
CREATE TYPE "ElectionType" AS ENUM ('ROOM', 'DEPARTMENT');

-- CreateEnum
CREATE TYPE "ElectionStatus" AS ENUM ('ACTIVE', 'COMPLETED', 'TIE_BREAKING');

-- AlterEnum
ALTER TYPE "ChatRoomType" ADD VALUE 'SENATE';

-- AlterTable
ALTER TABLE "ChatRoom" ADD COLUMN     "departmentSenateId" TEXT;

-- CreateTable
CREATE TABLE "Election" (
    "id" TEXT NOT NULL,
    "type" "ElectionType" NOT NULL,
    "status" "ElectionStatus" NOT NULL DEFAULT 'ACTIVE',
    "roomId" TEXT,
    "departmentId" TEXT,
    "deadline" TIMESTAMP(3) NOT NULL,
    "winnerId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Election_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ElectionCandidate" (
    "id" TEXT NOT NULL,
    "electionId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "totalVotePower" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "ElectionCandidate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ElectionVote" (
    "id" TEXT NOT NULL,
    "electionId" TEXT NOT NULL,
    "voterId" TEXT NOT NULL,
    "candidateId" TEXT NOT NULL,
    "votePower" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ElectionVote_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Election_roomId_idx" ON "Election"("roomId");

-- CreateIndex
CREATE INDEX "Election_departmentId_idx" ON "Election"("departmentId");

-- CreateIndex
CREATE INDEX "Election_status_idx" ON "Election"("status");

-- CreateIndex
CREATE INDEX "ElectionCandidate_electionId_idx" ON "ElectionCandidate"("electionId");

-- CreateIndex
CREATE UNIQUE INDEX "ElectionCandidate_electionId_userId_key" ON "ElectionCandidate"("electionId", "userId");

-- CreateIndex
CREATE INDEX "ElectionVote_electionId_idx" ON "ElectionVote"("electionId");

-- CreateIndex
CREATE INDEX "ElectionVote_candidateId_idx" ON "ElectionVote"("candidateId");

-- CreateIndex
CREATE UNIQUE INDEX "ElectionVote_electionId_voterId_key" ON "ElectionVote"("electionId", "voterId");

-- CreateIndex
CREATE UNIQUE INDEX "ChatRoom_departmentSenateId_key" ON "ChatRoom"("departmentSenateId");

-- AddForeignKey
ALTER TABLE "ChatRoom" ADD CONSTRAINT "ChatRoom_departmentSenateId_fkey" FOREIGN KEY ("departmentSenateId") REFERENCES "Department"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Election" ADD CONSTRAINT "Election_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES "Room"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Election" ADD CONSTRAINT "Election_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES "Department"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Election" ADD CONSTRAINT "Election_winnerId_fkey" FOREIGN KEY ("winnerId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ElectionCandidate" ADD CONSTRAINT "ElectionCandidate_electionId_fkey" FOREIGN KEY ("electionId") REFERENCES "Election"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ElectionCandidate" ADD CONSTRAINT "ElectionCandidate_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ElectionVote" ADD CONSTRAINT "ElectionVote_electionId_fkey" FOREIGN KEY ("electionId") REFERENCES "Election"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ElectionVote" ADD CONSTRAINT "ElectionVote_voterId_fkey" FOREIGN KEY ("voterId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ElectionVote" ADD CONSTRAINT "ElectionVote_candidateId_fkey" FOREIGN KEY ("candidateId") REFERENCES "ElectionCandidate"("id") ON DELETE CASCADE ON UPDATE CASCADE;
