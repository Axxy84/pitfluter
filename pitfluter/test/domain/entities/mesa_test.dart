import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/domain/entities/mesa.dart';

void main() {
  group('Mesa Entity', () {
    test('should create Mesa with required properties', () {
      // arrange
      const mesa = Mesa(
        id: 1,
        numero: 5,
        descricao: 'Mesa próxima à janela',
        capacidade: 4,
        ativa: true,
        ocupada: false,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(mesa.id, 1);
      expect(mesa.numero, 5);
      expect(mesa.descricao, 'Mesa próxima à janela');
      expect(mesa.capacidade, 4);
      expect(mesa.ativa, true);
      expect(mesa.ocupada, false);
      expect(mesa.dataCadastro, '2024-01-01T10:00:00Z');
      expect(mesa.ultimaAtualizacao, '2024-01-01T10:00:00Z');
    });

    test('should create Mesa with optional fields null', () {
      // arrange
      const mesa = Mesa(
        id: 1,
        numero: 5,
        capacidade: 4,
        ativa: true,
        ocupada: false,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(mesa.descricao, null);
      expect(mesa.observacoes, null);
    });

    test('should check if mesa is available', () {
      // arrange
      const mesaDisponivel = Mesa(
        id: 1,
        numero: 5,
        capacidade: 4,
        ativa: true,
        ocupada: false,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const mesaOcupada = Mesa(
        id: 2,
        numero: 6,
        capacidade: 4,
        ativa: true,
        ocupada: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const mesaInativa = Mesa(
        id: 3,
        numero: 7,
        capacidade: 4,
        ativa: false,
        ocupada: false,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(mesaDisponivel.estaDisponivel, true);
      expect(mesaOcupada.estaDisponivel, false);
      expect(mesaInativa.estaDisponivel, false);
    });

    test('should get mesa status', () {
      // arrange
      const mesaLivre = Mesa(
        id: 1,
        numero: 5,
        capacidade: 4,
        ativa: true,
        ocupada: false,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const mesaOcupada = Mesa(
        id: 2,
        numero: 6,
        capacidade: 4,
        ativa: true,
        ocupada: true,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const mesaInativa = Mesa(
        id: 3,
        numero: 7,
        capacidade: 4,
        ativa: false,
        ocupada: false,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(mesaLivre.status, MesaStatus.livre);
      expect(mesaOcupada.status, MesaStatus.ocupada);
      expect(mesaInativa.status, MesaStatus.inativa);
    });

    test('should support copyWith method', () {
      // arrange
      const mesa = Mesa(
        id: 1,
        numero: 5,
        capacidade: 4,
        ativa: true,
        ocupada: false,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // act
      final mesaAtualizada = mesa.copyWith(
        descricao: 'Mesa VIP',
        ocupada: true,
        observacoes: 'Cliente especial',
      );

      // assert
      expect(mesaAtualizada.id, 1);
      expect(mesaAtualizada.numero, 5);
      expect(mesaAtualizada.capacidade, 4);
      expect(mesaAtualizada.descricao, 'Mesa VIP');
      expect(mesaAtualizada.ocupada, true);
      expect(mesaAtualizada.observacoes, 'Cliente especial');
    });

    test('should support equality comparison', () {
      // arrange
      const mesa1 = Mesa(
        id: 1,
        numero: 5,
        capacidade: 4,
        ativa: true,
        ocupada: false,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const mesa2 = Mesa(
        id: 1,
        numero: 5,
        capacidade: 4,
        ativa: true,
        ocupada: false,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      const mesa3 = Mesa(
        id: 2,
        numero: 6,
        capacidade: 6,
        ativa: true,
        ocupada: false,
        dataCadastro: '2024-01-01T10:00:00Z',
        ultimaAtualizacao: '2024-01-01T10:00:00Z',
      );

      // assert
      expect(mesa1, mesa2);
      expect(mesa1, isNot(mesa3));
    });
  });
}