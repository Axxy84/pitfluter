import 'package:equatable/equatable.dart';

enum TipoMovimento {
  venda,
  sangria,
  suprimento,
  abertura,
  fechamento,
}

enum FormaPagamento {
  dinheiro,
  cartao,
  pix,
}

class MovimentoCaixa extends Equatable {
  final int id;
  final int caixaId;
  final TipoMovimento tipo;
  final double valor;
  final String descricao;
  final FormaPagamento formaPagamento;
  final DateTime dataHora;
  final String? observacoes;
  final String dataCadastro;

  const MovimentoCaixa({
    required this.id,
    required this.caixaId,
    required this.tipo,
    required this.valor,
    required this.descricao,
    required this.formaPagamento,
    required this.dataHora,
    this.observacoes,
    required this.dataCadastro,
  });

  bool get isEntrada => tipo == TipoMovimento.venda || tipo == TipoMovimento.suprimento;
  bool get isSaida => tipo == TipoMovimento.sangria;
  bool get isSangria => tipo == TipoMovimento.sangria;

  MovimentoCaixa copyWith({
    int? id,
    int? caixaId,
    TipoMovimento? tipo,
    double? valor,
    String? descricao,
    FormaPagamento? formaPagamento,
    DateTime? dataHora,
    String? observacoes,
    String? dataCadastro,
  }) {
    return MovimentoCaixa(
      id: id ?? this.id,
      caixaId: caixaId ?? this.caixaId,
      tipo: tipo ?? this.tipo,
      valor: valor ?? this.valor,
      descricao: descricao ?? this.descricao,
      formaPagamento: formaPagamento ?? this.formaPagamento,
      dataHora: dataHora ?? this.dataHora,
      observacoes: observacoes ?? this.observacoes,
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
        formaPagamento,
        dataHora,
        observacoes,
        dataCadastro,
      ];
}