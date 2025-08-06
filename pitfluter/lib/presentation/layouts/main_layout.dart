import 'package:flutter/material.dart';
import '../widgets/dashboard_content.dart';
import '../widgets/produtos_content.dart';
import '../widgets/pedidos_content.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  
  final List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      route: '/dashboard',
    ),
    _NavigationItem(
      icon: Icons.receipt_long,
      label: 'Pedidos',
      route: '/pedidos',
    ),
    _NavigationItem(
      icon: Icons.inventory_2,
      label: 'Produtos',
      route: '/produtos',
    ),
    _NavigationItem(
      icon: Icons.point_of_sale,
      label: 'Caixa',
      route: '/caixa',
    ),
    _NavigationItem(
      icon: Icons.history,
      label: 'Histórico',
      route: '/historico-caixas',
    ),
  ];


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar fixa
          Container(
            width: isDesktop ? 250 : 70,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Logo Header
                Container(
                  height: 120,
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_pizza,
                        color: Colors.white,
                        size: isDesktop ? 40 : 32,
                      ),
                      if (isDesktop) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Pizzaria Sistema',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = _navigationItems[index];
                      final isSelected = _selectedIndex == index;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 16 : 12,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                    size: 24,
                                  ),
                                  if (isDesktop) ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item.label,
                                        style: TextStyle(
                                          color: isSelected
                                              ? colorScheme.primary
                                              : colorScheme.onSurfaceVariant,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Bottom Actions
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      if (isDesktop)
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/novo-pedido');
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Novo Pedido'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        )
                      else
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/novo-pedido');
                          },
                          icon: const Icon(Icons.add_circle),
                          iconSize: 32,
                          color: colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content Area - IndexedStack mantém widgets vivos
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                _DashboardContent(),
                _PedidosContent(),
                _ProdutosContent(),
                _CaixaContent(),
                _HistoricoContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  _NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

// Content widget usando o DashboardContent real
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return const DashboardContent();
  }
}

class _PedidosContent extends StatelessWidget {
  const _PedidosContent();

  @override
  Widget build(BuildContext context) {
    return const PedidosContent();
  }
}

class _ProdutosContent extends StatelessWidget {
  const _ProdutosContent();

  @override
  Widget build(BuildContext context) {
    return const ProdutosContent();
  }
}

class _CaixaContent extends StatelessWidget {
  const _CaixaContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Caixa Content'),
    );
  }
}

class _HistoricoContent extends StatelessWidget {
  const _HistoricoContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Histórico Content'),
    );
  }
}