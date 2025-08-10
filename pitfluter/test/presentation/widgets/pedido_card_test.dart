import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/domain/entities/pedido.dart';
import 'package:pitfluter/presentation/widgets/pedido_card.dart';

void main() {
  group('PedidoCard Widget Tests', () {
    late Pedido mockPedido;

    setUp(() {
      mockPedido = Pedido(
        id: 1,
        numero: 'PED001',
        subtotal: 25.90,
        taxaEntrega: 5.00,
        desconto: 0.00,
        total: 30.90,
        formaPagamento: 'Dinheiro',
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
        find.bySemanticsLabel('Pedido PED001, total R\$ 30,90'),
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