import 'package:equatable/equatable.dart';

class Produto extends Equatable {
  final int id;
  final String nome;
  final String? descricao;
  final int categoriaId;
  final String? sku;
  final String? imagemUrl;
  final bool ativo;
  final int tempoPreparoMinutos;
  final int ordem;
  final String? observacoes;
  final String dataCadastro;
  final String ultimaAtualizacao;

  const Produto({
    required this.id,
    required this.nome,
    this.descricao,
    required this.categoriaId,
    this.sku,
    this.imagemUrl,
    required this.ativo,
    required this.tempoPreparoMinutos,
    required this.ordem,
    this.observacoes,
    required this.dataCadastro,
    required this.ultimaAtualizacao,
  });

  bool get estaDisponivel => ativo;

  Produto copyWith({
    int? id,
    String? nome,
    String? descricao,
    int? categoriaId,
    String? sku,
    String? imagemUrl,
    bool? ativo,
    int? tempoPreparoMinutos,
    int? ordem,
    String? observacoes,
    String? dataCadastro,
    String? ultimaAtualizacao,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      categoriaId: categoriaId ?? this.categoriaId,
      sku: sku ?? this.sku,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      ativo: ativo ?? this.ativo,
      tempoPreparoMinutos: tempoPreparoMinutos ?? this.tempoPreparoMinutos,
      ordem: ordem ?? this.ordem,
      observacoes: observacoes ?? this.observacoes,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        descricao,
        categoriaId,
        sku,
        imagemUrl,
        ativo,
        tempoPreparoMinutos,
        ordem,
        observacoes,
        dataCadastro,
        ultimaAtualizacao,
      ];

  @override
  String toString() {
    return 'Produto{id: $id, nome: $nome, descricao: $descricao, categoriaId: $categoriaId, sku: $sku, imagemUrl: $imagemUrl, ativo: $ativo, tempoPreparoMinutos: $tempoPreparoMinutos, ordem: $ordem, observacoes: $observacoes, dataCadastro: $dataCadastro, ultimaAtualizacao: $ultimaAtualizacao}';
  }
}