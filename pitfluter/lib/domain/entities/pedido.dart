import 'package:equatable/equatable.dart';

enum PedidoStatus {
  recebido,
  preparando,
  saindo,
  entregue,
  cancelado,
}

enum TipoPedido {
  entrega,
  balcao,
}

class Pedido extends Equatable {
  final int id;
  final String numero;
  final int? clienteId;
  final int? enderecoId;
  final int? mesaId;
  final double subtotal;
  final double taxaEntrega;
  final double desconto;
  final double total;
  final String formaPagamento;
  final PedidoStatus status;
  final TipoPedido tipo;
  final String? observacoes;
  final DateTime dataHoraCriacao;
  final DateTime? dataHoraEntrega;
  final int tempoEstimadoMinutos;

  const Pedido({
    required this.id,
    required this.numero,
    this.clienteId,
    this.enderecoId,
    this.mesaId,
    required this.subtotal,
    required this.taxaEntrega,
    required this.desconto,
    required this.total,
    required this.formaPagamento,
    required this.status,
    required this.tipo,
    this.observacoes,
    required this.dataHoraCriacao,
    this.dataHoraEntrega,
    required this.tempoEstimadoMinutos,
  });

  double calcularTotal() {
    return subtotal + taxaEntrega - desconto;
  }

  bool get estaEmAndamento {
    return status != PedidoStatus.entregue && status != PedidoStatus.cancelado;
  }

  bool get podeCancelar {
    return status == PedidoStatus.recebido || status == PedidoStatus.preparando;
  }

  Pedido copyWith({
    int? id,
    String? numero,
    int? clienteId,
    int? enderecoId,
    int? mesaId,
    double? subtotal,
    double? taxaEntrega,
    double? desconto,
    double? total,
    String? formaPagamento,
    PedidoStatus? status,
    TipoPedido? tipo,
    String? observacoes,
    DateTime? dataHoraCriacao,
    DateTime? dataHoraEntrega,
    int? tempoEstimadoMinutos,
  }) {
    return Pedido(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      clienteId: clienteId ?? this.clienteId,
      enderecoId: enderecoId ?? this.enderecoId,
      mesaId: mesaId ?? this.mesaId,
      subtotal: subtotal ?? this.subtotal,
      taxaEntrega: taxaEntrega ?? this.taxaEntrega,
      desconto: desconto ?? this.desconto,
      total: total ?? this.total,
      formaPagamento: formaPagamento ?? this.formaPagamento,
      status: status ?? this.status,
      tipo: tipo ?? this.tipo,
      observacoes: observacoes ?? this.observacoes,
      dataHoraCriacao: dataHoraCriacao ?? this.dataHoraCriacao,
      dataHoraEntrega: dataHoraEntrega ?? this.dataHoraEntrega,
      tempoEstimadoMinutos: tempoEstimadoMinutos ?? this.tempoEstimadoMinutos,
    );
  }

  @override
  List<Object?> get props => [
        id,
        numero,
        clienteId,
        enderecoId,
        mesaId,
        subtotal,
        taxaEntrega,
        desconto,
        total,
        formaPagamento,
        status,
        tipo,
        observacoes,
        dataHoraCriacao,
        dataHoraEntrega,
        tempoEstimadoMinutos,
      ];
}