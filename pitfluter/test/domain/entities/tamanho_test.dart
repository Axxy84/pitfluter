import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/domain/entities/tamanho.dart';

void main() {
  group('Tamanho Entity', () {
    test('should create Tamanho with required properties', () {
      // arrange
      const tamanho = Tamanho(
        id: 1,
        nome: 'Grande',
        descricao: 'Pizza grande 35cm',
        fatorMultiplicador: 1.5,
        ativo: true,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(tamanho.id, 1);
      expect(tamanho.nome, 'Grande');
      expect(tamanho.descricao, 'Pizza grande 35cm');
      expect(tamanho.fatorMultiplicador, 1.5);
      expect(tamanho.ativo, true);
      expect(tamanho.ordem, 1);
      expect(tamanho.dataCadastro, '2024-01-01T10:00:00Z');
      expect(tamanho.ultimaAtualizacao, '2024-01-01T10:00:00Z');
    });

    test('should create Tamanho with optional fields null', () {
      // arrange
      const tamanho = Tamanho(
        id: 1,
        nome: 'Médio',
        fatorMultiplicador: 1.0,
        ativo: true,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(tamanho.descricao, null);
    });

    test('should calculate price based on multiplicator factor', () {
      // arrange
      const tamanho = Tamanho(
        id: 1,
        nome: 'Grande',
        fatorMultiplicador: 1.5,
        ativo: true,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );
      const precoBase = 20.0;

      // act
      final precoCalculado = tamanho.calcularPreco(precoBase);

      // assert
      expect(precoCalculado, 30.0);
    });

    test('should support copyWith method', () {
      // arrange
      const tamanho = Tamanho(
        id: 1,
        nome: 'Pequeno',
        fatorMultiplicador: 0.8,
        ativo: true,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // act
      final tamanhoAtualizado = tamanho.copyWith(
        nome: 'Pequeno Premium',
        fatorMultiplicador: 0.9,
        ativo: false,
      );

      // assert
      expect(tamanhoAtualizado.id, 1);
      expect(tamanhoAtualizado.nome, 'Pequeno Premium');
      expect(tamanhoAtualizado.fatorMultiplicador, 0.9);
      expect(tamanhoAtualizado.ativo, false);
      expect(tamanhoAtualizado.ordem, 1);
    });

    test('should support equality comparison', () {
      // arrange
      const tamanho1 = Tamanho(
        id: 1,
        nome: 'Médio',
        fatorMultiplicador: 1.0,
        ativo: true,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const tamanho2 = Tamanho(
        id: 1,
        nome: 'Médio',
        fatorMultiplicador: 1.0,
        ativo: true,
        ordem: 1,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const tamanho3 = Tamanho(
        id: 2,
        nome: 'Grande',
        fatorMultiplicador: 1.5,
        ativo: true,
        ordem: 2,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(tamanho1, tamanho2);
      expect(tamanho1, isNot(tamanho3));
    });
  });
}