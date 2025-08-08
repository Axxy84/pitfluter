import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/pedido.dart';

class PedidosContent extends StatefulWidget {
  const PedidosContent({super.key});

  @override
  State<PedidosContent> createState() => _PedidosContentState();
}

class _PedidosContentState extends State<PedidosContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final supabase = Supabase.instance.client;
  
  List<Pedido> pedidosAtivos = [];
  List<Pedido> pedidosFinalizados = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPedidos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPedidos() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // TODO: Implementar carregamento real de pedidos quando fromJson estiver disponível

      setState(() {
        // Por enquanto, todos os pedidos serão tratados como ativos
        pedidosAtivos = []; // Temporariamente vazio até implementar fromJson
        pedidosFinalizados = [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text('Erro ao carregar pedidos', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(error!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadPedidos,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedidos',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gerencie os pedidos do restaurante',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _loadPedidos,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Atualizar',
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/novo-pedido')
                              .then((_) => _loadPedidos());
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Novo Pedido'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Estatísticas
              Row(
                children: [
                  _buildStatCard(
                    'Pedidos Ativos',
                    pedidosAtivos.length.toString(),
                    Icons.receipt_long,
                    colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    'Finalizados Hoje',
                    pedidosFinalizados.length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // TabBar
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Ativos (${pedidosAtivos.length})'),
              Tab(text: 'Finalizados (${pedidosFinalizados.length})'),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPedidosList(pedidosAtivos),
              _buildPedidosList(pedidosFinalizados),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPedidosList(List<Pedido> pedidos) {
    if (pedidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum pedido encontrado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pedidos.length,
      itemBuilder: (context, index) {
        final pedido = pedidos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                '#${pedido.numero}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text('Pedido ${pedido.numero}'),
            subtitle: Text(
              'Total: R\$ ${pedido.total.toStringAsFixed(2)}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {
                // TODO: Ver detalhes do pedido
              },
            ),
          ),
        );
      },
    );
  }

}