import 'package:equatable/equatable.dart';

enum TipoMovimentoEstoque {
  entrada,
  saida,
  ajuste,
}

class MovimentoEstoque extends Equatable {
  final int id;
  final int ingredienteId;
  final TipoMovimentoEstoque tipo;
  final double quantidade;
  final double valorUnitario;
  final String? observacoes;
  final String? numeroDocumento;
  final DateTime dataMovimento;
  final String dataCadastro;

  const MovimentoEstoque({
    required this.id,
    required this.ingredienteId,
    required this.tipo,
    required this.quantidade,
    required this.valorUnitario,
    this.observacoes,
    this.numeroDocumento,
    required this.dataMovimento,
    required this.dataCadastro,
  });

  double get valorTotal => quantidade * valorUnitario;
  bool get isEntrada => tipo == TipoMovimentoEstoque.entrada;
  bool get isSaida => tipo == TipoMovimentoEstoque.saida;

  MovimentoEstoque copyWith({
    int? id,
    int? ingredienteId,
    TipoMovimentoEstoque? tipo,
    double? quantidade,
    double? valorUnitario,
    String? observacoes,
    String? numeroDocumento,
    DateTime? dataMovimento,
    String? dataCadastro,
  }) {
    return MovimentoEstoque(
      id: id ?? this.id,
      ingredienteId: ingredienteId ?? this.ingredienteId,
      tipo: tipo ?? this.tipo,
      quantidade: quantidade ?? this.quantidade,
      valorUnitario: valorUnitario ?? this.valorUnitario,
      observacoes: observacoes ?? this.observacoes,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      dataMovimento: dataMovimento ?? this.dataMovimento,
      dataCadastro: dataCadastro ?? this.dataCadastro,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ingredienteId,
        tipo,
        quantidade,
        valorUnitario,
        observacoes,
        numeroDocumento,
        dataMovimento,
        dataCadastro,
      ];
}