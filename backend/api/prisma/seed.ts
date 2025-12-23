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

  // Criar usuário cliente de teste
  const customerPassword = await argon2.hash('customer123');
  const customer = await prisma.user.upsert({
    where: { email: 'cliente@ohmyfood.pt' },
    update: {},
    create: {
      email: 'cliente@ohmyfood.pt',
      passwordHash: customerPassword,
      role: Role.CUSTOMER,
      displayName: 'Cliente Teste',
    },
  });

  // Restaurante 1: Tasca do Bairro
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
      categories: ['restaurantes', 'portugues', 'Tradicional'],
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
            name: 'Bacalhau à Brás',
            description: 'Receita tradicional com batata palha estaladiça.',
            priceCents: 890,
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

  // Restaurante 2: Mercado Fresco
  await prisma.restaurant.upsert({
    where: { id: 'mercado-fresco' },
    update: {},
    create: {
      id: 'mercado-fresco',
      name: 'Mercado Fresco',
      description: 'Produtos frescos e biológicos entregues em casa.',
      lat: 38.7139,
      lng: -9.1366,
      active: true,
      categories: ['Mercearia', 'Bio'],
      averagePrepMin: 10,
      menuItems: {
        create: [
          {
            name: 'Cabaz Bio Lisboa',
            description: 'Frutas e legumes locais para a semana.',
            priceCents: 1590,
          },
          {
            name: 'Granola Artesanal',
            description: 'Granola com frutos secos e mel.',
            priceCents: 690,
          },
        ],
      },
    },
  });

  // Restaurante 3: Farmácia Lisboa 24h
  await prisma.restaurant.upsert({
    where: { id: 'farmacia-lisboa' },
    update: {},
    create: {
      id: 'farmacia-lisboa',
      name: 'Farmácia Lisboa 24h',
      description: 'Medicamentos e produtos de saúde 24/7.',
      lat: 38.7091,
      lng: -9.1333,
      active: true,
      categories: ['Farmácia', 'Saúde'],
      averagePrepMin: 8,
      menuItems: {
        create: [
          {
            name: 'Kit Constipação',
            description: 'Analgesia, vitamina C e spray nasal.',
            priceCents: 1490,
          },
          {
            name: 'Pack Testes Antigénio',
            description: '5 testes rápidos aprovados pela DGS.',
            priceCents: 990,
          },
        ],
      },
    },
  });

  console.info('✅ Seeding concluído.');
  console.info(`\n📧 Credenciais de teste:`);
  console.info(`Admin: ${admin.email} / admin123`);
  console.info(`Restaurante: restaurante@ohmyfood.pt / restaurant123`);
  console.info(`Cliente: cliente@ohmyfood.pt / customer123`);
}

seed()
  .catch((error) => {
    console.error('❌ Seed falhou', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
