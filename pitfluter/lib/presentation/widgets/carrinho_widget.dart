import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/produto.dart';
import '../../domain/entities/tamanho.dart';

class CarrinhoItem {
  final Produto produto;
  final Tamanho tamanho;
  final int quantidade;
  final double precoUnitario;

  CarrinhoItem({
    required this.produto,
    required this.tamanho,
    required this.quantidade,
    required this.precoUnitario,
  });

  double get subtotal => quantidade * precoUnitario;

  CarrinhoItem copyWith({
    Produto? produto,
    Tamanho? tamanho,
    int? quantidade,
    double? precoUnitario,
  }) {
    return CarrinhoItem(
      produto: produto ?? this.produto,
      tamanho: tamanho ?? this.tamanho,
      quantidade: quantidade ?? this.quantidade,
      precoUnitario: precoUnitario ?? this.precoUnitario,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CarrinhoItem &&
        other.produto.id == produto.id &&
        other.tamanho.id == tamanho.id;
  }

  @override
  int get hashCode => produto.id.hashCode ^ tamanho.id.hashCode;
}

class CarrinhoWidget extends StatelessWidget {
  final List<CarrinhoItem> itens;
  final Function(CarrinhoItem item, int quantidade) onQuantidadeChanged;
  final Function(CarrinhoItem item) onItemRemoved;
  final VoidCallback onFinalizarPedido;
  final bool showAsBottomSheet;

  const CarrinhoWidget({
    super.key,
    required this.itens,
    required this.onQuantidadeChanged,
    required this.onItemRemoved,
    required this.onFinalizarPedido,
    this.showAsBottomSheet = false,
  });

  double get total => itens.fold(0, (sum, item) => sum + item.subtotal);
  int get totalItens => itens.fold(0, (sum, item) => sum + item.quantidade);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Carrinho de compras',
      child: Container(
        width: showAsBottomSheet ? double.infinity : 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: showAsBottomSheet
              ? const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                )
              : null,
          boxShadow: showAsBottomSheet
              ? null
              : [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(-2, 0),
                  ),
                ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: showAsBottomSheet
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Carrinho',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (itens.isNotEmpty) ...[
                    const Spacer(),
                    Text(
                      '($totalItens itens)',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Items List or Empty State
            Expanded(
              child: itens.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: itens.length,
                      itemBuilder: (context, index) {
                        final item = itens[index];
                        return _buildCarrinhoItem(context, item);
                      },
                    ),
            ),

            // Footer with Total and Action Button
            if (itens.isNotEmpty) _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Carrinho vazio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Adicione produtos ao carrinho',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarrinhoItem(BuildContext context, CarrinhoItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.produto.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tamanho: ${item.tamanho.nome}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(item.precoUnitario),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => onItemRemoved(item),
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  tooltip: 'Remover item',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity Controls
                Row(
                  children: [
                    IconButton(
                      onPressed: item.quantidade > 1
                          ? () => onQuantidadeChanged(item, item.quantidade - 1)
                          : null,
                      icon: const Icon(Icons.remove),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        item.quantidade.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          onQuantidadeChanged(item, item.quantidade + 1),
                      icon: const Icon(Icons.add),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                      ),
                    ),
                  ],
                ),
                // Subtotal
                Text(
                  _formatCurrency(item.subtotal),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatCurrency(total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: itens.isEmpty ? null : onFinalizarPedido,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Finalizar Pedido',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    ).format(value);
  }
}

// Helper function to show cart as bottom sheet
void showCarrinhoBottomSheet({
  required BuildContext context,
  required List<CarrinhoItem> itens,
  required Function(CarrinhoItem item, int quantidade) onQuantidadeChanged,
  required Function(CarrinhoItem item) onItemRemoved,
  required VoidCallback onFinalizarPedido,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => CarrinhoWidget(
        itens: itens,
        onQuantidadeChanged: onQuantidadeChanged,
        onItemRemoved: onItemRemoved,
        onFinalizarPedido: onFinalizarPedido,
        showAsBottomSheet: true,
      ),
    ),
  );
}