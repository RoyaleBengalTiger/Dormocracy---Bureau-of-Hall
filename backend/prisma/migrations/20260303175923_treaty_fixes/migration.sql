/*
  Warnings:

  - The values [DRAFT,PENDING_ACCEPTANCE] on the enum `TreatyStatus` will be removed. If these variants are still used in the database, this will fail.

*/
-- AlterEnum
ALTER TYPE "ParticipantStatus" ADD VALUE 'LEFT';

-- AlterEnum
BEGIN;
CREATE TYPE "TreatyStatus_new" AS ENUM ('NEGOTIATION', 'LOCKED', 'ACTIVE', 'EXPIRED');
ALTER TABLE "public"."Treaty" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "Treaty" ALTER COLUMN "status" TYPE "TreatyStatus_new" USING ("status"::text::"TreatyStatus_new");
ALTER TYPE "TreatyStatus" RENAME TO "TreatyStatus_old";
ALTER TYPE "TreatyStatus_new" RENAME TO "TreatyStatus";
DROP TYPE "public"."TreatyStatus_old";
ALTER TABLE "Treaty" ALTER COLUMN "status" SET DEFAULT 'NEGOTIATION';
COMMIT;

-- AlterTable
ALTER TABLE "Treaty" ALTER COLUMN "status" SET DEFAULT 'NEGOTIATION';
