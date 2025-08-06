import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  String selectedPeriod = 'Hoje';
  bool isRefreshing = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> periods = ['Hoje', 'Semana', 'Mês'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isRefreshing = false;
    });

    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorScheme.surface,
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(colorScheme),
              ),
              
              // Period Selector
              SliverToBoxAdapter(
                child: _buildPeriodSelector(colorScheme),
              ),
              
              // Metric Cards Grid
              SliverToBoxAdapter(
                child: _buildMetricCards(colorScheme),
              ),
              
              // Charts Row
              SliverToBoxAdapter(
                child: _buildChartsRow(colorScheme),
              ),
              
              // Recent Activity
              SliverToBoxAdapter(
                child: _buildRecentActivity(colorScheme),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/novo-pedido'),
        icon: const Icon(Icons.add),
        label: const Text('Novo Pedido'),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    final now = DateTime.now();
    final greeting = _getGreeting();
    final dateString = _formatDate(now);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row com o botão do menu e o título
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                color: colorScheme.onSurface,
                iconSize: 28,
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            greeting,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateString,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: periods.map((period) {
          final isSelected = period == selectedPeriod;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: FilterChip(
                  label: Text(period),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        selectedPeriod = period;
                      });
                      HapticFeedback.selectionClick();
                    }
                  },
                  selectedColor: const Color(0xFFDC2626).withValues(alpha: 0.1),
                  backgroundColor: colorScheme.surface,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? const Color(0xFFDC2626)
                        : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricCards(ColorScheme colorScheme) {
    final metrics = _getMetricsData();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(3, (index) {
          final metric = metrics[index];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 8,
                right: index == 2 ? 0 : 8,
              ),
              child: _buildMetricCard(metric, colorScheme),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMetricCard(Map<String, dynamic> metric, ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              metric['icon'],
              color: const Color(0xFFDC2626),
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              metric['title'],
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              metric['value'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            if (metric['change'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    metric['changeIcon'],
                    size: 16,
                    color: metric['changeColor'],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    metric['change'],
                    style: TextStyle(
                      fontSize: 12,
                      color: metric['changeColor'],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChartsRow(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: _buildPieChart(colorScheme),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildBarChart(colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: () => _showChartDetails('Vendas por Categoria'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vendas por Categoria',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: CustomPaint(
                    size: const Size(150, 150),
                    painter: PieChartPainter(),
                  ),
                ),
              ),
              _buildLegend(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: () => _showChartDetails('Vendas Últimos 7 Dias'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vendas Últimos 7 Dias',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: BarChartPainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(ColorScheme colorScheme) {
    final items = [
      {'color': const Color(0xFFDC2626), 'label': 'Pizza', 'value': '60%'},
      {'color': const Color(0xFFEF4444), 'label': 'Bebidas', 'value': '25%'},
      {'color': const Color(0xFFF87171), 'label': 'Sobremesas', 'value': '15%'},
    ];

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item['color'] as Color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item['label'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              Text(
                item['value'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivity(ColorScheme colorScheme) {
    final activities = _getRecentActivities();

    return Container(
      margin: const EdgeInsets.all(24),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Atividades Recentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ...activities.map((activity) => _buildActivityItem(activity, colorScheme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: activity['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              activity['icon'],
              size: 20,
              color: activity['color'],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  activity['subtitle'],
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'],
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showChartDetails(String chartType) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalhes: $chartType'),
        content: Text('Visão detalhada de $chartType seria mostrada aqui.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia!';
    if (hour < 18) return 'Boa tarde!';
    return 'Boa noite!';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }

  List<Map<String, dynamic>> _getMetricsData() {
    return [
      {
        'icon': Icons.attach_money,
        'title': 'Faturamento',
        'value': 'R\$ 3.247',
        'change': '+12.5%',
        'changeIcon': Icons.arrow_upward,
        'changeColor': Colors.green,
      },
      {
        'icon': Icons.shopping_cart,
        'title': 'Pedidos',
        'value': '127',
        'change': '+8.2%',
        'changeIcon': Icons.arrow_upward,
        'changeColor': Colors.green,
      },
      {
        'icon': Icons.kitchen,
        'title': 'Em Preparo',
        'value': '8',
        'change': '-2.1%',
        'changeIcon': Icons.arrow_downward,
        'changeColor': Colors.orange,
      },
    ];
  }

  List<Map<String, dynamic>> _getRecentActivities() {
    return [
      {
        'icon': Icons.shopping_bag,
        'title': 'Pedido #1234 entregue',
        'subtitle': 'Pizza Margherita - João Silva',
        'time': '2 min',
        'color': Colors.green,
      },
      {
        'icon': Icons.kitchen,
        'title': 'Pedido #1235 em preparo',
        'subtitle': 'Pizza Pepperoni - Maria Santos',
        'time': '8 min',
        'color': Colors.orange,
      },
      {
        'icon': Icons.access_time,
        'title': 'Novo pedido recebido',
        'subtitle': 'Pizza Quattro Stagioni - Pedro Costa',
        'time': '15 min',
        'color': const Color(0xFFDC2626),
      },
      {
        'icon': Icons.person_add,
        'title': 'Novo cliente cadastrado',
        'subtitle': 'Ana Oliveira se registrou',
        'time': '1 hora',
        'color': Colors.blue,
      },
    ];
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFFDC2626),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_pizza,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  'Pizzaria Sistema',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Pedidos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/pedidos');
            },
          ),
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Produtos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/produtos');
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Caixa'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/caixa');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clientes'),
            onTap: () {
              Navigator.pop(context);
              _showComingSoon(context);
            },
          ),
        ],
      ),
    );
  }


  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade em desenvolvimento!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    final paint = Paint()..style = PaintingStyle.fill;

    final data = [
      {'value': 0.60, 'color': const Color(0xFFDC2626)},
      {'value': 0.25, 'color': const Color(0xFFEF4444)},
      {'value': 0.15, 'color': const Color(0xFFF87171)},
    ];

    double startAngle = -math.pi / 2;

    for (final segment in data) {
      final sweepAngle = 2 * math.pi * (segment['value'] as double);
      paint.color = segment['color'] as Color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFDC2626);
    final data = [1200.0, 1800.0, 1500.0, 2200.0, 1900.0, 2500.0, 2100.0];
    
    final barWidth = size.width / (data.length * 2);
    final maxValue = data.reduce(math.max);
    final maxHeight = size.height - 20;

    for (int i = 0; i < data.length; i++) {
      final barHeight = (maxHeight * data[i]) / maxValue;
      final left = i * barWidth * 2 + barWidth * 0.5;
      final top = size.height - barHeight;

      final rect = Rect.fromLTWH(left, top, barWidth, barHeight);
      
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFDC2626),
          const Color(0xFFDC2626).withValues(alpha: 0.7),
        ],
      );

      paint.shader = gradient.createShader(rect);
      
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}