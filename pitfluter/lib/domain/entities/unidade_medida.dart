import 'package:equatable/equatable.dart';

class UnidadeMedida extends Equatable {
  final int id;
  final String nome;
  final String sigla;
  final String? descricao;
  final bool ativa;
  final String dataCadastro;
  final String ultimaAtualizacao;

  const UnidadeMedida({
    required this.id,
    required this.nome,
    required this.sigla,
    this.descricao,
    required this.ativa,
    required this.dataCadastro,
    required this.ultimaAtualizacao,
  });

  UnidadeMedida copyWith({
    int? id,
    String? nome,
    String? sigla,
    String? descricao,
    bool? ativa,
    String? dataCadastro,
    String? ultimaAtualizacao,
  }) {
    return UnidadeMedida(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      sigla: sigla ?? this.sigla,
      descricao: descricao ?? this.descricao,
      ativa: ativa ?? this.ativa,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        sigla,
        descricao,
        ativa,
        dataCadastro,
        ultimaAtualizacao,
      ];
}