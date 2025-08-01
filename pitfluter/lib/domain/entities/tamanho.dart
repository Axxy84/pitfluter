import 'package:equatable/equatable.dart';

class Tamanho extends Equatable {
  final int id;
  final String nome;
  final String? descricao;
  final double fatorMultiplicador;
  final bool ativo;
  final int ordem;
  final String dataCadastro;
  final String ultimaAtualizacao;

  const Tamanho({
    required this.id,
    required this.nome,
    this.descricao,
    required this.fatorMultiplicador,
    required this.ativo,
    required this.ordem,
    required this.dataCadastro,
    required this.ultimaAtualizacao,
  });

  double calcularPreco(double precoBase) {
    return precoBase * fatorMultiplicador;
  }

  Tamanho copyWith({
    int? id,
    String? nome,
    String? descricao,
    double? fatorMultiplicador,
    bool? ativo,
    int? ordem,
    String? dataCadastro,
    String? ultimaAtualizacao,
  }) {
    return Tamanho(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      fatorMultiplicador: fatorMultiplicador ?? this.fatorMultiplicador,
      ativo: ativo ?? this.ativo,
      ordem: ordem ?? this.ordem,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        descricao,
        fatorMultiplicador,
        ativo,
        ordem,
        dataCadastro,
        ultimaAtualizacao,
      ];

  @override
  String toString() {
    return 'Tamanho{id: $id, nome: $nome, descricao: $descricao, fatorMultiplicador: $fatorMultiplicador, ativo: $ativo, ordem: $ordem, dataCadastro: $dataCadastro, ultimaAtualizacao: $ultimaAtualizacao}';
  }
}