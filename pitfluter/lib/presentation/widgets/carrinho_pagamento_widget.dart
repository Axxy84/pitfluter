import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/produto.dart';
import '../../domain/entities/tamanho.dart';

enum FormaPagamento {
  dinheiro('Dinheiro', Icons.money),
  cartaoCredito('Cartão de Crédito', Icons.credit_card),
  cartaoDebito('Cartão de Débito', Icons.credit_card),
  pix('PIX', Icons.qr_code),
  vale('Vale Refeição', Icons.restaurant);

  final String label;
  final IconData icon;
  
  const FormaPagamento(this.label, this.icon);
}

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

class CarrinhoPagamentoWidget extends StatefulWidget {
  final List<CarrinhoItem> itens;
  final Function(CarrinhoItem item, int quantidade) onQuantidadeChanged;
  final Function(CarrinhoItem item) onItemRemoved;
  final Function(FormaPagamento formaPagamento, double? valorPago, double? troco) onFinalizarPedido;
  final bool showAsBottomSheet;

  const CarrinhoPagamentoWidget({
    super.key,
    required this.itens,
    required this.onQuantidadeChanged,
    required this.onItemRemoved,
    required this.onFinalizarPedido,
    this.showAsBottomSheet = false,
  });

  @override
  State<CarrinhoPagamentoWidget> createState() => _CarrinhoPagamentoWidgetState();
}

class _CarrinhoPagamentoWidgetState extends State<CarrinhoPagamentoWidget> {
  FormaPagamento? _formaPagamentoSelecionada;
  final _valorPagoController = TextEditingController();
  double? _troco;
  bool _mostrarPagamento = false;

  double get total => widget.itens.fold(0, (sum, item) => sum + item.subtotal);
  int get totalItens => widget.itens.fold(0, (sum, item) => sum + item.quantidade);

  @override
  void dispose() {
    _valorPagoController.dispose();
    super.dispose();
  }

  void _calcularTroco() {
    if (_formaPagamentoSelecionada != FormaPagamento.dinheiro) {
      setState(() => _troco = null);
      return;
    }

    final valorPagoText = _valorPagoController.text
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    if (valorPagoText.isEmpty) {
      setState(() => _troco = null);
      return;
    }

    try {
      final valorPago = double.parse(valorPagoText);
      if (valorPago >= total) {
        setState(() => _troco = valorPago - total);
      } else {
        setState(() => _troco = null);
      }
    } catch (e) {
      setState(() => _troco = null);
    }
  }

  void _finalizarPedido() {
    if (_formaPagamentoSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma forma de pagamento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    double? valorPago;
    if (_formaPagamentoSelecionada == FormaPagamento.dinheiro && _valorPagoController.text.isNotEmpty) {
      final valorPagoText = _valorPagoController.text
          .replaceAll('R\$', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();
      valorPago = double.tryParse(valorPagoText);
      
      if (valorPago == null || valorPago < total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Valor pago insuficiente'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    widget.onFinalizarPedido(_formaPagamentoSelecionada!, valorPago, _troco);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Carrinho de compras com pagamento',
      child: Container(
        width: widget.showAsBottomSheet ? double.infinity : 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: widget.showAsBottomSheet
              ? const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                )
              : null,
          boxShadow: widget.showAsBottomSheet
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
                borderRadius: widget.showAsBottomSheet
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
                  if (widget.itens.isNotEmpty) ...[
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

            // Content
            Expanded(
              child: widget.itens.isEmpty
                  ? _buildEmptyState()
                  : _mostrarPagamento
                      ? _buildPagamentoView()
                      : _buildItensView(),
            ),

            // Footer
            if (widget.itens.isNotEmpty) _buildFooter(context),
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

  Widget _buildItensView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.itens.length,
      itemBuilder: (context, index) {
        final item = widget.itens[index];
        return _buildCarrinhoItem(context, item);
      },
    );
  }

  Widget _buildPagamentoView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumo do pedido
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumo do Pedido',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total de itens: $totalItens'),
                      Text(
                        _formatCurrency(total),
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
          ),
          
          const SizedBox(height: 20),
          
          // Formas de pagamento
          const Text(
            'Forma de Pagamento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          ...FormaPagamento.values.map((forma) => Card(
            child: RadioListTile<FormaPagamento>(
              value: forma,
              groupValue: _formaPagamentoSelecionada,
              onChanged: (value) {
                setState(() {
                  _formaPagamentoSelecionada = value;
                  if (value != FormaPagamento.dinheiro) {
                    _valorPagoController.clear();
                    _troco = null;
                  }
                });
              },
              title: Text(forma.label),
              secondary: Icon(forma.icon),
              activeColor: const Color(0xFFDC2626),
            ),
          )),
          
          // Campo de valor pago (apenas para dinheiro)
          if (_formaPagamentoSelecionada == FormaPagamento.dinheiro) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Valor Recebido',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _valorPagoController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                      ],
                      decoration: InputDecoration(
                        prefixText: 'R\$ ',
                        hintText: '0,00',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      onChanged: (value) => _calcularTroco(),
                    ),
                    if (_troco != null && _troco! > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Troco:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _formatCurrency(_troco!),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
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
                  onPressed: () => widget.onItemRemoved(item),
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
                          ? () => widget.onQuantidadeChanged(item, item.quantidade - 1)
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
                          widget.onQuantidadeChanged(item, item.quantidade + 1),
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
          Row(
            children: [
              if (_mostrarPagamento)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _mostrarPagamento = false;
                        _formaPagamentoSelecionada = null;
                        _valorPagoController.clear();
                        _troco = null;
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              if (_mostrarPagamento) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.itens.isEmpty 
                      ? null 
                      : _mostrarPagamento 
                          ? _finalizarPedido
                          : () => setState(() => _mostrarPagamento = true),
                  icon: Icon(_mostrarPagamento ? Icons.check : Icons.payment),
                  label: Text(
                    _mostrarPagamento ? 'Finalizar Pedido' : 'Ir para Pagamento',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
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

// Helper function to show cart with payment as bottom sheet
void showCarrinhoPagamentoBottomSheet({
  required BuildContext context,
  required List<CarrinhoItem> itens,
  required Function(CarrinhoItem item, int quantidade) onQuantidadeChanged,
  required Function(CarrinhoItem item) onItemRemoved,
  required Function(FormaPagamento formaPagamento, double? valorPago, double? troco) onFinalizarPedido,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => CarrinhoPagamentoWidget(
        itens: itens,
        onQuantidadeChanged: onQuantidadeChanged,
        onItemRemoved: onItemRemoved,
        onFinalizarPedido: onFinalizarPedido,
        showAsBottomSheet: true,
      ),
    ),
  );
}