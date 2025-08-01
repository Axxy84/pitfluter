import 'package:equatable/equatable.dart';

class ItemPedido extends Equatable {
  final int id;
  final int pedidoId;
  final int produtoId;
  final int tamanhoId;
  final int quantidade;
  final double valorUnitario;
  final double valorTotal;
  final String? observacoes;
  final bool meioAMeio;
  final int? produtoMeioId;
  final int? tamanhoMeioId;

  const ItemPedido({
    required this.id,
    required this.pedidoId,
    required this.produtoId,
    required this.tamanhoId,
    required this.quantidade,
    required this.valorUnitario,
    required this.valorTotal,
    this.observacoes,
    required this.meioAMeio,
    this.produtoMeioId,
    this.tamanhoMeioId,
  });

  double calcularValorTotal() {
    return valorUnitario * quantidade;
  }

  bool get ehMeioAMeioValido {
    if (!meioAMeio) {
      return true; // Item normal é sempre válido
    }
    
    // Para meio a meio, deve ter produto e tamanho meio
    return produtoMeioId != null && tamanhoMeioId != null;
  }

  ItemPedido copyWith({
    int? id,
    int? pedidoId,
    int? produtoId,
    int? tamanhoId,
    int? quantidade,
    double? valorUnitario,
    double? valorTotal,
    String? observacoes,
    bool? meioAMeio,
    int? produtoMeioId,
    int? tamanhoMeioId,
  }) {
    return ItemPedido(
      id: id ?? this.id,
      pedidoId: pedidoId ?? this.pedidoId,
      produtoId: produtoId ?? this.produtoId,
      tamanhoId: tamanhoId ?? this.tamanhoId,
      quantidade: quantidade ?? this.quantidade,
      valorUnitario: valorUnitario ?? this.valorUnitario,
      valorTotal: valorTotal ?? this.valorTotal,
      observacoes: observacoes ?? this.observacoes,
      meioAMeio: meioAMeio ?? this.meioAMeio,
      produtoMeioId: produtoMeioId ?? this.produtoMeioId,
      tamanhoMeioId: tamanhoMeioId ?? this.tamanhoMeioId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        pedidoId,
        produtoId,
        tamanhoId,
        quantidade,
        valorUnitario,
        valorTotal,
        observacoes,
        meioAMeio,
        produtoMeioId,
        tamanhoMeioId,
      ];
}