import 'package:equatable/equatable.dart';

class Settings extends Equatable {
  final int id;
  final String nomeEstabelecimento;
  final String? telefone;
  final String? endereco;
  final String? email;
  final String? logoUrl;
  final bool aceitaEntrega;
  final bool aceitaBalcao;
  final bool aceitaMesa;
  final String moeda;
  final String timezone;
  final String idioma;
  final String dataCadastro;
  final String ultimaAtualizacao;

  const Settings({
    required this.id,
    required this.nomeEstabelecimento,
    this.telefone,
    this.endereco,
    this.email,
    this.logoUrl,
    required this.aceitaEntrega,
    required this.aceitaBalcao,
    required this.aceitaMesa,
    required this.moeda,
    required this.timezone,
    required this.idioma,
    required this.dataCadastro,
    required this.ultimaAtualizacao,
  });

  bool get temConfiguracoesCompletas => 
      nomeEstabelecimento.isNotEmpty && 
      telefone != null && 
      endereco != null;

  Settings copyWith({
    int? id,
    String? nomeEstabelecimento,
    String? telefone,
    String? endereco,
    String? email,
    String? logoUrl,
    bool? aceitaEntrega,
    bool? aceitaBalcao,
    bool? aceitaMesa,
    String? moeda,
    String? timezone,
    String? idioma,
    String? dataCadastro,
    String? ultimaAtualizacao,
  }) {
    return Settings(
      id: id ?? this.id,
      nomeEstabelecimento: nomeEstabelecimento ?? this.nomeEstabelecimento,
      telefone: telefone ?? this.telefone,
      endereco: endereco ?? this.endereco,
      email: email ?? this.email,
      logoUrl: logoUrl ?? this.logoUrl,
      aceitaEntrega: aceitaEntrega ?? this.aceitaEntrega,
      aceitaBalcao: aceitaBalcao ?? this.aceitaBalcao,
      aceitaMesa: aceitaMesa ?? this.aceitaMesa,
      moeda: moeda ?? this.moeda,
      timezone: timezone ?? this.timezone,
      idioma: idioma ?? this.idioma,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nomeEstabelecimento,
        telefone,
        endereco,
        email,
        logoUrl,
        aceitaEntrega,
        aceitaBalcao,
        aceitaMesa,
        moeda,
        timezone,
        idioma,
        dataCadastro,
        ultimaAtualizacao,
      ];
}