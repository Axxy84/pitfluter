import 'package:equatable/equatable.dart';

enum MesaStatus {
  livre,
  ocupada,
  inativa,
}

class Mesa extends Equatable {
  final int id;
  final int numero;
  final String? descricao;
  final int capacidade;
  final bool ativa;
  final bool ocupada;
  final String? observacoes;
  final String dataCadastro;
  final String ultimaAtualizacao;

  const Mesa({
    required this.id,
    required this.numero,
    this.descricao,
    required this.capacidade,
    required this.ativa,
    required this.ocupada,
    this.observacoes,
    required this.dataCadastro,
    required this.ultimaAtualizacao,
  });

  bool get estaDisponivel => ativa && !ocupada;

  MesaStatus get status {
    if (!ativa) return MesaStatus.inativa;
    if (ocupada) return MesaStatus.ocupada;
    return MesaStatus.livre;
  }

  Mesa copyWith({
    int? id,
    int? numero,
    String? descricao,
    int? capacidade,
    bool? ativa,
    bool? ocupada,
    String? observacoes,
    String? dataCadastro,
    String? ultimaAtualizacao,
  }) {
    return Mesa(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      descricao: descricao ?? this.descricao,
      capacidade: capacidade ?? this.capacidade,
      ativa: ativa ?? this.ativa,
      ocupada: ocupada ?? this.ocupada,
      observacoes: observacoes ?? this.observacoes,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
    );
  }

  @override
  List<Object?> get props => [
        id,
        numero,
        descricao,
        capacidade,
        ativa,
        ocupada,
        observacoes,
        dataCadastro,
        ultimaAtualizacao,
      ];

  @override
  String toString() {
    return 'Mesa{id: $id, numero: $numero, descricao: $descricao, capacidade: $capacidade, ativa: $ativa, ocupada: $ocupada, observacoes: $observacoes, dataCadastro: $dataCadastro, ultimaAtualizacao: $ultimaAtualizacao}';
  }
}