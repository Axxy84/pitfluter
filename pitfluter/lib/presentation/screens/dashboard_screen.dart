import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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
  
  final supabase = Supabase.instance.client;
  
  // Dados reais
  double totalVendasHoje = 0.0;
  int quantidadePedidosHoje = 0;
  double ticketMedio = 0.0;
  List<Map<String, dynamic>> pedidosRecentes = [];
  Map<String, double> vendasPorTipo = {'Balcão': 0, 'Delivery': 0, 'Mesa': 0};
  Map<String, double> formasPagamento = {'Dinheiro': 0, 'PIX': 0, 'Cartão': 0};
  Map<String, double> vendasPorCategoria = {'Pizza': 0, 'Bebidas': 0, 'Sobremesas': 0};
  List<double> vendasUltimos7Dias = [];

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
    _carregarDadosReais();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosReais() async {
    // Carregando dados do dashboard
    try {
      final hoje = DateTime.now();
      DateTime inicio;
      
      // Determinar período baseado na seleção
      switch (selectedPeriod) {
        case 'Hoje':
          inicio = DateTime(hoje.year, hoje.month, hoje.day);
          break;
        case 'Semana':
          inicio = hoje.subtract(const Duration(days: 7));
          break;
        case 'Mês':
          inicio = DateTime(hoje.year, hoje.month - 1, hoje.day);
          break;
        default:
          inicio = DateTime(hoje.year, hoje.month, hoje.day);
      }
      
      // Buscando pedidos do período
      
      final response = await supabase
          .from('pedidos')
          .select()
          .gte('created_at', inicio.toIso8601String());
      
      // Processando resposta do Supabase
      
      // Resetar contadores
      totalVendasHoje = 0.0;
      quantidadePedidosHoje = 0;
      vendasPorTipo = {'Balcão': 0, 'Delivery': 0, 'Mesa': 0};
      formasPagamento = {'Dinheiro': 0, 'PIX': 0, 'Cartão': 0};
      
      // Processar pedidos
      for (final pedido in response) {
        final valor = (pedido['total'] ?? 0).toDouble();
        totalVendasHoje += valor;
        quantidadePedidosHoje++;
        
        // Contar por tipo
        final tipo = pedido['tipo'] ?? 'balcao';
        if (tipo == 'entrega' || tipo == 'delivery') {
          vendasPorTipo['Delivery'] = (vendasPorTipo['Delivery'] ?? 0) + valor;
        } else if (tipo == 'mesa') {
          vendasPorTipo['Mesa'] = (vendasPorTipo['Mesa'] ?? 0) + valor;
        } else {
          vendasPorTipo['Balcão'] = (vendasPorTipo['Balcão'] ?? 0) + valor;
        }
        
        // Contar por forma de pagamento
        final formaPagamento = pedido['forma_pagamento'] ?? 'Dinheiro';
        if (formaPagamento == 'PIX') {
          formasPagamento['PIX'] = (formasPagamento['PIX'] ?? 0) + valor;
        } else if (formaPagamento == 'Cartão') {
          formasPagamento['Cartão'] = (formasPagamento['Cartão'] ?? 0) + valor;
        } else {
          formasPagamento['Dinheiro'] = (formasPagamento['Dinheiro'] ?? 0) + valor;
        }
      }
      
      // Calcular ticket médio
      if (quantidadePedidosHoje > 0) {
        ticketMedio = totalVendasHoje / quantidadePedidosHoje;
      } else {
        ticketMedio = 0;
      }
      
      // Simular dados de categoria (por enquanto distribui proporcionalmente)
      // Em produção, você teria uma tabela de itens de pedido com categorias
      if (totalVendasHoje > 0) {
        vendasPorCategoria['Pizza'] = totalVendasHoje * 0.60;
        vendasPorCategoria['Bebidas'] = totalVendasHoje * 0.25;
        vendasPorCategoria['Sobremesas'] = totalVendasHoje * 0.15;
      } else {
        vendasPorCategoria = {'Pizza': 0, 'Bebidas': 0, 'Sobremesas': 0};
      }
      
      // Buscar vendas dos últimos 7 dias para o gráfico de barras
      vendasUltimos7Dias = [];
      for (int i = 6; i >= 0; i--) {
        final dia = hoje.subtract(Duration(days: i));
        final inicioDia = DateTime(dia.year, dia.month, dia.day);
        final fimDia = inicioDia.add(const Duration(days: 1));
        
        final vendasDia = await supabase
            .from('pedidos')
            .select('total')
            .gte('created_at', inicioDia.toIso8601String())
            .lt('created_at', fimDia.toIso8601String());
        
        double totalDia = 0;
        for (final venda in vendasDia) {
          totalDia += (venda['total'] ?? 0).toDouble();
        }
        vendasUltimos7Dias.add(totalDia);
      }
      
      // Buscar pedidos recentes (últimos 5)
      final recentesResponse = await supabase
          .from('pedidos')
          .select()
          .order('created_at', ascending: false)
          .limit(5);
      
      pedidosRecentes = List<Map<String, dynamic>>.from(recentesResponse);
      
      // Dados processados com sucesso
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Erro ao carregar dados - usar logging em produção
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isRefreshing = true;
    });

    await _carregarDadosReais();

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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'test',
            onPressed: () async {
              // Criar pedido de teste
              try {
                final ultimoPedido = await supabase
                    .from('pedidos')
                    .select('numero')
                    .order('numero', ascending: false)
                    .limit(1);
                
                int proximoNumero = 1;
                if (ultimoPedido.isNotEmpty && ultimoPedido.first['numero'] != null) {
                  proximoNumero = ultimoPedido.first['numero'] + 1;
                }
                
                await supabase.from('pedidos').insert({
                  'numero': proximoNumero,
                  'tipo': 'balcao',
                  'total': 45.50,
                  'forma_pagamento': 'Dinheiro',
                  'observacoes': 'Pedido de teste',
                });
                
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pedido #$proximoNumero criado!')),
                );
                
                _carregarDadosReais();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro: $e')),
                );
              }
            },
            backgroundColor: Colors.orange,
            child: const Icon(Icons.bug_report),
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: 'novo',
            onPressed: () => Navigator.pushNamed(context, '/novo-pedido'),
            icon: const Icon(Icons.add),
            label: const Text('Novo Pedido'),
          ),
        ],
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
                      _carregarDadosReais(); // Recarregar dados ao mudar período
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
                    painter: PieChartPainter(vendasPorCategoria),
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
                  painter: BarChartPainter(vendasUltimos7Dias),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(ColorScheme colorScheme) {
    final total = vendasPorCategoria.values.fold(0.0, (a, b) => a + b);
    final items = [
      {
        'color': const Color(0xFFDC2626),
        'label': 'Pizza',
        'value': total > 0 ? '${((vendasPorCategoria['Pizza']! / total) * 100).toStringAsFixed(0)}%' : '0%'
      },
      {
        'color': const Color(0xFFEF4444),
        'label': 'Bebidas',
        'value': total > 0 ? '${((vendasPorCategoria['Bebidas']! / total) * 100).toStringAsFixed(0)}%' : '0%'
      },
      {
        'color': const Color(0xFFF87171),
        'label': 'Sobremesas',
        'value': total > 0 ? '${((vendasPorCategoria['Sobremesas']! / total) * 100).toStringAsFixed(0)}%' : '0%'
      },
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
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    return [
      {
        'icon': Icons.attach_money,
        'title': 'Faturamento',
        'value': formatador.format(totalVendasHoje),
        'change': quantidadePedidosHoje > 0 ? '+$quantidadePedidosHoje' : '0',
        'changeIcon': Icons.shopping_cart,
        'changeColor': Colors.green,
      },
      {
        'icon': Icons.shopping_cart,
        'title': 'Pedidos',
        'value': quantidadePedidosHoje.toString(),
        'change': ticketMedio > 0 ? formatador.format(ticketMedio) : 'R\$ 0',
        'changeIcon': Icons.attach_money,
        'changeColor': Colors.blue,
      },
      {
        'icon': Icons.receipt_long,
        'title': 'Ticket Médio',
        'value': formatador.format(ticketMedio),
        'change': 'Média/pedido',
        'changeIcon': Icons.trending_up,
        'changeColor': Colors.purple,
      },
    ];
  }

  List<Map<String, dynamic>> _getRecentActivities() {
    if (pedidosRecentes.isEmpty) {
      return [
        {
          'icon': Icons.info_outline,
          'title': 'Nenhum pedido ainda',
          'subtitle': 'Os pedidos aparecerão aqui',
          'time': 'Agora',
          'color': Colors.grey,
        },
      ];
    }
    
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final agora = DateTime.now();
    
    return pedidosRecentes.map((pedido) {
      final dataHora = DateTime.parse(pedido['created_at']);
      final diferenca = agora.difference(dataHora);
      String tempoAtras;
      
      if (diferenca.inMinutes < 1) {
        tempoAtras = 'Agora';
      } else if (diferenca.inMinutes < 60) {
        tempoAtras = '${diferenca.inMinutes} min';
      } else if (diferenca.inHours < 24) {
        tempoAtras = '${diferenca.inHours}h';
      } else {
        tempoAtras = '${diferenca.inDays}d';
      }
      
      final tipo = pedido['tipo'] ?? 'balcao';
      IconData icone;
      Color cor;
      String tipoTexto;
      
      if (tipo == 'entrega' || tipo == 'delivery') {
        icone = Icons.delivery_dining;
        cor = Colors.orange;
        tipoTexto = 'Delivery';
      } else if (tipo == 'mesa') {
        icone = Icons.table_restaurant;
        cor = Colors.purple;
        tipoTexto = 'Mesa';
      } else {
        icone = Icons.storefront;
        cor = Colors.blue;
        tipoTexto = 'Balcão';
      }
      
      return {
        'icon': icone,
        'title': 'Pedido #${pedido['numero'] ?? pedido['id']}',
        'subtitle': '$tipoTexto - ${formatador.format(pedido['total'] ?? 0)}',
        'time': tempoAtras,
        'color': cor,
      };
    }).toList();
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
            leading: const Icon(Icons.history),
            title: const Text('Histórico de Caixas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/historico-caixas');
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
  final Map<String, double> vendas;
  
  PieChartPainter(this.vendas);
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    final paint = Paint()..style = PaintingStyle.fill;
    
    final total = vendas.values.fold(0.0, (a, b) => a + b);
    
    if (total == 0) {
      // Desenhar gráfico vazio
      paint.color = Colors.grey.shade300;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    final data = [
      {'value': vendas['Pizza']! / total, 'color': const Color(0xFFDC2626)},
      {'value': vendas['Bebidas']! / total, 'color': const Color(0xFFEF4444)},
      {'value': vendas['Sobremesas']! / total, 'color': const Color(0xFFF87171)},
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
  bool shouldRepaint(PieChartPainter oldDelegate) => oldDelegate.vendas != vendas;
}

class BarChartPainter extends CustomPainter {
  final List<double> vendas;
  
  BarChartPainter(this.vendas);
  
  @override
  void paint(Canvas canvas, Size size) {
    if (vendas.isEmpty) return;
    
    final paint = Paint()..color = const Color(0xFFDC2626);
    final data = vendas.isEmpty ? [0.0] : vendas;
    
    final barWidth = size.width / (data.length * 2);
    final maxValue = data.isEmpty || data.every((v) => v == 0) 
        ? 100.0 
        : data.reduce(math.max);
    final maxHeight = size.height - 20;

    for (int i = 0; i < data.length; i++) {
      if (data[i] == 0 && maxValue == 100) {
        // Desenhar barra vazia
        final left = i * barWidth * 2 + barWidth * 0.5;
        final rect = Rect.fromLTWH(left, size.height - 5, barWidth, 5);
        paint.color = Colors.grey.shade300;
        paint.shader = null;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          paint,
        );
      } else {
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
  }

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) => oldDelegate.vendas != vendas;
}