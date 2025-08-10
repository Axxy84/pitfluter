import 'package:equatable/equatable.dart';

enum TipoPedido {
  entrega,
  balcao,
}

class Pedido extends Equatable {
  final int id;
  final String numero;
  final int? mesaId;
  final double subtotal;
  final double taxaEntrega;
  final double desconto;
  final double total;
  final String formaPagamento;
  final TipoPedido tipo;
  final String? observacoes;
  final DateTime dataHoraCriacao;
  final DateTime? dataHoraEntrega;
  final int tempoEstimadoMinutos;

  const Pedido({
    required this.id,
    required this.numero,
    this.mesaId,
    required this.subtotal,
    required this.taxaEntrega,
    required this.desconto,
    required this.total,
    required this.formaPagamento,
    required this.tipo,
    this.observacoes,
    required this.dataHoraCriacao,
    this.dataHoraEntrega,
    required this.tempoEstimadoMinutos,
  });

  double calcularTotal() {
    return subtotal + taxaEntrega - desconto;
  }

  // Removidas funções relacionadas a status

  Pedido copyWith({
    int? id,
    String? numero,
    int? mesaId,
    double? subtotal,
    double? taxaEntrega,
    double? desconto,
    double? total,
    String? formaPagamento,
    TipoPedido? tipo,
    String? observacoes,
    DateTime? dataHoraCriacao,
    DateTime? dataHoraEntrega,
    int? tempoEstimadoMinutos,
  }) {
    return Pedido(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      mesaId: mesaId ?? this.mesaId,
      subtotal: subtotal ?? this.subtotal,
      taxaEntrega: taxaEntrega ?? this.taxaEntrega,
      desconto: desconto ?? this.desconto,
      total: total ?? this.total,
      formaPagamento: formaPagamento ?? this.formaPagamento,
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
        mesaId,
        subtotal,
        taxaEntrega,
        desconto,
        total,
        formaPagamento,
        tipo,
        observacoes,
        dataHoraCriacao,
        dataHoraEntrega,
        tempoEstimadoMinutos,
      ];
}