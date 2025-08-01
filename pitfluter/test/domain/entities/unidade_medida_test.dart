import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/domain/entities/unidade_medida.dart';

void main() {
  group('UnidadeMedida Entity', () {
    test('should create UnidadeMedida with required properties', () {
      const unidade = UnidadeMedida(
        id: 1,
        nome: 'Quilograma',
        sigla: 'kg',
        ativa: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      expect(unidade.id, 1);
      expect(unidade.nome, 'Quilograma');
      expect(unidade.sigla, 'kg');
      expect(unidade.ativa, true);
    });

    test('should support equality comparison', () {
      const unidade1 = UnidadeMedida(
        id: 1,
        nome: 'Quilograma',
        sigla: 'kg',
        ativa: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const unidade2 = UnidadeMedida(
        id: 1,
        nome: 'Quilograma',
        sigla: 'kg',
        ativa: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      expect(unidade1, unidade2);
    });
  });
}