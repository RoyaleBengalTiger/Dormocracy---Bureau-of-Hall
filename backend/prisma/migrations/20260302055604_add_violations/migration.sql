-- CreateTable
CREATE TABLE "Violation" (
    "id" TEXT NOT NULL,
    "roomId" TEXT NOT NULL,
    "offenderId" TEXT NOT NULL,
    "createdById" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "points" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Violation_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Violation_roomId_createdAt_idx" ON "Violation"("roomId", "createdAt");

-- CreateIndex
CREATE INDEX "Violation_offenderId_createdAt_idx" ON "Violation"("offenderId", "createdAt");

-- CreateIndex
CREATE INDEX "Violation_createdById_idx" ON "Violation"("createdById");

-- AddForeignKey
ALTER TABLE "Violation" ADD CONSTRAINT "Violation_roomId_fkey" FOREIGN KEY ("roomId") REFERENCES "Room"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Violation" ADD CONSTRAINT "Violation_offenderId_fkey" FOREIGN KEY ("offenderId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Violation" ADD CONSTRAINT "Violation_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
