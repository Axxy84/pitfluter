import 'package:equatable/equatable.dart';

class Cliente extends Equatable {
  final int id;
  final String nome;
  final String telefone;
  final String? email;
  final String? cpfCnpj;
  final DateTime? dataNascimento;
  final String? observacoes;
  final bool ativo;
  final DateTime dataCadastro;
  final DateTime ultimaAtualizacao;

  const Cliente({
    required this.id,
    required this.nome,
    required this.telefone,
    this.email,
    this.cpfCnpj,
    this.dataNascimento,
    this.observacoes,
    required this.ativo,
    required this.dataCadastro,
    required this.ultimaAtualizacao,
  });

  Cliente copyWith({
    int? id,
    String? nome,
    String? telefone,
    String? email,
    String? cpfCnpj,
    DateTime? dataNascimento,
    String? observacoes,
    bool? ativo,
    DateTime? dataCadastro,
    DateTime? ultimaAtualizacao,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      observacoes: observacoes ?? this.observacoes,
      ativo: ativo ?? this.ativo,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        telefone,
        email,
        cpfCnpj,
        dataNascimento,
        observacoes,
        ativo,
        dataCadastro,
        ultimaAtualizacao,
      ];
}