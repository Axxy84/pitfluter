import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

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
  
  // Dados para gráficos
  List<FlSpot> vendaSemanaSPots = [];
  Map<String, double> formasPagamento = {};
  List<Map<String, dynamic>> vendasPorHora = [];
  
  // Dados para mini gráficos dos cards
  List<FlSpot> faturamentoSemanaSpots = [];
  List<double> pedidosSemanaBars = [];
  double ticketMedioAnterior = 0.0;

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
      
      // 6. Dados para gráficos
      await _loadChartData(pedidos);
      
    } catch (e) {
      // Erro ao carregar dados do dashboard
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadChartData(List<Map<String, dynamic>> pedidos) async {
    // 1. Vendas por hora (últimas 24 horas)
    final vendasHora = <int, double>{};
    for (int i = 0; i < 24; i++) {
      vendasHora[i] = 0;
    }
    
    for (var pedido in pedidos) {
      if (pedido['created_at'] != null) {
        final data = DateTime.parse(pedido['created_at']);
        final hora = data.hour;
        vendasHora[hora] = (vendasHora[hora] ?? 0) + (pedido['total'] ?? 0.0);
      }
    }
    
    vendasPorHora = vendasHora.entries.map((e) => {
      'hora': e.key,
      'valor': e.value,
    }).toList();
    
    // 2. Formas de pagamento
    formasPagamento = {
      'Dinheiro': 0,
      'Cartão': 0,
      'PIX': 0,
    };
    
    for (var pedido in pedidos) {
      final forma = pedido['forma_pagamento']?.toString() ?? 'Dinheiro';
      final valor = (pedido['total'] ?? 0.0).toDouble();
      formasPagamento[forma] = (formasPagamento[forma] ?? 0) + valor;
    }
    
    // 3. Vendas da semana (últimos 7 dias)
    final now = DateTime.now();
    vendaSemanaSPots = [];
    faturamentoSemanaSpots = [];
    pedidosSemanaBars = [];
    
    for (int i = 6; i >= 0; i--) {
      final dia = now.subtract(Duration(days: i));
      final inicioDia = DateTime(dia.year, dia.month, dia.day);
      final fimDia = inicioDia.add(const Duration(days: 1));
      
      double totalDia = 0;
      int pedidosDia = 0;
      
      for (var pedido in pedidos) {
        if (pedido['created_at'] != null) {
          final dataPedido = DateTime.parse(pedido['created_at']);
          if (dataPedido.isAfter(inicioDia) && dataPedido.isBefore(fimDia)) {
            totalDia += (pedido['total'] ?? 0.0).toDouble();
            pedidosDia++;
          }
        }
      }
      
      vendaSemanaSPots.add(FlSpot((6 - i).toDouble(), totalDia));
      faturamentoSemanaSpots.add(FlSpot((6 - i).toDouble(), totalDia));
      pedidosSemanaBars.add(pedidosDia.toDouble());
    }
    
    // 4. Calcular ticket médio anterior (semana passada) para comparação
    final semanaPassadaInicio = now.subtract(const Duration(days: 14));
    final semanaPassadaFim = now.subtract(const Duration(days: 7));
    
    double totalSemanaPassada = 0;
    int pedidosSemanaPassada = 0;
    
    for (var pedido in pedidos) {
      if (pedido['created_at'] != null) {
        final dataPedido = DateTime.parse(pedido['created_at']);
        if (dataPedido.isAfter(semanaPassadaInicio) && dataPedido.isBefore(semanaPassadaFim)) {
          totalSemanaPassada += (pedido['total'] ?? 0.0).toDouble();
          pedidosSemanaPassada++;
        }
      }
    }
    
    ticketMedioAnterior = pedidosSemanaPassada > 0 ? totalSemanaPassada / pedidosSemanaPassada : 0;
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
              childAspectRatio: 1.3, // Ajustado para acomodar os mini gráficos
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
              
              // Mini chart area
              if (_shouldShowMiniChart(metric.title))
                SizedBox(
                  height: 40,
                  child: _buildMiniChart(metric.title, colorScheme),
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
  
  bool _shouldShowMiniChart(String title) {
    return title.contains('Faturamento') || 
           title.contains('Pedidos');
  }
  
  Widget _buildMiniChart(String title, ColorScheme colorScheme) {
    if (title.contains('Faturamento')) {
      return _buildMiniLineChart(colorScheme);
    } else if (title.contains('Pedidos')) {
      return _buildMiniBarChart(colorScheme);
    }
    return Container();
  }
  
  Widget _buildMiniLineChart(ColorScheme colorScheme) {
    if (faturamentoSemanaSpots.isEmpty) return Container();
    
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: faturamentoSemanaSpots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Colors.green,
                Colors.green.withValues(alpha: 0.3),
              ],
            ),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green.withValues(alpha: 0.2),
                  Colors.green.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMiniBarChart(ColorScheme colorScheme) {
    if (pedidosSemanaBars.isEmpty) return Container();
    
    final maxValue = pedidosSemanaBars.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return Container();
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.2,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: pedidosSemanaBars.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.blue,
                    Colors.blue.withValues(alpha: 0.7),
                  ],
                ),
                width: 8,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
  

  Widget _buildChartsRow(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 1200;
          
          if (isWide) {
            return Row(
              children: [
                Expanded(child: _buildSalesLineChart(colorScheme)),
                const SizedBox(width: 16),
                Expanded(child: _buildPaymentMethodsChart(colorScheme)),
                const SizedBox(width: 16),
                Expanded(child: _buildHourlySalesChart(colorScheme)),
              ],
            );
          } else {
            return Column(
              children: [
                _buildSalesLineChart(colorScheme),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildPaymentMethodsChart(colorScheme)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildHourlySalesChart(colorScheme)),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
  
  Widget _buildSalesLineChart(ColorScheme colorScheme) {
    return Card(
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
                  'Vendas da Semana',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.show_chart,
                  color: colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: vendaSemanaSPots.isEmpty
                  ? Center(
                      child: Text(
                        'Sem dados para exibir',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                const dias = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
                                final index = value.toInt();
                                if (index >= 0 && index < dias.length) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      dias[index],
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }
                                return Container();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: null,
                              reservedSize: 60,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    'R\$ ${value.toInt()}',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.3),
                            ),
                            left: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: vendaSemanaSPots,
                            isCurved: true,
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.primary.withValues(alpha: 0.3),
                              ],
                            ),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                    radius: 4,
                                    color: colorScheme.primary,
                                    strokeWidth: 2,
                                    strokeColor: colorScheme.surface,
                                  ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  colorScheme.primary.withValues(alpha: 0.2),
                                  colorScheme.primary.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethodsChart(ColorScheme colorScheme) {
    final total = formasPagamento.values.fold(0.0, (sum, value) => sum + value);
    
    return Card(
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
                  'Formas de Pagamento',
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
            SizedBox(
              height: 200,
              child: total == 0
                  ? Center(
                      child: Text(
                        'Sem dados para exibir',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 60,
                        startDegreeOffset: -90,
                        sections: formasPagamento.entries.map((entry) {
                          final percentage = (entry.value / total * 100);
                          final colors = [
                            Colors.green,
                            Colors.blue,
                            Colors.purple,
                          ];
                          final colorIndex = formasPagamento.keys.toList().indexOf(entry.key);
                          
                          return PieChartSectionData(
                            color: colors[colorIndex % colors.length],
                            value: entry.value,
                            title: '${percentage.toStringAsFixed(1)}%',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            ...formasPagamento.entries.map((entry) {
              final colors = [Colors.green, Colors.blue, Colors.purple];
              final colorIndex = formasPagamento.keys.toList().indexOf(entry.key);
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors[colorIndex % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.key)),
                    Text(
                      'R\$ ${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHourlySalesChart(ColorScheme colorScheme) {
    return Card(
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
                  'Vendas por Hora',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.bar_chart,
                  color: colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: vendasPorHora.isEmpty
                  ? Center(
                      child: Text(
                        'Sem dados para exibir',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: vendasPorHora.map((e) => e['valor'] as double).reduce((a, b) => a > b ? a : b) * 1.2,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: colorScheme.inverseSurface,
                            tooltipHorizontalAlignment: FLHorizontalAlignment.center,
                            tooltipMargin: 10,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final hora = group.x.toInt();
                              final valor = rod.toY;
                              return BarTooltipItem(
                                '${hora}h\nR\$ ${valor.toStringAsFixed(2)}',
                                TextStyle(
                                  color: colorScheme.onInverseSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 4,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    '${value.toInt()}h',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    'R\$${value.toInt()}',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 9,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.3),
                            ),
                            left: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        barGroups: vendasPorHora.map((venda) {
                          final hora = venda['hora'] as int;
                          final valor = venda['valor'] as double;
                          
                          return BarChartGroupData(
                            x: hora,
                            barRods: [
                              BarChartRodData(
                                toY: valor,
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.primary.withValues(alpha: 0.7),
                                  ],
                                ),
                                width: 8,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                            strokeWidth: 1,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
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

