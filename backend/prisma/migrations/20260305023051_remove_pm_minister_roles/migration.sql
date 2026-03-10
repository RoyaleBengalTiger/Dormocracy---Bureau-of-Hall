/*
  Warnings:

  - The values [MINISTER,PM] on the enum `Role` will be removed. If these variants are still used in the database, this will fail.

*/
-- Data migration: convert existing PM/MINISTER users to MAYOR before removing enum values
UPDATE "User" SET "role" = 'MAYOR' WHERE "role" IN ('PM', 'MINISTER');

-- AlterEnum
BEGIN;
CREATE TYPE "Role_new" AS ENUM ('CITIZEN', 'MAYOR', 'ADMIN');
ALTER TABLE "public"."User" ALTER COLUMN "role" DROP DEFAULT;
ALTER TABLE "User" ALTER COLUMN "role" TYPE "Role_new" USING ("role"::text::"Role_new");
ALTER TYPE "Role" RENAME TO "Role_old";
ALTER TYPE "Role_new" RENAME TO "Role";
DROP TYPE "public"."Role_old";
ALTER TABLE "User" ALTER COLUMN "role" SET DEFAULT 'CITIZEN';
COMMIT;
