import 'package:equatable/equatable.dart';

enum StatusContaPagar {
  pendente,
  paga,
  vencida,
  cancelada,
}

class ContaPagar extends Equatable {
  final int id;
  final String descricao;
  final double valor;
  final DateTime dataVencimento;
  final DateTime? dataPagamento;
  final StatusContaPagar status;
  final String? observacoes;
  final String? numeroDocumento;
  final String dataCadastro;
  final String ultimaAtualizacao;

  const ContaPagar({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.dataVencimento,
    this.dataPagamento,
    required this.status,
    this.observacoes,
    this.numeroDocumento,
    required this.dataCadastro,
    required this.ultimaAtualizacao,
  });

  bool get estaPaga => status == StatusContaPagar.paga;
  bool get estaVencida => status == StatusContaPagar.vencida || 
      (status == StatusContaPagar.pendente && DateTime.now().isAfter(dataVencimento));
  bool get estaPendente => status == StatusContaPagar.pendente;

  int get diasAteVencimento => dataVencimento.difference(DateTime.now()).inDays;

  ContaPagar copyWith({
    int? id,
    String? descricao,
    double? valor,
    DateTime? dataVencimento,
    DateTime? dataPagamento,
    StatusContaPagar? status,
    String? observacoes,
    String? numeroDocumento,
    String? dataCadastro,
    String? ultimaAtualizacao,
  }) {
    return ContaPagar(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      dataPagamento: dataPagamento ?? this.dataPagamento,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
    );
  }

  @override
  List<Object?> get props => [
        id,
        descricao,
        valor,
        dataVencimento,
        dataPagamento,
        status,
        observacoes,
        numeroDocumento,
        dataCadastro,
        ultimaAtualizacao,
      ];
}