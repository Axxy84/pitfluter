import 'package:equatable/equatable.dart';

enum StatusCaixa {
  aberto,
  fechado,
}

class Caixa extends Equatable {
  final int id;
  final DateTime dataAbertura;
  final DateTime? dataFechamento;
  final double saldoInicial;
  final double saldoFinal;
  final double totalVendas;
  final double totalDinheiro;
  final double totalCartao;
  final double totalPix;
  final double totalSangrias;
  final StatusCaixa status;
  final String? observacoes;
  final String dataCadastro;
  final String ultimaAtualizacao;

  const Caixa({
    required this.id,
    required this.dataAbertura,
    this.dataFechamento,
    required this.saldoInicial,
    required this.saldoFinal,
    required this.totalVendas,
    required this.totalDinheiro,
    required this.totalCartao,
    required this.totalPix,
    required this.totalSangrias,
    required this.status,
    this.observacoes,
    required this.dataCadastro,
    required this.ultimaAtualizacao,
  });

  bool get estaAberto => status == StatusCaixa.aberto;
  double get saldoAtual => saldoInicial + totalVendas - totalSangrias;
  double get diferencaCaixa => saldoFinal - saldoAtual;

  Caixa copyWith({
    int? id,
    DateTime? dataAbertura,
    DateTime? dataFechamento,
    double? saldoInicial,
    double? saldoFinal,
    double? totalVendas,
    double? totalDinheiro,
    double? totalCartao,
    double? totalPix,
    double? totalSangrias,
    StatusCaixa? status,
    String? observacoes,
    String? dataCadastro,
    String? ultimaAtualizacao,
  }) {
    return Caixa(
      id: id ?? this.id,
      dataAbertura: dataAbertura ?? this.dataAbertura,
      dataFechamento: dataFechamento ?? this.dataFechamento,
      saldoInicial: saldoInicial ?? this.saldoInicial,
      saldoFinal: saldoFinal ?? this.saldoFinal,
      totalVendas: totalVendas ?? this.totalVendas,
      totalDinheiro: totalDinheiro ?? this.totalDinheiro,
      totalCartao: totalCartao ?? this.totalCartao,
      totalPix: totalPix ?? this.totalPix,
      totalSangrias: totalSangrias ?? this.totalSangrias,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
    );
  }

  @override
  List<Object?> get props => [
        id,
        dataAbertura,
        dataFechamento,
        saldoInicial,
        saldoFinal,
        totalVendas,
        totalDinheiro,
        totalCartao,
        totalPix,
        totalSangrias,
        status,
        observacoes,
        dataCadastro,
        ultimaAtualizacao,
      ];
}