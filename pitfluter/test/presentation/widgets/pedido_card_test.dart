import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/domain/entities/pedido.dart';
import 'package:pitfluter/presentation/widgets/pedido_card.dart';

void main() {
  group('PedidoCard Widget Tests', () {
    late Pedido mockPedido;

    setUp(() {
      mockPedido = const Pedido(
        id: 1,
        numero: 'PED001',
        clienteId: 1,
        subtotal: 25.90,
        taxaEntrega: 5.00,
        desconto: 0.00,
        total: 30.90,
        formaPagamento: 'Dinheiro',
        status: PedidoStatus.recebido,
        tipo: TipoPedido.entrega,
        dataHoraCriacao: DateTime.parse('2024-01-01T10:00:00Z'),
        tempoEstimadoMinutos: 30,
      );
    });

    testWidgets('should display pedido information correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PedidoCard(pedido: mockPedido),
          ),
        ),
      );

      expect(find.text('PED001'), findsOneWidget);
      expect(find.text('R\$ 30,90'), findsOneWidget);
      expect(find.text('30 min'), findsOneWidget);
    });

    testWidgets('should display correct color for recebido status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PedidoCard(pedido: mockPedido),
          ),
        ),
      );

      final cardWidget = tester.widget<Card>(find.byType(Card));
      expect(cardWidget.color, equals(Colors.blue.shade50));
    });

    testWidgets('should display correct color for preparando status', (tester) async {
      final pedidoPreparando = mockPedido.copyWith(status: PedidoStatus.preparando);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PedidoCard(pedido: pedidoPreparando),
          ),
        ),
      );

      final cardWidget = tester.widget<Card>(find.byType(Card));
      expect(cardWidget.color, equals(Colors.orange.shade50));
    });

    testWidgets('should display correct color for saindo status', (tester) async {
      final pedidoSaindo = mockPedido.copyWith(status: PedidoStatus.saindo);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PedidoCard(pedido: pedidoSaindo),
          ),
        ),
      );

      final cardWidget = tester.widget<Card>(find.byType(Card));
      expect(cardWidget.color, equals(Colors.purple.shade50));
    });

    testWidgets('should display correct color for entregue status', (tester) async {
      final pedidoEntregue = mockPedido.copyWith(status: PedidoStatus.entregue);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PedidoCard(pedido: pedidoEntregue),
          ),
        ),
      );

      final cardWidget = tester.widget<Card>(find.byType(Card));
      expect(cardWidget.color, equals(Colors.green.shade50));
    });

    testWidgets('should display correct color for cancelado status', (tester) async {
      final pedidoCancelado = mockPedido.copyWith(status: PedidoStatus.cancelado);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PedidoCard(pedido: pedidoCancelado),
          ),
        ),
      );

      final cardWidget = tester.widget<Card>(find.byType(Card));
      expect(cardWidget.color, equals(Colors.red.shade50));
    });

    testWidgets('should display status badge with correct text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PedidoCard(pedido: mockPedido),
          ),
        ),
      );

      expect(find.text('RECEBIDO'), findsOneWidget);
    });

    testWidgets('should display delivery type icon for entrega', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PedidoCard(pedido: mockPedido),
          ),
        ),
      );

      expect(find.byIcon(Icons.delivery_dining), findsOneWidget);
    });

    testWidgets('should display takeout icon for balcao', (tester) async {
      final pedidoBalcao = mockPedido.copyWith(tipo: TipoPedido.balcao);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PedidoCard(pedido: pedidoBalcao),
          ),
        ),
      );

      expect(find.byIcon(Icons.store), findsOneWidget);
    });

    testWidgets('should be accessible with proper semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PedidoCard(pedido: mockPedido),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Pedido PED001, status recebido, total R\$ 30,90'),
        findsOneWidget,
      );
    });

    testWidgets('should handle tap interaction', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PedidoCard(
              pedido: mockPedido,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PedidoCard));
      expect(tapped, isTrue);
    });
  });
}