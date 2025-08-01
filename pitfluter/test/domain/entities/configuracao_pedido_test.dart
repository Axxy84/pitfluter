import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/domain/entities/configuracao_pedido.dart';

void main() {
  group('ConfiguracaoPedido Entity', () {
    test('should create ConfiguracaoPedido with required properties', () {
      const config = ConfiguracaoPedido(
        id: 1,
        taxaEntregaMinima: 5.0,
        valorMinimoEntrega: 25.0,
        tempoMedioPreparo: 30,
        raioEntregaKm: 10.0,
        ativa: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      expect(config.id, 1);
      expect(config.taxaEntregaMinima, 5.0);
      expect(config.valorMinimoEntrega, 25.0);
      expect(config.tempoMedioPreparo, 30);
      expect(config.raioEntregaKm, 10.0);
      expect(config.ativa, true);
    });

    test('should validate delivery parameters', () {
      const config = ConfiguracaoPedido(
        id: 1,
        taxaEntregaMinima: 5.0,
        valorMinimoEntrega: 25.0,
        tempoMedioPreparo: 30,
        raioEntregaKm: 10.0,
        ativa: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      expect(config.podeEntregar(30.0, 8.0), true);
      expect(config.podeEntregar(20.0, 8.0), false);
      expect(config.podeEntregar(30.0, 15.0), false);
    });
  });
}