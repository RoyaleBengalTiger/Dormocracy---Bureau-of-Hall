/*
  Swap Exchange buyer/seller role semantics:
  - Creator is now the BUYER (buyerId, required)
  - Acceptor is now the SELLER (sellerId, optional)

  Step 1: Add temp column, swap existing data
  Step 2: Change nullability
  Step 3: Re-add foreign keys with correct ON DELETE behavior
*/

-- Step 1: Swap existing data using a temp column
-- Old sellerId = creator → should become buyerId
-- Old buyerId = acceptor → should become sellerId
ALTER TABLE "Exchange" ADD COLUMN "tmp_sellerId" TEXT;
UPDATE "Exchange" SET "tmp_sellerId" = "sellerId";
UPDATE "Exchange" SET "sellerId" = "buyerId";
UPDATE "Exchange" SET "buyerId" = "tmp_sellerId";
ALTER TABLE "Exchange" DROP COLUMN "tmp_sellerId";

-- Step 2: Drop old foreign keys
ALTER TABLE "Exchange" DROP CONSTRAINT "Exchange_buyerId_fkey";
ALTER TABLE "Exchange" DROP CONSTRAINT "Exchange_sellerId_fkey";

-- Step 3: Change nullability
ALTER TABLE "Exchange" ALTER COLUMN "sellerId" DROP NOT NULL,
ALTER COLUMN "buyerId" SET NOT NULL;

-- Step 4: Re-add foreign keys
ALTER TABLE "Exchange" ADD CONSTRAINT "Exchange_sellerId_fkey" FOREIGN KEY ("sellerId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Exchange" ADD CONSTRAINT "Exchange_buyerId_fkey" FOREIGN KEY ("buyerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
