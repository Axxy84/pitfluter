import 'package:equatable/equatable.dart';

class Ingrediente extends Equatable {
  final int id;
  final String nome;
  final String? descricao;
  final int unidadeMedidaId;
  final double quantidadeEstoque;
  final double quantidadeMinima;
  final double custoUnitario;
  final bool ativo;
  final String dataCadastro;
  final String ultimaAtualizacao;

  const Ingrediente({
    required this.id,
    required this.nome,
    this.descricao,
    required this.unidadeMedidaId,
    required this.quantidadeEstoque,
    required this.quantidadeMinima,
    required this.custoUnitario,
    required this.ativo,
    required this.dataCadastro,
    required this.ultimaAtualizacao,
  });

  bool get precisaReposicao => quantidadeEstoque <= quantidadeMinima;
  bool get estaDisponivel => ativo && quantidadeEstoque > 0;
  double get valorTotalEstoque => quantidadeEstoque * custoUnitario;

  Ingrediente copyWith({
    int? id,
    String? nome,
    String? descricao,
    int? unidadeMedidaId,
    double? quantidadeEstoque,
    double? quantidadeMinima,
    double? custoUnitario,
    bool? ativo,
    String? dataCadastro,
    String? ultimaAtualizacao,
  }) {
    return Ingrediente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      unidadeMedidaId: unidadeMedidaId ?? this.unidadeMedidaId,
      quantidadeEstoque: quantidadeEstoque ?? this.quantidadeEstoque,
      quantidadeMinima: quantidadeMinima ?? this.quantidadeMinima,
      custoUnitario: custoUnitario ?? this.custoUnitario,
      ativo: ativo ?? this.ativo,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        descricao,
        unidadeMedidaId,
        quantidadeEstoque,
        quantidadeMinima,
        custoUnitario,
        ativo,
        dataCadastro,
        ultimaAtualizacao,
      ];
}