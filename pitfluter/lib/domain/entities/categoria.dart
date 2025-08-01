import 'package:equatable/equatable.dart';

class Categoria extends Equatable {
  final int id;
  final String nome;
  final String? descricao;
  final bool ativo;
  final int ordem;
  final String dataCadastro;
  final String ultimaAtualizacao;

  const Categoria({
    required this.id,
    required this.nome,
    this.descricao,
    required this.ativo,
    required this.ordem,
    required this.dataCadastro,
    required this.ultimaAtualizacao,
  });

  Categoria copyWith({
    int? id,
    String? nome,
    String? descricao,
    bool? ativo,
    int? ordem,
    String? dataCadastro,
    String? ultimaAtualizacao,
  }) {
    return Categoria(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
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
        ativo,
        ordem,
        dataCadastro,
        ultimaAtualizacao,
      ];

  @override
  String toString() {
    return 'Categoria{id: $id, nome: $nome, descricao: $descricao, ativo: $ativo, ordem: $ordem, dataCadastro: $dataCadastro, ultimaAtualizacao: $ultimaAtualizacao}';
  }
}