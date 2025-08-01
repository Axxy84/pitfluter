import '../../domain/entities/categoria.dart';

class CategoriaModel extends Categoria {
  const CategoriaModel({
    required super.id,
    required super.nome,
    super.descricao,
    required super.ativo,
    required super.ordem,
    required super.dataCadastro,
    required super.ultimaAtualizacao,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
      ativo: json['ativo'] as bool,
      ordem: json['ordem'] as int,
      dataCadastro: json['data_cadastro'] as String,
      ultimaAtualizacao: json['ultima_atualizacao'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'ativo': ativo,
      'ordem': ordem,
      'data_cadastro': dataCadastro,
      'ultima_atualizacao': ultimaAtualizacao,
    };
  }

  factory CategoriaModel.fromEntity(Categoria categoria) {
    return CategoriaModel(
      id: categoria.id,
      nome: categoria.nome,
      descricao: categoria.descricao,
      ativo: categoria.ativo,
      ordem: categoria.ordem,
      dataCadastro: categoria.dataCadastro,
      ultimaAtualizacao: categoria.ultimaAtualizacao,
    );
  }
}