import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final Widget body;
  final String currentRoute;
  final Function(String) onNavigate;
  final String? userName;
  final String? userEmail;
  final VoidCallback? onLogout;

  const MainLayout({
    super.key,
    required this.body,
    required this.currentRoute,
    required this.onNavigate,
    this.userName,
    this.userEmail,
    this.onLogout,
  });

  static const Color primaryRed = Color(0xFFDC2626);
  static const Color primaryBrown = Color(0xFF7C2D12);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            height: double.infinity,
            color: primaryBrown,
            child: Semantics(
              label: 'Menu de navegação principal',
              child: Column(
                children: [
                  // App Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_pizza,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'PitFlutter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(
                    color: Colors.white24,
                    thickness: 1,
                  ),
                  
                  // Navigation Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: [
                        _buildNavigationItem(
                          context,
                          icon: Icons.receipt_long,
                          title: 'Pedidos',
                          route: '/pedidos',
                        ),
                        _buildNavigationItem(
                          context,
                          icon: Icons.restaurant_menu,
                          title: 'Produtos',
                          route: '/produtos',
                        ),
                        _buildNavigationItem(
                          context,
                          icon: Icons.people,
                          title: 'Clientes',
                          route: '/clientes',
                        ),
                        _buildNavigationItem(
                          context,
                          icon: Icons.inventory,
                          title: 'Estoque',
                          route: '/estoque',
                        ),
                        _buildNavigationItem(
                          context,
                          icon: Icons.attach_money,
                          title: 'Financeiro',
                          route: '/financeiro',
                        ),
                        const SizedBox(height: 16),
                        const Divider(
                          color: Colors.white24,
                          thickness: 1,
                        ),
                        const SizedBox(height: 16),
                        _buildNavigationItem(
                          context,
                          icon: Icons.settings,
                          title: 'Configurações',
                          route: '/configuracoes',
                        ),
                      ],
                    ),
                  ),
                  
                  // User Info Section
                  if (userName != null || userEmail != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.white24,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (userName != null)
                                      Text(
                                        userName!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    if (userEmail != null)
                                      Text(
                                        userEmail!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (onLogout != null)
                                IconButton(
                                  onPressed: onLogout,
                                  icon: const Icon(
                                    Icons.logout,
                                    color: Colors.white70,
                                  ),
                                  tooltip: 'Sair',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Main Content
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isSelected = currentRoute == route;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? primaryRed.withOpacity(0.2) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontFamily: 'Inter',
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.white,
        onTap: () => onNavigate(route),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Extension to help with responsive behavior
extension ResponsiveMainLayout on MainLayout {
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }
}