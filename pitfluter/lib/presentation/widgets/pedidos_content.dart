import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/pedidos_bloc.dart';
import '../../domain/entities/pedido.dart';

class PedidosContent extends StatefulWidget {
  const PedidosContent({super.key});

  @override
  State<PedidosContent> createState() => _PedidosContentState();
}

class _PedidosContentState extends State<PedidosContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Recarregar pedidos ao iniciar
    context.read<PedidosBloc>().add(CarregarPedidos());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedidos',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gerencie os pedidos do sistema',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          context.read<PedidosBloc>().add(AtualizarPedidos());
                        },
                        tooltip: 'Atualizar',
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _abrirNovoPedido(),
                        icon: const Icon(Icons.add),
                        label: const Text('Novo Pedido'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                indicatorColor: colorScheme.primary,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.list_alt),
                    text: 'Ativos',
                  ),
                  Tab(
                    icon: Icon(Icons.delete_outline),
                    text: 'Removidos',
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: BlocConsumer<PedidosBloc, PedidosState>(
            listener: (context, state) {
              if (state is PedidoOperacaoSucesso) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.mensagem),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is PedidosErro) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.mensagem),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is PedidosCarregando) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is PedidosCarregados) {
                return Column(
                  children: [
                    // Header com estatísticas
                    _buildEstatisticasHeader(state),
                    
                    // TabBarView com listas
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildListaPedidos(state.pedidosAtivos, isAtivos: true),
                          _buildListaPedidos(state.pedidosRemovidos, isAtivos: false),
                        ],
                      ),
                    ),
                  ],
                );
              }

              if (state is PedidosErro) {
                return _buildErroState(state.mensagem);
              }

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Carregue os pedidos para começar',
                      style: TextStyle(
                        fontSize: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<PedidosBloc>().add(CarregarPedidos());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Carregar Pedidos'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEstatisticasHeader(PedidosCarregados state) {
    final totalAtivos = state.pedidosAtivos.length;
    final entrega = state.pedidosAtivos.where((p) => p.tipo == TipoPedido.entrega).length;
    final balcao = state.pedidosAtivos.where((p) => p.tipo == TipoPedido.balcao).length;
    final mesa = state.pedidosAtivos.where((p) => p.tipo == TipoPedido.mesa).length;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusCard(
              'Total',
              totalAtivos.toString(),
              Colors.blue,
              Icons.list_alt,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatusCard(
              'Entrega',
              entrega.toString(),
              Colors.blue,
              Icons.delivery_dining,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatusCard(
              'Balcão',
              balcao.toString(),
              Colors.green,
              Icons.storefront,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatusCard(
              'Mesa',
              mesa.toString(),
              Colors.orange,
              Icons.table_restaurant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, String value, Color color, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaPedidos(List<Pedido> pedidos, {required bool isAtivos}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (pedidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAtivos ? Icons.inbox : Icons.delete_outline,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isAtivos ? 'Nenhum pedido ativo' : 'Nenhum pedido removido',
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurfaceVariant,
              ),
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
        return _PedidoCard(
          pedido: pedido,
          isAtivo: isAtivos,
          onTap: () => _mostrarDetalhesPedido(pedido),
        );
      },
    );
  }

  Widget _buildErroState(String mensagem) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar pedidos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mensagem,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PedidosBloc>().add(CarregarPedidos());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  void _abrirNovoPedido() {
    Navigator.pushNamed(context, '/novo-pedido');
  }

  void _mostrarDetalhesPedido(Pedido pedido) {
    // TODO: Implementar detalhes do pedido
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pedido #${pedido.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Número: ${pedido.numero}'),
            Text('Total: R\$ ${pedido.total.toStringAsFixed(2)}'),
            Text('Tipo: ${pedido.tipo.toString().split('.').last}'),
            if (pedido.observacoes != null)
              Text('Obs: ${pedido.observacoes}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final bool isAtivo;
  final VoidCallback onTap;

  const _PedidoCard({
    required this.pedido,
    required this.isAtivo,
    required this.onTap,
  });

  IconData _getTipoIcon(TipoPedido tipo) {
    switch (tipo) {
      case TipoPedido.entrega:
        return Icons.delivery_dining;
      case TipoPedido.balcao:
        return Icons.storefront;
      case TipoPedido.mesa:
        return Icons.table_restaurant;
    }
  }

  Color _getTipoColor(TipoPedido tipo) {
    switch (tipo) {
      case TipoPedido.entrega:
        return Colors.blue;
      case TipoPedido.balcao:
        return Colors.green;
      case TipoPedido.mesa:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone do tipo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getTipoColor(pedido.tipo).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTipoIcon(pedido.tipo),
                  color: _getTipoColor(pedido.tipo),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Informações do pedido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${pedido.id}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTipoColor(pedido.tipo).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            pedido.tipo.toString().split('.').last.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getTipoColor(pedido.tipo),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pedido ${pedido.numero}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (pedido.observacoes != null && pedido.observacoes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        pedido.observacoes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Valor total
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${pedido.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pedido.formaPagamento,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
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
}