import 'package:flutter/material.dart';

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/novo-pedido'),
            tooltip: 'Novo Pedido',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com estatísticas
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    'Pendentes',
                    '3',
                    Colors.orange,
                    Icons.pending,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    'Em Preparo',
                    '2',
                    Colors.blue,
                    Icons.restaurant,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    'Prontos',
                    '1',
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de pedidos
          Expanded(
            child: _buildPedidosList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/novo-pedido'),
        tooltip: 'Novo Pedido',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusCard(String title, String count, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPedidosList() {
    // Dados mockados para demonstração
    final pedidosMock = [
      {
        'id': '001',
        'cliente': 'João Silva',
        'items': 'Pizza Margherita (M), Coca-Cola',
        'valor': 35.90,
        'status': 'Pendente',
        'hora': '19:30',
        'cor': Colors.orange,
      },
      {
        'id': '002',
        'cliente': 'Maria Santos',
        'items': 'Pizza Calabresa (G), Guaraná',
        'valor': 42.50,
        'status': 'Em Preparo',
        'hora': '19:45',
        'cor': Colors.blue,
      },
      {
        'id': '003',
        'cliente': 'Pedro Costa',
        'items': 'Pizza Portuguesa (M)',
        'valor': 38.90,
        'status': 'Pronto',
        'hora': '20:00',
        'cor': Colors.green,
      },
    ];

    if (pedidosMock.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum pedido encontrado',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Crie um novo pedido para começar',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: pedidosMock.length,
      itemBuilder: (context, index) {
        final pedido = pedidosMock[index];
        return _buildPedidoCard(pedido);
      },
    );
  }

  Widget _buildPedidoCard(Map<String, dynamic> pedido) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: pedido['cor'].withValues(alpha: 0.2),
          child: Text(
            pedido['id'],
            style: TextStyle(
              color: pedido['cor'],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          pedido['cliente'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pedido['items']),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: pedido['cor'].withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pedido['status'],
                    style: TextStyle(
                      color: pedido['cor'],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  pedido['hora'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          'R\$ ${pedido['valor'].toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFDC2626),
          ),
        ),
        onTap: () => _showPedidoDetails(pedido),
      ),
    );
  }

  void _showPedidoDetails(Map<String, dynamic> pedido) {
    // Implementar detalhes do pedido
  }
}