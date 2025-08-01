import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/domain/entities/cliente.dart';

void main() {
  group('Cliente', () {
    test('deve criar uma instância válida de Cliente', () {
      final cliente = Cliente(
        id: 1,
        nome: 'João Silva',
        telefone: '11999999999',
        email: 'joao@example.com',
        cpfCnpj: '12345678901',
        dataNascimento: DateTime(1990, 1, 1),
        observacoes: 'Cliente VIP',
        ativo: true,
        dataCadastro: DateTime.now(),
        ultimaAtualizacao: DateTime.now(),
      );

      expect(cliente.id, 1);
      expect(cliente.nome, 'João Silva');
      expect(cliente.telefone, '11999999999');
      expect(cliente.email, 'joao@example.com');
      expect(cliente.cpfCnpj, '12345678901');
      expect(cliente.dataNascimento, DateTime(1990, 1, 1));
      expect(cliente.observacoes, 'Cliente VIP');
      expect(cliente.ativo, true);
      expect(cliente.dataCadastro, isA<DateTime>());
      expect(cliente.ultimaAtualizacao, isA<DateTime>());
    });

    test('deve aceitar valores nulos para campos opcionais', () {
      final cliente = Cliente(
        id: 1,
        nome: 'Maria Santos',
        telefone: '11888888888',
        email: null,
        cpfCnpj: null,
        dataNascimento: null,
        observacoes: null,
        ativo: true,
        dataCadastro: DateTime.now(),
        ultimaAtualizacao: DateTime.now(),
      );

      expect(cliente.email, isNull);
      expect(cliente.cpfCnpj, isNull);
      expect(cliente.dataNascimento, isNull);
      expect(cliente.observacoes, isNull);
    });

    test('deve implementar Equatable corretamente', () {
      final dataAgora = DateTime.now();
      final cliente1 = Cliente(
        id: 1,
        nome: 'João Silva',
        telefone: '11999999999',
        email: 'joao@example.com',
        cpfCnpj: '12345678901',
        dataNascimento: DateTime(1990, 1, 1),
        observacoes: 'Cliente VIP',
        ativo: true,
        dataCadastro: dataAgora,
        ultimaAtualizacao: dataAgora,
      );

      final cliente2 = Cliente(
        id: 1,
        nome: 'João Silva',
        telefone: '11999999999',
        email: 'joao@example.com',
        cpfCnpj: '12345678901',
        dataNascimento: DateTime(1990, 1, 1),
        observacoes: 'Cliente VIP',
        ativo: true,
        dataCadastro: dataAgora,
        ultimaAtualizacao: dataAgora,
      );

      expect(cliente1, equals(cliente2));
    });

    test('deve ter copyWith funcionando corretamente', () {
      final cliente = Cliente(
        id: 1,
        nome: 'João Silva',
        telefone: '11999999999',
        email: 'joao@example.com',
        cpfCnpj: '12345678901',
        dataNascimento: DateTime(1990, 1, 1),
        observacoes: 'Cliente VIP',
        ativo: true,
        dataCadastro: DateTime.now(),
        ultimaAtualizacao: DateTime.now(),
      );

      final clienteAtualizado = cliente.copyWith(
        nome: 'João Silva Santos',
        email: 'joao.santos@example.com',
      );

      expect(clienteAtualizado.nome, 'João Silva Santos');
      expect(clienteAtualizado.email, 'joao.santos@example.com');
      expect(clienteAtualizado.id, cliente.id);
      expect(clienteAtualizado.telefone, cliente.telefone);
    });
  });
}