import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // ✅ Ensures PrismaService.onModuleDestroy() runs on CTRL+C / SIGTERM
  app.enableShutdownHooks();

  await app.listen(Number(process.env.PORT) || 3000);
}
bootstrap();
