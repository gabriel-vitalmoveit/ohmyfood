import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const routeName = 'landing';

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'OhMyFood',
                style: OhMyFoodTypography.titleLg.copyWith(
                  color: OhMyFoodColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            actions: [
              if (isDesktop) ...[
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Entrar',
                    style: OhMyFoodTypography.bodyBold.copyWith(
                      color: OhMyFoodColors.neutral600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => context.go('/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OhMyFoodColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Criar Conta'),
                ),
                const SizedBox(width: 24),
              ] else
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => _showMobileMenu(context),
                ),
            ],
          ),

          // Hero Section
          SliverToBoxAdapter(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              margin: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : 24,
                vertical: isDesktop ? 80 : 40,
              ),
              child: isDesktop || isTablet
                  ? _DesktopHero()
                  : _MobileHero(),
            ),
          ),

          // Features Section
          SliverToBoxAdapter(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              margin: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : 24,
                vertical: 60,
              ),
              child: _FeaturesSection(isDesktop: isDesktop),
            ),
          ),

          // CTA Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 60),
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    OhMyFoodColors.primary,
                    OhMyFoodColors.primaryDark,
                  ],
                ),
              ),
              child: _CTASection(isDesktop: isDesktop),
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              color: OhMyFoodColors.neutral100,
              child: const _Footer(),
            ),
          ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Entrar'),
              onTap: () {
                Navigator.pop(context);
                context.go('/login');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Criar Conta'),
              onTap: () {
                Navigator.pop(context);
                context.go('/register');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Entregas deliciosas\nna tua porta',
                style: OhMyFoodTypography.displayLg.copyWith(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: OhMyFoodColors.neutral900,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Restaurantes, mercearias e farmácias num só lugar.\nEntregas rápidas em toda Lisboa.',
                style: OhMyFoodTypography.body.copyWith(
                  fontSize: 20,
                  color: OhMyFoodColors.neutral600,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OhMyFoodColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Começar Agora',
                      style: OhMyFoodTypography.bodyBold.copyWith(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () => context.go('/login'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: OhMyFoodColors.primary,
                      side: const BorderSide(
                        color: OhMyFoodColors.primary,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Entrar',
                      style: OhMyFoodTypography.bodyBold.copyWith(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
        Expanded(
          child: Container(
            height: 500,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  OhMyFoodColors.primarySoft,
                  OhMyFoodColors.primary.withOpacity(0.3),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.delivery_dining_rounded,
                size: 200,
                color: OhMyFoodColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                OhMyFoodColors.primarySoft,
                OhMyFoodColors.primary.withOpacity(0.3),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.delivery_dining_rounded,
              size: 120,
              color: OhMyFoodColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Entregas deliciosas\nna tua porta',
          style: OhMyFoodTypography.displayLg.copyWith(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: OhMyFoodColors.neutral900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Restaurantes, mercearias e farmácias num só lugar. Entregas rápidas em toda Lisboa.',
          style: OhMyFoodTypography.body.copyWith(
            fontSize: 16,
            color: OhMyFoodColors.neutral600,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: OhMyFoodColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Começar Agora'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go('/login'),
            style: OutlinedButton.styleFrom(
              foregroundColor: OhMyFoodColors.primary,
              side: const BorderSide(
                color: OhMyFoodColors.primary,
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Entrar'),
          ),
        ),
      ],
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final features = [
      _Feature(
        icon: Icons.restaurant,
        title: 'Restaurantes',
        description: 'Milhares de opções gastronómicas ao teu alcance',
      ),
      _Feature(
        icon: Icons.local_grocery_store,
        title: 'Mercearias',
        description: 'Produtos frescos e essenciais entregues em casa',
      ),
      _Feature(
        icon: Icons.local_pharmacy,
        title: 'Farmácias',
        description: 'Medicamentos e produtos de saúde 24/7',
      ),
      _Feature(
        icon: Icons.track_changes,
        title: 'Tracking em Tempo Real',
        description: 'Acompanha a tua encomenda a cada momento',
      ),
      _Feature(
        icon: Icons.payment,
        title: 'Pagamentos Seguros',
        description: 'MB WAY, cartão ou Multibanco - tu escolhes',
      ),
      _Feature(
        icon: Icons.speed,
        title: 'Entregas Rápidas',
        description: 'Recebe em minutos, não em horas',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Porquê escolher OhMyFood?',
          style: OhMyFoodTypography.titleLg.copyWith(
            fontSize: isDesktop ? 40 : 32,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        isDesktop
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.1,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) => features[index],
              )
            : Column(
                children: features
                    .map((feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: feature,
                        ))
                    .toList(),
              ),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: OhMyFoodColors.neutral200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: OhMyFoodColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: OhMyFoodColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: OhMyFoodTypography.titleMd.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: OhMyFoodTypography.body.copyWith(
              color: OhMyFoodColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CTASection extends StatelessWidget {
  const _CTASection({required this.isDesktop});

  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Pronto para começar?',
            style: OhMyFoodTypography.titleLg.copyWith(
              fontSize: isDesktop ? 40 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Junta-te a milhares de clientes satisfeitos em Lisboa',
            style: OhMyFoodTypography.body.copyWith(
              fontSize: isDesktop ? 20 : 18,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: OhMyFoodColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Criar Conta Grátis',
                    style: OhMyFoodTypography.bodyBold.copyWith(
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => context.go('/login'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Entrar',
                    style: OhMyFoodTypography.bodyBold.copyWith(
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: OhMyFoodColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Criar Conta Grátis'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/login'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Entrar'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'OhMyFood',
                style: OhMyFoodTypography.titleLg.copyWith(
                  color: OhMyFoodColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '© 2025 OhMyFood. Todos os direitos reservados.',
            style: OhMyFoodTypography.caption.copyWith(
              color: OhMyFoodColors.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

