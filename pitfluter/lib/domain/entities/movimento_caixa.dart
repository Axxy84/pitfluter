import 'package:equatable/equatable.dart';

enum TipoMovimentoCaixa {
  entrada,
  saida,
  sangria,
}

class MovimentoCaixa extends Equatable {
  final int id;
  final int caixaId;
  final TipoMovimentoCaixa tipo;
  final double valor;
  final String descricao;
  final String? observacoes;
  final DateTime dataMovimento;
  final String dataCadastro;

  const MovimentoCaixa({
    required this.id,
    required this.caixaId,
    required this.tipo,
    required this.valor,
    required this.descricao,
    this.observacoes,
    required this.dataMovimento,
    required this.dataCadastro,
  });

  bool get isEntrada => tipo == TipoMovimentoCaixa.entrada;
  bool get isSaida => tipo == TipoMovimentoCaixa.saida;
  bool get isSangria => tipo == TipoMovimentoCaixa.sangria;

  MovimentoCaixa copyWith({
    int? id,
    int? caixaId,
    TipoMovimentoCaixa? tipo,
    double? valor,
    String? descricao,
    String? observacoes,
    DateTime? dataMovimento,
    String? dataCadastro,
  }) {
    return MovimentoCaixa(
      id: id ?? this.id,
      caixaId: caixaId ?? this.caixaId,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      descricao: descricao ?? this.descricao,
      observacoes: observacoes ?? this.observacoes,
      dataMovimento: dataMovimento ?? this.dataMovimento,
      dataCadastro: dataCadastro ?? this.dataCadastro,
    );
  }

  @override
  List<Object?> get props => [
        id,
        caixaId,
        tipo,
        valor,
        descricao,
        observacoes,
        dataMovimento,
        dataCadastro,
      ];
}