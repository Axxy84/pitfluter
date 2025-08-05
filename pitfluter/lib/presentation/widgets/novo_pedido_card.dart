import 'package:flutter/material.dart';
import '../screens/novo_pedido_screen.dart';

class NovoPedidoCard extends StatelessWidget {
  const NovoPedidoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NovoPedidoScreen(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_shopping_cart,
                size: 48,
                color: Colors.red,
              ),
              SizedBox(height: 12),
              Text(
                'Novo Pedido',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Criar novo pedido',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NovoPedidoButton extends StatelessWidget {
  final bool compact;
  
  const NovoPedidoButton({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NovoPedidoScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_shopping_cart),
        tooltip: 'Novo Pedido',
      );
    }
    
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NovoPedidoScreen(),
          ),
        );
      },
      icon: const Icon(Icons.add_shopping_cart),
      label: const Text('Novo Pedido'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}