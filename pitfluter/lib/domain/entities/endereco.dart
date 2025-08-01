import 'package:equatable/equatable.dart';

class Endereco extends Equatable {
  final int id;
  final int clienteId;
  final String apelido;
  final String logradouro;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;
  final String? complemento;
  final String? referencia;
  final double taxaEntrega;
  final int tempoEntregaMinutos;
  final bool ativo;
  final bool padrao;

  const Endereco({
    required this.id,
    required this.clienteId,
    required this.apelido,
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.cep,
    this.complemento,
    this.referencia,
    required this.taxaEntrega,
    required this.tempoEntregaMinutos,
    required this.ativo,
    required this.padrao,
  });

  String get enderecoCompleto {
    final cepFormatado = '${cep.substring(0, 5)}-${cep.substring(5)}';
    
    if (complemento != null && complemento!.isNotEmpty) {
      return '$logradouro, $complemento - $bairro, $cidade - $estado, $cepFormatado';
    } else {
      return '$logradouro - $bairro, $cidade - $estado, $cepFormatado';
    }
  }

  Endereco copyWith({
    int? id,
    int? clienteId,
    String? apelido,
    String? logradouro,
    String? bairro,
    String? cidade,
    String? estado,
    String? cep,
    String? complemento,
    String? referencia,
    double? taxaEntrega,
    int? tempoEntregaMinutos,
    bool? ativo,
    bool? padrao,
  }) {
    return Endereco(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      apelido: apelido ?? this.apelido,
      logradouro: logradouro ?? this.logradouro,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      cep: cep ?? this.cep,
      complemento: complemento ?? this.complemento,
      referencia: referencia ?? this.referencia,
      taxaEntrega: taxaEntrega ?? this.taxaEntrega,
      tempoEntregaMinutos: tempoEntregaMinutos ?? this.tempoEntregaMinutos,
      ativo: ativo ?? this.ativo,
      padrao: padrao ?? this.padrao,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clienteId,
        apelido,
        logradouro,
        bairro,
        cidade,
        estado,
        cep,
        complemento,
        referencia,
        taxaEntrega,
        tempoEntregaMinutos,
        ativo,
        padrao,
      ];
}