import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/domain/entities/pedido.dart';

void main() {
  group('Pedido', () {
    test('deve criar uma instância válida de Pedido', () {
      final pedido = Pedido(
        id: 1,
        numero: '000001',
        clienteId: 1,
        enderecoId: 1,
        mesaId: null,
        subtotal: 25.90,
        taxaEntrega: 5.50,
        desconto: 2.00,
        total: 29.40,
        formaPagamento: 'Dinheiro',
        status: PedidoStatus.recebido,
        tipo: TipoPedido.entrega,
        observacoes: 'Sem cebola',
        dataHoraCriacao: DateTime.now(),
        dataHoraEntrega: null,
        tempoEstimadoMinutos: 45,
      );

      expect(pedido.id, 1);
      expect(pedido.numero, '000001');
      expect(pedido.clienteId, 1);
      expect(pedido.enderecoId, 1);
      expect(pedido.subtotal, 25.90);
      expect(pedido.taxaEntrega, 5.50);
      expect(pedido.desconto, 2.00);
      expect(pedido.total, 29.40);
      expect(pedido.formaPagamento, 'Dinheiro');
      expect(pedido.status, PedidoStatus.recebido);
      expect(pedido.tipo, TipoPedido.entrega);
      expect(pedido.observacoes, 'Sem cebola');
      expect(pedido.dataHoraCriacao, isA<DateTime>());
    });

    test('deve criar pedido para mesa (balcão)', () {
      final pedido = Pedido(
        id: 2,
        numero: '000002',
        clienteId: null,
        enderecoId: null,
        mesaId: 5,
        subtotal: 18.50,
        taxaEntrega: 0.0,
        desconto: 0.0,
        total: 18.50,
        formaPagamento: 'Cartão',
        status: PedidoStatus.preparando,
        tipo: TipoPedido.balcao,
        observacoes: null,
        dataHoraCriacao: DateTime.now(),
        dataHoraEntrega: null,
        tempoEstimadoMinutos: 15,
      );

      expect(pedido.mesaId, 5);
      expect(pedido.clienteId, isNull);
      expect(pedido.enderecoId, isNull);
      expect(pedido.tipo, TipoPedido.balcao);
      expect(pedido.taxaEntrega, 0.0);
    });

    test('deve implementar Equatable corretamente', () {
      final dataAgora = DateTime.now();
      final pedido1 = Pedido(
        id: 1,
        numero: '000001',
        clienteId: 1,
        enderecoId: 1,
        mesaId: null,
        subtotal: 25.90,
        taxaEntrega: 5.50,
        desconto: 2.00,
        total: 29.40,
        formaPagamento: 'Dinheiro',
        status: PedidoStatus.recebido,
        tipo: TipoPedido.entrega,
        observacoes: 'Sem cebola',
        dataHoraCriacao: dataAgora,
        dataHoraEntrega: null,
        tempoEstimadoMinutos: 45,
      );

      final pedido2 = Pedido(
        id: 1,
        numero: '000001',
        clienteId: 1,
        enderecoId: 1,
        mesaId: null,
        subtotal: 25.90,
        taxaEntrega: 5.50,
        desconto: 2.00,
        total: 29.40,
        formaPagamento: 'Dinheiro',
        status: PedidoStatus.recebido,
        tipo: TipoPedido.entrega,
        observacoes: 'Sem cebola',
        dataHoraCriacao: dataAgora,
        dataHoraEntrega: null,
        tempoEstimadoMinutos: 45,
      );

      expect(pedido1, equals(pedido2));
    });

    test('deve ter copyWith funcionando corretamente', () {
      final pedido = Pedido(
        id: 1,
        numero: '000001',
        clienteId: 1,
        enderecoId: 1,
        mesaId: null,
        subtotal: 25.90,
        taxaEntrega: 5.50,
        desconto: 2.00,
        total: 29.40,
        formaPagamento: 'Dinheiro',
        status: PedidoStatus.recebido,
        tipo: TipoPedido.entrega,
        observacoes: 'Sem cebola',
        dataHoraCriacao: DateTime.now(),
        dataHoraEntrega: null,
        tempoEstimadoMinutos: 45,
      );

      final pedidoAtualizado = pedido.copyWith(
        status: PedidoStatus.preparando,
        observacoes: 'Sem cebola e sem tomate',
      );

      expect(pedidoAtualizado.status, PedidoStatus.preparando);
      expect(pedidoAtualizado.observacoes, 'Sem cebola e sem tomate');
      expect(pedidoAtualizado.id, pedido.id);
      expect(pedidoAtualizado.numero, pedido.numero);
    });

    test('deve calcular total corretamente', () {
      final pedido = Pedido(
        id: 1,
        numero: '000001',
        clienteId: 1,
        enderecoId: 1,
        mesaId: null,
        subtotal: 25.90,
        taxaEntrega: 5.50,
        desconto: 2.00,
        total: 0.0, // Será calculado
        formaPagamento: 'Dinheiro',
        status: PedidoStatus.recebido,
        tipo: TipoPedido.entrega,
        observacoes: null,
        dataHoraCriacao: DateTime.now(),
        dataHoraEntrega: null,
        tempoEstimadoMinutos: 45,
      );

      final totalCalculado = pedido.calcularTotal();
      expect(totalCalculado, 29.40); // 25.90 + 5.50 - 2.00
    });

    test('deve verificar se pedido está em andamento', () {
      final pedidoRecebido = Pedido(
        id: 1,
        numero: '000001',
        clienteId: 1,
        enderecoId: 1,
        mesaId: null,
        subtotal: 25.90,
        taxaEntrega: 5.50,
        desconto: 0.0,
        total: 31.40,
        formaPagamento: 'Dinheiro',
        status: PedidoStatus.recebido,
        tipo: TipoPedido.entrega,
        observacoes: null,
        dataHoraCriacao: DateTime.now(),
        dataHoraEntrega: null,
        tempoEstimadoMinutos: 45,
      );

      final pedidoEntregue = pedidoRecebido.copyWith(
        status: PedidoStatus.entregue,
      );

      expect(pedidoRecebido.estaEmAndamento, true);
      expect(pedidoEntregue.estaEmAndamento, false);
    });

    test('deve verificar se pedido pode ser cancelado', () {
      final pedidoRecebido = Pedido(
        id: 1,
        numero: '000001',
        clienteId: 1,
        enderecoId: 1,
        mesaId: null,
        subtotal: 25.90,
        taxaEntrega: 5.50,
        desconto: 0.0,
        total: 31.40,
        formaPagamento: 'Dinheiro',
        status: PedidoStatus.recebido,
        tipo: TipoPedido.entrega,
        observacoes: null,
        dataHoraCriacao: DateTime.now(),
        dataHoraEntrega: null,
        tempoEstimadoMinutos: 45,
      );

      final pedidoSaindo = pedidoRecebido.copyWith(
        status: PedidoStatus.saindo,
      );

      expect(pedidoRecebido.podeCancelar, true);
      expect(pedidoSaindo.podeCancelar, false);
    });
  });

  group('PedidoStatus', () {
    test('deve ter todas as opções de status', () {
      expect(PedidoStatus.values.length, 5);
      expect(PedidoStatus.values, contains(PedidoStatus.recebido));
      expect(PedidoStatus.values, contains(PedidoStatus.preparando));
      expect(PedidoStatus.values, contains(PedidoStatus.saindo));
      expect(PedidoStatus.values, contains(PedidoStatus.entregue));
      expect(PedidoStatus.values, contains(PedidoStatus.cancelado));
    });
  });

  group('TipoPedido', () {
    test('deve ter todas as opções de tipo', () {
      expect(TipoPedido.values.length, 2);
      expect(TipoPedido.values, contains(TipoPedido.entrega));
      expect(TipoPedido.values, contains(TipoPedido.balcao));
    });
  });
}