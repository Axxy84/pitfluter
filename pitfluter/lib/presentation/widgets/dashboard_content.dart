import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent>
    with TickerProviderStateMixin {
  String selectedPeriod = 'Hoje';
  bool isRefreshing = false;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final supabase = Supabase.instance.client;
  
  // Dados reais
  int totalPedidosHoje = 0;
  double faturamentoHoje = 0.0;
  double ticketMedio = 0.0;
  int clientesAtivos = 0;
  List<Map<String, dynamic>> pedidosRecentes = [];
  List<Map<String, dynamic>> produtosMaisVendidos = [];

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
    _loadDashboardData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      // Período selecionado
      DateTime startDate;
      switch (selectedPeriod) {
        case 'Semana':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'Mês':
          startDate = DateTime(now.year, now.month, 1);
          break;
        default:
          startDate = startOfDay;
      }

      // 1. Buscar pedidos do período
      final pedidosResponse = await supabase
          .from('pedidos')
          .select('*')
          .gte('created_at', startDate.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());

      final pedidos = List<Map<String, dynamic>>.from(pedidosResponse);
      
      // 2. Calcular métricas
      totalPedidosHoje = pedidos.length;
      faturamentoHoje = pedidos.fold(0.0, (sum, p) => sum + (p['total'] ?? 0.0));
      ticketMedio = totalPedidosHoje > 0 ? faturamentoHoje / totalPedidosHoje : 0;
      
      // 3. Clientes únicos (baseado em nome_cliente se existir)
      final clientesUnicos = <String>{};
      for (var pedido in pedidos) {
        final nomeCliente = pedido['nome_cliente']?.toString();
        if (nomeCliente != null && nomeCliente.isNotEmpty) {
          clientesUnicos.add(nomeCliente);
        }
      }
      clientesAtivos = clientesUnicos.length;
      
      // 4. Pedidos recentes (últimos 5)
      final recentesResponse = await supabase
          .from('pedidos')
          .select('*')
          .order('created_at', ascending: false)
          .limit(5);
      
      pedidosRecentes = List<Map<String, dynamic>>.from(recentesResponse);
      
      // 5. Produtos mais vendidos (se a tabela pedido_itens existir)
      try {
        final itensResponse = await supabase
            .from('pedido_itens')
            .select('nome_item, quantidade')
            .gte('created_at', startDate.toIso8601String());
        
        final itens = List<Map<String, dynamic>>.from(itensResponse);
        
        // Agrupar por produto
        final produtosMap = <String, int>{};
        for (var item in itens) {
          final nome = item['nome_item']?.toString() ?? 'Sem nome';
          final quantidade = (item['quantidade'] ?? 1) as int;
          produtosMap[nome] = (produtosMap[nome] ?? 0) + quantidade;
        }
        
        // Ordenar e pegar top 5
        var sortedProdutos = produtosMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        produtosMaisVendidos = sortedProdutos.take(5).map((e) => {
          'nome': e.key,
          'quantidade': e.value,
        }).toList();
      } catch (e) {
        // Tabela pedido_itens pode não existir
        produtosMaisVendidos = [];
      }
      
    } catch (e) {
      // Erro ao carregar dados do dashboard
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      isRefreshing = true;
    });

    await _loadDashboardData();

    setState(() {
      isRefreshing = false;
    });

    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
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
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Acompanhe o desempenho do seu negócio em tempo real',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: periods.map((period) {
          final isSelected = selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    selectedPeriod = period;
                  });
                  _loadDashboardData();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricCards(ColorScheme colorScheme) {
    final numberFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    final metrics = [
      _MetricData(
        title: 'Pedidos $selectedPeriod',
        value: totalPedidosHoje.toString(),
        change: '',
        icon: Icons.shopping_cart,
        color: Colors.blue,
        isPositive: true,
      ),
      _MetricData(
        title: 'Faturamento',
        value: numberFormat.format(faturamentoHoje),
        change: '',
        icon: Icons.attach_money,
        color: Colors.green,
        isPositive: true,
      ),
      _MetricData(
        title: 'Ticket Médio',
        value: numberFormat.format(ticketMedio),
        change: '',
        icon: Icons.trending_up,
        color: Colors.orange,
        isPositive: true,
      ),
      _MetricData(
        title: 'Clientes',
        value: clientesAtivos.toString(),
        change: '',
        icon: Icons.people,
        color: Colors.purple,
        isPositive: true,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 1200 ? 4 :
                               constraints.maxWidth > 800 ? 2 : 1;
          
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: metrics.length,
            itemBuilder: (context, index) {
              final metric = metrics[index];
              return _buildMetricCard(metric, colorScheme);
            },
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(_MetricData metric, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: metric.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      metric.icon,
                      color: metric.color,
                      size: 24,
                    ),
                  ),
                  if (metric.change.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: metric.isPositive 
                            ? Colors.green.withValues(alpha: 0.1) 
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            metric.isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 12,
                            color: metric.isPositive ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            metric.change,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: metric.isPositive ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metric.value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartsRow(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Produtos mais vendidos
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Produtos Mais Vendidos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Icon(
                          Icons.pie_chart,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (produtosMaisVendidos.isEmpty)
                      Center(
                        child: Text(
                          'Nenhum produto vendido no período',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      ...produtosMaisVendidos.map((produto) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                produto['nome'],
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${produto['quantidade']}x',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(ColorScheme colorScheme) {
    final dateFormat = DateFormat('dd/MM HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pedidos Recentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              if (pedidosRecentes.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Nenhum pedido registrado',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ...pedidosRecentes.map((pedido) {
                  final createdAt = pedido['created_at'] != null
                      ? DateTime.parse(pedido['created_at'])
                      : DateTime.now();
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(pedido['status']),
                      child: Text(
                        '#${pedido['numero'] ?? pedido['id']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      pedido['nome_cliente'] ?? 'Cliente #${pedido['id']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      dateFormat.format(createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Text(
                      currencyFormat.format(pedido['total'] ?? 0),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'aberto':
        return Colors.blue;
      case 'preparando':
        return Colors.orange;
      case 'finalizado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _MetricData {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final bool isPositive;

  _MetricData({
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    required this.isPositive,
  });
}