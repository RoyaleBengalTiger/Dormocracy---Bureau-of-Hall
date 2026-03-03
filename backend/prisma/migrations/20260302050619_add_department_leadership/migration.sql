-- AlterTable
ALTER TABLE "Department" ADD COLUMN     "foreignMinisterId" TEXT,
ADD COLUMN     "primeMinisterId" TEXT;

-- CreateIndex
CREATE INDEX "Department_primeMinisterId_idx" ON "Department"("primeMinisterId");

-- CreateIndex
CREATE INDEX "Department_foreignMinisterId_idx" ON "Department"("foreignMinisterId");

-- AddForeignKey
ALTER TABLE "Department" ADD CONSTRAINT "Department_primeMinisterId_fkey" FOREIGN KEY ("primeMinisterId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Department" ADD CONSTRAINT "Department_foreignMinisterId_fkey" FOREIGN KEY ("foreignMinisterId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
