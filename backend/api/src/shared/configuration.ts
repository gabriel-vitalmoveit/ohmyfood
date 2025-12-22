export default () => ({
  port: parseInt(process.env.PORT ?? '3000', 10),
  cors: {
    origin: process.env.CORS_ORIGIN ?? '*',
    allowedOrigins: process.env.CORS_ORIGINS
      ? process.env.CORS_ORIGINS.split(',')
      : [
          'https://ohmyfood.eu',
          'https://www.ohmyfood.eu',
          'https://admin.ohmyfood.eu',
          'https://restaurante.ohmyfood.eu',
          'https://estafeta.ohmyfood.eu',
          'http://localhost:8080',
          'http://localhost:8081',
          'http://localhost:8082',
          'http://localhost:8083',
        ],
  },
  database: {
    url: process.env.DATABASE_URL ?? 'postgresql://postgres:postgres@localhost:5432/ohmyfood',
  },
  redis: {
    url: process.env.REDIS_URL ?? 'redis://localhost:6379',
  },
  jwt: {
    accessSecret: process.env.JWT_ACCESS_SECRET ?? 'changeme',
    refreshSecret: process.env.JWT_REFRESH_SECRET ?? 'changeme-refresh',
    accessTtl: process.env.JWT_ACCESS_TTL ?? '15m',
    refreshTtl: process.env.JWT_REFRESH_TTL ?? '7d',
  },
  stripe: {
    apiKey: process.env.STRIPE_API_KEY ?? '',
    webhookSecret: process.env.STRIPE_WEBHOOK_SECRET ?? '',
  },
  mapbox: {
    apiKey: process.env.MAPBOX_API_KEY ?? '',
  },
  fileStorage: {
    bucketUrl: process.env.FILE_BUCKET_URL ?? '',
  },
});
