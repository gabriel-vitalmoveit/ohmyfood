/* eslint-disable no-console */
import { PrismaClient, Role } from '@prisma/client';
import * as argon2 from 'argon2';

const prisma = new PrismaClient();

async function seed() {
  console.info('🌱 Seeding OhMyFood database...');

  const adminPassword = await argon2.hash('admin123');

  const admin = await prisma.user.upsert({
    where: { email: 'admin@ohmyfood.pt' },
    update: {},
    create: {
      email: 'admin@ohmyfood.pt',
      passwordHash: adminPassword,
      role: Role.ADMIN,
      displayName: 'Admin OhMyFood',
    },
  });

  const restaurantOwnerPassword = await argon2.hash('restaurant123');
  const restaurantUser = await prisma.user.upsert({
    where: { email: 'restaurante@ohmyfood.pt' },
    update: {},
    create: {
      email: 'restaurante@ohmyfood.pt',
      passwordHash: restaurantOwnerPassword,
      role: Role.RESTAURANT,
      displayName: 'Restaurante Lisboa',
    },
  });

  await prisma.restaurant.upsert({
    where: { id: 'demo-restaurant' },
    update: {},
    create: {
      id: 'demo-restaurant',
      userId: restaurantUser.id,
      name: 'Tasca do Bairro',
      description:
        'Petiscos lisboetas preparados com carinho. Ideal para partilhar com amigos.',
      lat: 38.7223,
      lng: -9.1393,
      active: true,
      categories: ['restaurantes', 'portugues'],
      averagePrepMin: 18,
      menuItems: {
        create: [
          {
            name: 'Bitoque Clássico',
            description: 'Vaca grelhada, ovo estrelado, batata frita e arroz.',
            priceCents: 950,
            optionGroups: {
              create: [
                {
                  name: 'Ponto da Carne',
                  minSelect: 1,
                  maxSelect: 1,
                  options: {
                    create: [
                      { name: 'Mal Passado', priceCents: 0 },
                      { name: 'Médio', priceCents: 0 },
                      { name: 'Bem Passado', priceCents: 0 },
                    ],
                  },
                },
              ],
            },
          },
          {
            name: 'Pastel de Nata',
            description: 'Doce tradicional com massa folhada crocante.',
            priceCents: 180,
          },
        ],
      },
    },
  });

  console.info('✅ Seeding concluído.');
  console.info(`Admin login: ${admin.email} / admin123`);
}

seed()
  .catch((error) => {
    console.error('❌ Seed falhou', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
