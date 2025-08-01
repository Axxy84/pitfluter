import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/pedido.dart';

class PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback? onTap;

  const PedidoCard({
    super.key,
    required this.pedido,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(pedido.status);
    final statusText = _getStatusText(pedido.status);
    final typeIcon = _getTypeIcon(pedido.tipo);
    
    return Card(
      color: statusColor.withOpacity(0.1),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Semantics(
          label: 'Pedido ${pedido.numero}, status ${statusText.toLowerCase()}, total ${_formatCurrency(pedido.total)}',
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          typeIcon,
                          color: statusColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          pedido.numero,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          _formatCurrency(pedido.total),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Tempo estimado',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${pedido.tempoEstimadoMinutos} min',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Criado em ${_formatDateTime(pedido.dataHoraCriacao)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(PedidoStatus status) {
    switch (status) {
      case PedidoStatus.recebido:
        return Colors.blue;
      case PedidoStatus.preparando:
        return Colors.orange;
      case PedidoStatus.saindo:
        return Colors.purple;
      case PedidoStatus.entregue:
        return Colors.green;
      case PedidoStatus.cancelado:
        return Colors.red;
    }
  }

  String _getStatusText(PedidoStatus status) {
    switch (status) {
      case PedidoStatus.recebido:
        return 'RECEBIDO';
      case PedidoStatus.preparando:
        return 'PREPARANDO';
      case PedidoStatus.saindo:
        return 'SAINDO';
      case PedidoStatus.entregue:
        return 'ENTREGUE';
      case PedidoStatus.cancelado:
        return 'CANCELADO';
    }
  }

  IconData _getTypeIcon(TipoPedido tipo) {
    switch (tipo) {
      case TipoPedido.entrega:
        return Icons.delivery_dining;
      case TipoPedido.balcao:
        return Icons.store;
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    ).format(value);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(dateTime);
  }
}