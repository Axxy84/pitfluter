import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/domain/entities/item_pedido.dart';

void main() {
  group('ItemPedido', () {
    test('deve criar uma instância válida de ItemPedido', () {
      final item = ItemPedido(
        id: 1,
        pedidoId: 1,
        produtoId: 1,
        tamanhoId: 1,
        quantidade: 2,
        valorUnitario: 25.90,
        valorTotal: 51.80,
        observacoes: 'Sem cebola',
        meioAMeio: false,
        produtoMeioId: null,
        tamanhoMeioId: null,
      );

      expect(item.id, 1);
      expect(item.pedidoId, 1);
      expect(item.produtoId, 1);
      expect(item.tamanhoId, 1);
      expect(item.quantidade, 2);
      expect(item.valorUnitario, 25.90);
      expect(item.valorTotal, 51.80);
      expect(item.observacoes, 'Sem cebola');
      expect(item.meioAMeio, false);
      expect(item.produtoMeioId, isNull);
      expect(item.tamanhoMeioId, isNull);
    });

    test('deve criar item meio a meio', () {
      final item = ItemPedido(
        id: 2,
        pedidoId: 1,
        produtoId: 1,
        tamanhoId: 2,
        quantidade: 1,
        valorUnitario: 35.90,
        valorTotal: 35.90,
        observacoes: 'Pizza meio a meio',
        meioAMeio: true,
        produtoMeioId: 2,
        tamanhoMeioId: 2,
      );

      expect(item.meioAMeio, true);
      expect(item.produtoMeioId, 2);
      expect(item.tamanhoMeioId, 2);
    });

    test('deve aceitar valores nulos para campos opcionais', () {
      final item = ItemPedido(
        id: 3,
        pedidoId: 1,
        produtoId: 3,
        tamanhoId: 1,
        quantidade: 1,
        valorUnitario: 15.50,
        valorTotal: 15.50,
        observacoes: null,
        meioAMeio: false,
        produtoMeioId: null,
        tamanhoMeioId: null,
      );

      expect(item.observacoes, isNull);
      expect(item.produtoMeioId, isNull);
      expect(item.tamanhoMeioId, isNull);
    });

    test('deve implementar Equatable corretamente', () {
      final item1 = ItemPedido(
        id: 1,
        pedidoId: 1,
        produtoId: 1,
        tamanhoId: 1,
        quantidade: 2,
        valorUnitario: 25.90,
        valorTotal: 51.80,
        observacoes: 'Sem cebola',
        meioAMeio: false,
        produtoMeioId: null,
        tamanhoMeioId: null,
      );

      final item2 = ItemPedido(
        id: 1,
        pedidoId: 1,
        produtoId: 1,
        tamanhoId: 1,
        quantidade: 2,
        valorUnitario: 25.90,
        valorTotal: 51.80,
        observacoes: 'Sem cebola',
        meioAMeio: false,
        produtoMeioId: null,
        tamanhoMeioId: null,
      );

      expect(item1, equals(item2));
    });

    test('deve ter copyWith funcionando corretamente', () {
      final item = ItemPedido(
        id: 1,
        pedidoId: 1,
        produtoId: 1,
        tamanhoId: 1,
        quantidade: 2,
        valorUnitario: 25.90,
        valorTotal: 51.80,
        observacoes: 'Sem cebola',
        meioAMeio: false,
        produtoMeioId: null,
        tamanhoMeioId: null,
      );

      final itemAtualizado = item.copyWith(
        quantidade: 3,
        valorTotal: 77.70,
        observacoes: 'Sem cebola e sem tomate',
      );

      expect(itemAtualizado.quantidade, 3);
      expect(itemAtualizado.valorTotal, 77.70);
      expect(itemAtualizado.observacoes, 'Sem cebola e sem tomate');
      expect(itemAtualizado.id, item.id);
      expect(itemAtualizado.valorUnitario, item.valorUnitario);
    });

    test('deve calcular valor total corretamente', () {
      final item = ItemPedido(
        id: 1,
        pedidoId: 1,
        produtoId: 1,
        tamanhoId: 1,
        quantidade: 3,
        valorUnitario: 18.90,
        valorTotal: 0.0, // Será calculado
        observacoes: null,
        meioAMeio: false,
        produtoMeioId: null,
        tamanhoMeioId: null,
      );

      final valorCalculado = item.calcularValorTotal();
      expect(valorCalculado, closeTo(56.70, 0.01)); // 18.90 * 3
    });

    test('deve validar se é meio a meio corretamente', () {
      final itemMeioAMeio = ItemPedido(
        id: 1,
        pedidoId: 1,
        produtoId: 1,
        tamanhoId: 1,
        quantidade: 1,
        valorUnitario: 35.90,
        valorTotal: 35.90,
        observacoes: null,
        meioAMeio: true,
        produtoMeioId: 2,
        tamanhoMeioId: 1,
      );

      final itemNormal = ItemPedido(
        id: 2,
        pedidoId: 1,
        produtoId: 1,
        tamanhoId: 1,
        quantidade: 1,
        valorUnitario: 25.90,
        valorTotal: 25.90,
        observacoes: null,
        meioAMeio: false,
        produtoMeioId: null,
        tamanhoMeioId: null,
      );

      expect(itemMeioAMeio.ehMeioAMeioValido, true);
      expect(itemNormal.ehMeioAMeioValido, true); // Normal também é válido
    });

    test('deve invalidar meio a meio sem dados necessários', () {
      final itemInvalido = ItemPedido(
        id: 1,
        pedidoId: 1,
        produtoId: 1,
        tamanhoId: 1,
        quantidade: 1,
        valorUnitario: 35.90,
        valorTotal: 35.90,
        observacoes: null,
        meioAMeio: true,
        produtoMeioId: null, // Deveria ter produto meio
        tamanhoMeioId: null, // Deveria ter tamanho meio
      );

      expect(itemInvalido.ehMeioAMeioValido, false);
    });
  });
}