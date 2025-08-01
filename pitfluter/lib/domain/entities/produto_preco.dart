import 'package:equatable/equatable.dart';

class ProdutoPreco extends Equatable {
  final int id;
  final int produtoId;
  final int tamanhoId;
  final double preco;
  final double? precoPromocional;
  final bool ativo;
  final String dataCadastro;
  final String ultimaAtualizacao;

  const ProdutoPreco({
    required this.id,
    required this.produtoId,
    required this.tamanhoId,
    required this.preco,
    this.precoPromocional,
    required this.ativo,
    required this.dataCadastro,
    required this.ultimaAtualizacao,
  });

  double get precoFinal => precoPromocional ?? preco;

  bool get temPromocao => precoPromocional != null && precoPromocional! < preco;

  double get percentualDesconto {
    if (!temPromocao) return 0.0;
    return ((preco - precoPromocional!) / preco) * 100;
  }

  ProdutoPreco copyWith({
    int? id,
    int? produtoId,
    int? tamanhoId,
    double? preco,
    double? precoPromocional,
    bool? ativo,
    String? dataCadastro,
    String? ultimaAtualizacao,
  }) {
    return ProdutoPreco(
      id: id ?? this.id,
      produtoId: produtoId ?? this.produtoId,
      tamanhoId: tamanhoId ?? this.tamanhoId,
      preco: preco ?? this.preco,
      precoPromocional: precoPromocional ?? this.precoPromocional,
      ativo: ativo ?? this.ativo,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
    );
  }

  @override
  List<Object?> get props => [
        id,
        produtoId,
        tamanhoId,
        preco,
        precoPromocional,
        ativo,
        dataCadastro,
        ultimaAtualizacao,
      ];

  @override
  String toString() {
    return 'ProdutoPreco{id: $id, produtoId: $produtoId, tamanhoId: $tamanhoId, preco: $preco, precoPromocional: $precoPromocional, ativo: $ativo, dataCadastro: $dataCadastro, ultimaAtualizacao: $ultimaAtualizacao}';
  }
}