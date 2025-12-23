/* eslint-disable no-console */
import { PrismaClient, Role, OrderStatus } from '@prisma/client';
import * as argon2 from 'argon2';

const prisma = new PrismaClient();

// Coordenadas de Lisboa (centro/Alameda)
const LISBON_CENTER = { lat: 38.7369, lng: -9.1377 };

async function seed() {
  console.info('🌱 Seeding OhMyFood database...');

  // Limpar dados existentes (opcional - comentar em produção)
  // await prisma.orderItem.deleteMany();
  // await prisma.order.deleteMany();
  // await prisma.menuItem.deleteMany();
  // await prisma.restaurant.deleteMany();
  // await prisma.user.deleteMany();

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

  // ============================================
  // RESTAURANTE 1: Tasca do Bairro (ligado ao restaurantUser)
  // ============================================
  await prisma.restaurant.upsert({
    where: { id: 'demo-restaurant' },
    update: { active: true, userId: restaurantUser.id },
    create: {
      id: 'demo-restaurant',
      userId: restaurantUser.id,
      name: 'Tasca do Bairro',
      description: 'Petiscos lisboetas preparados com carinho. Ideal para partilhar com amigos.',
      imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
      lat: LISBON_CENTER.lat + 0.005,
      lng: LISBON_CENTER.lng + 0.003,
      active: true,
      categories: ['Português', 'Tradicional', 'Petiscos'],
      averagePrepMin: 18,
      menuItems: {
        create: [
          {
            name: 'Bitoque Clássico',
            description: 'Vaca grelhada, ovo estrelado, batata frita e arroz.',
            priceCents: 950,
            imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400',
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
            imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
          },
          {
            name: 'Frango Piri-Piri',
            description: 'Frango grelhado com molho piri-piri caseiro.',
            priceCents: 1050,
            imageUrl: 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400',
          },
          {
            name: 'Prego no Pão',
            description: 'Bife grelhado no pão alentejano com manteiga de alho.',
            priceCents: 650,
            imageUrl: 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=400',
          },
          {
            name: 'Pastel de Nata',
            description: 'Doce tradicional com massa folhada crocante.',
            priceCents: 180,
            imageUrl: 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=400',
          },
          {
            name: 'Arroz Doce',
            description: 'Arroz doce tradicional com canela.',
            priceCents: 320,
            imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400',
          },
          {
            name: 'Sopa de Legumes',
            description: 'Sopa caseira com legumes frescos.',
            priceCents: 450,
            imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400',
          },
          {
            name: 'Salada Mista',
            description: 'Salada fresca com tomate, alface, cebola e azeite.',
            priceCents: 580,
            imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
          },
          {
            name: 'Água 0.5L',
            description: 'Água mineral natural.',
            priceCents: 120,
          },
          {
            name: 'Sumo Natural Laranja',
            description: 'Sumo de laranja fresco espremido.',
            priceCents: 280,
          },
        ],
      },
    },
  });

  // ============================================
  // RESTAURANTE 2: Mercado Fresco
  // ============================================
  await prisma.restaurant.upsert({
    where: { id: 'mercado-fresco' },
    update: { active: true },
    create: {
      id: 'mercado-fresco',
      name: 'Mercado Fresco',
      description: 'Produtos frescos e biológicos entregues em casa.',
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
      lat: LISBON_CENTER.lat - 0.003,
      lng: LISBON_CENTER.lng + 0.002,
      active: true,
      categories: ['Mercearia', 'Bio', 'Saudável'],
      averagePrepMin: 10,
      menuItems: {
        create: [
          {
            name: 'Cabaz Bio Lisboa',
            description: 'Frutas e legumes locais para a semana.',
            priceCents: 1590,
            imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
          },
          {
            name: 'Granola Artesanal',
            description: 'Granola com frutos secos e mel.',
            priceCents: 690,
            imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400',
          },
          {
            name: 'Pão Integral Caseiro',
            description: 'Pão integral feito com farinha biológica.',
            priceCents: 450,
            imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
          },
          {
            name: 'Azeite Extra Virgem',
            description: 'Azeite biológico 500ml.',
            priceCents: 890,
            imageUrl: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400',
          },
          {
            name: 'Mel de Rosmaninho',
            description: 'Mel artesanal 250g.',
            priceCents: 750,
            imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400',
          },
          {
            name: 'Iogurte Natural Bio',
            description: 'Iogurte natural biológico 500g.',
            priceCents: 320,
            imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',
          },
          {
            name: 'Queijo de Cabra',
            description: 'Queijo de cabra artesanal 200g.',
            priceCents: 580,
            imageUrl: 'https://images.unsplash.com/photo-1618164436269-1f3a0e5a6943?w=400',
          },
          {
            name: 'Fruta da Época',
            description: 'Seleção de fruta fresca da época.',
            priceCents: 450,
            imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400',
          },
          {
            name: 'Legumes Orgânicos',
            description: 'Seleção de legumes orgânicos frescos.',
            priceCents: 520,
            imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
          },
          {
            name: 'Chá Verde Bio',
            description: 'Chá verde biológico 20 saquetas.',
            priceCents: 380,
            imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400',
          },
        ],
      },
    },
  });

  // ============================================
  // RESTAURANTE 3: Farmácia Lisboa 24h
  // ============================================
  await prisma.restaurant.upsert({
    where: { id: 'farmacia-lisboa' },
    update: { active: true },
    create: {
      id: 'farmacia-lisboa',
      name: 'Farmácia Lisboa 24h',
      description: 'Medicamentos e produtos de saúde 24/7.',
      imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=800',
      lat: LISBON_CENTER.lat + 0.002,
      lng: LISBON_CENTER.lng - 0.004,
      active: true,
      categories: ['Farmácia', 'Saúde', '24h'],
      averagePrepMin: 8,
      menuItems: {
        create: [
          {
            name: 'Kit Constipação',
            description: 'Analgesia, vitamina C e spray nasal.',
            priceCents: 1490,
            imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
          },
          {
            name: 'Pack Testes Antigénio',
            description: '5 testes rápidos aprovados pela DGS.',
            priceCents: 990,
            imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400',
          },
          {
            name: 'Paracetamol 500mg',
            description: 'Paracetamol 20 comprimidos.',
            priceCents: 320,
            imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
          },
          {
            name: 'Ibuprofeno 400mg',
            description: 'Ibuprofeno 20 comprimidos.',
            priceCents: 380,
            imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
          },
          {
            name: 'Vitamina D3',
            description: 'Suplemento de vitamina D3 60 cápsulas.',
            priceCents: 1250,
            imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400',
          },
          {
            name: 'Protetor Solar FPS 50',
            description: 'Protetor solar facial 50ml.',
            priceCents: 1890,
            imageUrl: 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400',
          },
          {
            name: 'Desinfetante Mãos',
            description: 'Gel desinfetante 500ml.',
            priceCents: 450,
            imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400',
          },
          {
            name: 'Termómetro Digital',
            description: 'Termómetro digital infravermelho.',
            priceCents: 1590,
            imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400',
          },
          {
            name: 'Máscaras Cirúrgicas',
            description: 'Pack 50 máscaras cirúrgicas.',
            priceCents: 890,
            imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400',
          },
          {
            name: 'Água Oxigenada',
            description: 'Água oxigenada 200ml.',
            priceCents: 280,
            imageUrl: 'https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400',
          },
        ],
      },
    },
  });

  // ============================================
  // RESTAURANTE 4: Pizza Express Lisboa
  // ============================================
  await prisma.restaurant.upsert({
    where: { id: 'pizza-express' },
    update: { active: true },
    create: {
      id: 'pizza-express',
      name: 'Pizza Express Lisboa',
      description: 'Pizzas artesanais com ingredientes frescos e massa fina.',
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800',
      lat: LISBON_CENTER.lat - 0.004,
      lng: LISBON_CENTER.lng - 0.002,
      active: true,
      categories: ['Pizza', 'Italiana', 'Rápida'],
      averagePrepMin: 20,
      menuItems: {
        create: [
          {
            name: 'Pizza Margherita',
            description: 'Molho de tomate, mozzarella e manjericão fresco.',
            priceCents: 890,
            imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
            optionGroups: {
              create: [
                {
                  name: 'Tamanho',
                  minSelect: 1,
                  maxSelect: 1,
                  options: {
                    create: [
                      { name: 'Pequena (25cm)', priceCents: 0 },
                      { name: 'Média (30cm)', priceCents: 200 },
                      { name: 'Grande (35cm)', priceCents: 400 },
                    ],
                  },
                },
              ],
            },
          },
          {
            name: 'Pizza Pepperoni',
            description: 'Molho de tomate, mozzarella e pepperoni.',
            priceCents: 1050,
            imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=400',
          },
          {
            name: 'Pizza Quatro Queijos',
            description: 'Mozzarella, gorgonzola, parmesão e queijo de cabra.',
            priceCents: 1150,
            imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
          },
          {
            name: 'Pizza Vegetariana',
            description: 'Pimentos, cebola, cogumelos, azeitonas e tomate.',
            priceCents: 980,
            imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
          },
          {
            name: 'Pizza Frango BBQ',
            description: 'Frango grelhado, molho BBQ, cebola roxa e mozzarella.',
            priceCents: 1250,
            imageUrl: 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=400',
          },
          {
            name: 'Pizza Havaiana',
            description: 'Fiambre, ananás, mozzarella e molho de tomate.',
            priceCents: 1100,
            imageUrl: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400',
          },
          {
            name: 'Bruschetta',
            description: 'Pão tostado com tomate, alho e manjericão.',
            priceCents: 580,
            imageUrl: 'https://images.unsplash.com/photo-1572441713132-51c75654db73?w=400',
          },
          {
            name: 'Salada Caesar',
            description: 'Alface, frango grelhado, croutons e molho caesar.',
            priceCents: 750,
            imageUrl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=400',
          },
          {
            name: 'Coca-Cola 330ml',
            description: 'Refrigerante gelado.',
            priceCents: 250,
          },
          {
            name: 'Água 500ml',
            description: 'Água mineral natural.',
            priceCents: 120,
          },
        ],
      },
    },
  });

  // ============================================
  // RESTAURANTE 5: Sushi Master
  // ============================================
  await prisma.restaurant.upsert({
    where: { id: 'sushi-master' },
    update: { active: true },
    create: {
      id: 'sushi-master',
      name: 'Sushi Master',
      description: 'Sushi fresco preparado diariamente com peixe de qualidade.',
      imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=800',
      lat: LISBON_CENTER.lat + 0.003,
      lng: LISBON_CENTER.lng + 0.005,
      active: true,
      categories: ['Sushi', 'Japonês', 'Peixe'],
      averagePrepMin: 25,
      menuItems: {
        create: [
          {
            name: 'Sashimi Mix',
            description: 'Seleção de 12 peças de sashimi variado.',
            priceCents: 1890,
            imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
          },
          {
            name: 'Sushi Mix 16 Peças',
            description: '16 peças de sushi variado com salmão, atum e camarão.',
            priceCents: 2250,
            imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
          },
          {
            name: 'California Roll',
            description: '8 peças de california roll com salmão e abacate.',
            priceCents: 890,
            imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
          },
          {
            name: 'Temaki Salmão',
            description: 'Cone de alga com salmão, arroz e vegetais.',
            priceCents: 650,
            imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
          },
          {
            name: 'Ramen de Frango',
            description: 'Sopa ramen com frango, ovo e vegetais.',
            priceCents: 1250,
            imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
          },
          {
            name: 'Gyoza',
            description: '6 peças de gyoza frito com molho de soja.',
            priceCents: 750,
            imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
          },
          {
            name: 'Edamame',
            description: 'Vagens de soja cozidas com sal.',
            priceCents: 450,
            imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
          },
          {
            name: 'Miso Soup',
            description: 'Sopa de miso tradicional.',
            priceCents: 380,
            imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
          },
          {
            name: 'Chá Verde',
            description: 'Chá verde japonês quente.',
            priceCents: 280,
            imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400',
          },
          {
            name: 'Água 500ml',
            description: 'Água mineral natural.',
            priceCents: 120,
          },
        ],
      },
    },
  });

  // ============================================
  // COURIER USER + ENTITY
  // ============================================
  const courierPassword = await argon2.hash('courier123');
  const courierUser = await prisma.user.upsert({
    where: { email: 'courier@ohmyfood.pt' },
    update: {},
    create: {
      email: 'courier@ohmyfood.pt',
      passwordHash: courierPassword,
      role: Role.COURIER,
      displayName: 'Estafeta Teste',
    },
  });

  await prisma.courier.upsert({
    where: { userId: courierUser.id },
    update: { isVerified: true, online: true },
    create: {
      userId: courierUser.id,
      isVerified: true,
      online: true,
      location: {
        create: {
          lat: LISBON_CENTER.lat,
          lng: LISBON_CENTER.lng,
        },
      },
    },
  });

  // ============================================
  // ADDRESS PARA CUSTOMER
  // ============================================
  await prisma.address.upsert({
    where: { id: 'customer-address-1' },
    update: {},
    create: {
      id: 'customer-address-1',
      userId: customer.id,
      label: 'Casa',
      street: 'Rua da Alameda',
      number: '123',
      complement: '2º Esquerdo',
      postalCode: '1000-001',
      city: 'Lisboa',
      country: 'Portugal',
      lat: LISBON_CENTER.lat,
      lng: LISBON_CENTER.lng,
      isDefault: true,
      instructions: 'Tocar à campainha do 2º esquerdo',
    },
  });

  // ============================================
  // ORDERS DE TESTE
  // ============================================
  // Buscar menu items do demo-restaurant
  const menuItems = await prisma.menuItem.findMany({
    where: { restaurantId: 'demo-restaurant' },
    take: 3,
  });

  if (menuItems.length >= 2) {
    // Order A: Novo (para aceitar no restaurant)
    await prisma.order.create({
      data: {
        userId: customer.id,
        restaurantId: 'demo-restaurant',
        status: OrderStatus.AWAITING_ACCEPTANCE,
        itemsTotal: 2850, // 3 itens
        deliveryFee: 200,
        serviceFee: 150,
        total: 3200,
        items: {
          create: [
            {
              menuItemId: menuItems[0].id,
              name: menuItems[0].name,
              quantity: 2,
              unitPrice: menuItems[0].priceCents,
            },
            {
              menuItemId: menuItems[1].id,
              name: menuItems[1].name,
              quantity: 1,
              unitPrice: menuItems[1].priceCents,
            },
          ],
        },
        statusHistory: [
          { status: OrderStatus.DRAFT, timestamp: new Date().toISOString() },
          { status: OrderStatus.AWAITING_ACCEPTANCE, timestamp: new Date().toISOString() },
        ],
      },
    });

    // Order B: Em estado intermediário (PREPARING)
    await prisma.order.create({
      data: {
        userId: customer.id,
        restaurantId: 'demo-restaurant',
        status: OrderStatus.PREPARING,
        itemsTotal: menuItems[2]?.priceCents || 1050,
        deliveryFee: 200,
        serviceFee: 100,
        total: (menuItems[2]?.priceCents || 1050) + 200 + 100,
        items: {
          create: [
            {
              menuItemId: menuItems[2]?.id || menuItems[0].id,
              name: menuItems[2]?.name || menuItems[0].name,
              quantity: 1,
              unitPrice: menuItems[2]?.priceCents || 1050,
            },
          ],
        },
        statusHistory: [
          { status: OrderStatus.DRAFT, timestamp: new Date(Date.now() - 3600000).toISOString() },
          { status: OrderStatus.AWAITING_ACCEPTANCE, timestamp: new Date(Date.now() - 3000000).toISOString() },
          { status: OrderStatus.PREPARING, timestamp: new Date(Date.now() - 1800000).toISOString() },
        ],
      },
    });
  }

  console.info('✅ Seeding concluído.');
  console.info(`\n📧 Credenciais de teste:`);
  console.info(`Admin: ${admin.email} / admin123`);
  console.info(`Restaurante: restaurante@ohmyfood.pt / restaurant123`);
  console.info(`Cliente: cliente@ohmyfood.pt / customer123`);
  console.info(`Estafeta: courier@ohmyfood.pt / courier123`);
  console.info(`\n🍽️  Restaurantes criados: 5`);
  console.info(`📦 Itens de menu criados: ~50`);
  console.info(`🚴 Estafeta criado: 1`);
  console.info(`📍 Moradas criadas: 1`);
  console.info(`📋 Pedidos criados: 2`);
}

seed()
  .catch((error) => {
    console.error('❌ Seed falhou', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
