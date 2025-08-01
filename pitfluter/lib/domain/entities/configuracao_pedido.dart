import 'package:equatable/equatable.dart';

class ConfiguracaoPedido extends Equatable {
  final int id;
  final double taxaEntregaMinima;
  final double valorMinimoEntrega;
  final int tempoMedioPreparo;
  final double raioEntregaKm;
  final bool ativa;
  final String? observacoes;
  final String dataCadastro;
  final String ultimaAtualizacao;

  const ConfiguracaoPedido({
    required this.id,
    required this.taxaEntregaMinima,
    required this.valorMinimoEntrega,
    required this.tempoMedioPreparo,
    required this.raioEntregaKm,
    required this.ativa,
    this.observacoes,
    required this.dataCadastro,
    required this.ultimaAtualizacao,
  });

  bool podeEntregar(double valorPedido, double distanciaKm) {
    return valorPedido >= valorMinimoEntrega && distanciaKm <= raioEntregaKm;
  }

  ConfiguracaoPedido copyWith({
    int? id,
    double? taxaEntregaMinima,
    double? valorMinimoEntrega,
    int? tempoMedioPreparo,
    double? raioEntregaKm,
    bool? ativa,
    String? observacoes,
    String? dataCadastro,
    String? ultimaAtualizacao,
  }) {
    return ConfiguracaoPedido(
      id: id ?? this.id,
      taxaEntregaMinima: taxaEntregaMinima ?? this.taxaEntregaMinima,
      valorMinimoEntrega: valorMinimoEntrega ?? this.valorMinimoEntrega,
      tempoMedioPreparo: tempoMedioPreparo ?? this.tempoMedioPreparo,
      raioEntregaKm: raioEntregaKm ?? this.raioEntregaKm,
      ativa: ativa ?? this.ativa,
      observacoes: observacoes ?? this.observacoes,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taxaEntregaMinima,
        valorMinimoEntrega,
        tempoMedioPreparo,
        raioEntregaKm,
        ativa,
        observacoes,
        dataCadastro,
        ultimaAtualizacao,
      ];
}