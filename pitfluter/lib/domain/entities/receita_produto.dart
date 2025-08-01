import 'package:equatable/equatable.dart';

class ReceitaProduto extends Equatable {
  final int id;
  final int produtoId;
  final int ingredienteId;
  final double quantidade;
  final bool ativo;
  final String dataCadastro;
  final String ultimaAtualizacao;

  const ReceitaProduto({
    required this.id,
    required this.produtoId,
    required this.ingredienteId,
    required this.quantidade,
    required this.ativo,
    required this.dataCadastro,
    required this.ultimaAtualizacao,
  });

  double calcularCusto(double custoIngrediente) {
    return quantidade * custoIngrediente;
  }

  ReceitaProduto copyWith({
    int? id,
    int? produtoId,
    int? ingredienteId,
    double? quantidade,
    bool? ativo,
    String? dataCadastro,
    String? ultimaAtualizacao,
  }) {
    return ReceitaProduto(
      id: id ?? this.id,
      produtoId: produtoId ?? this.produtoId,
      ingredienteId: ingredienteId ?? this.ingredienteId,
      quantidade: quantidade ?? this.quantidade,
      ativo: ativo ?? this.ativo,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
    );
  }

  @override
  List<Object?> get props => [
        id,
        produtoId,
        ingredienteId,
        quantidade,
        ativo,
        dataCadastro,
        ultimaAtualizacao,
      ];
}