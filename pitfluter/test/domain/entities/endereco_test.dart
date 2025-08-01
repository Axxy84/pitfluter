import 'package:flutter_test/flutter_test.dart';
import 'package:pitfluter/domain/entities/endereco.dart';

void main() {
  group('Endereco', () {
    test('deve criar uma instância válida de Endereco', () {
      final endereco = Endereco(
        id: 1,
        clienteId: 1,
        apelido: 'Casa',
        logradouro: 'Rua das Flores, 123',
        bairro: 'Centro',
        cidade: 'São Paulo',
        estado: 'SP',
        cep: '01234567',
        complemento: 'Apto 101',
        referencia: 'Próximo ao mercado',
        taxaEntrega: 5.50,
        tempoEntregaMinutos: 30,
        ativo: true,
        padrao: false,
      );

      expect(endereco.id, 1);
      expect(endereco.clienteId, 1);
      expect(endereco.apelido, 'Casa');
      expect(endereco.logradouro, 'Rua das Flores, 123');
      expect(endereco.bairro, 'Centro');
      expect(endereco.cidade, 'São Paulo');
      expect(endereco.estado, 'SP');
      expect(endereco.cep, '01234567');
      expect(endereco.complemento, 'Apto 101');
      expect(endereco.referencia, 'Próximo ao mercado');
      expect(endereco.taxaEntrega, 5.50);
      expect(endereco.tempoEntregaMinutos, 30);
      expect(endereco.ativo, true);
      expect(endereco.padrao, false);
    });

    test('deve aceitar valores nulos para campos opcionais', () {
      final endereco = Endereco(
        id: 1,
        clienteId: 1,
        apelido: 'Trabalho',
        logradouro: 'Av. Paulista, 1000',
        bairro: 'Bela Vista',
        cidade: 'São Paulo',
        estado: 'SP',
        cep: '01310100',
        complemento: null,
        referencia: null,
        taxaEntrega: 8.00,
        tempoEntregaMinutos: 45,
        ativo: true,
        padrao: true,
      );

      expect(endereco.complemento, isNull);
      expect(endereco.referencia, isNull);
    });

    test('deve implementar Equatable corretamente', () {
      final endereco1 = Endereco(
        id: 1,
        clienteId: 1,
        apelido: 'Casa',
        logradouro: 'Rua das Flores, 123',
        bairro: 'Centro',
        cidade: 'São Paulo',
        estado: 'SP',
        cep: '01234567',
        complemento: 'Apto 101',
        referencia: 'Próximo ao mercado',
        taxaEntrega: 5.50,
        tempoEntregaMinutos: 30,
        ativo: true,
        padrao: false,
      );

      final endereco2 = Endereco(
        id: 1,
        clienteId: 1,
        apelido: 'Casa',
        logradouro: 'Rua das Flores, 123',
        bairro: 'Centro',
        cidade: 'São Paulo',
        estado: 'SP',
        cep: '01234567',
        complemento: 'Apto 101',
        referencia: 'Próximo ao mercado',
        taxaEntrega: 5.50,
        tempoEntregaMinutos: 30,
        ativo: true,
        padrao: false,
      );

      expect(endereco1, equals(endereco2));
    });

    test('deve ter copyWith funcionando corretamente', () {
      final endereco = Endereco(
        id: 1,
        clienteId: 1,
        apelido: 'Casa',
        logradouro: 'Rua das Flores, 123',
        bairro: 'Centro',
        cidade: 'São Paulo',
        estado: 'SP',
        cep: '01234567',
        complemento: 'Apto 101',
        referencia: 'Próximo ao mercado',
        taxaEntrega: 5.50,
        tempoEntregaMinutos: 30,
        ativo: true,
        padrao: false,
      );

      final enderecoAtualizado = endereco.copyWith(
        apelido: 'Casa Nova',
        taxaEntrega: 6.00,
        padrao: true,
      );

      expect(enderecoAtualizado.apelido, 'Casa Nova');
      expect(enderecoAtualizado.taxaEntrega, 6.00);
      expect(enderecoAtualizado.padrao, true);
      expect(enderecoAtualizado.id, endereco.id);
      expect(enderecoAtualizado.logradouro, endereco.logradouro);
    });

    test('deve calcular endereço completo corretamente', () {
      final endereco = Endereco(
        id: 1,
        clienteId: 1,
        apelido: 'Casa',
        logradouro: 'Rua das Flores, 123',
        bairro: 'Centro',
        cidade: 'São Paulo',
        estado: 'SP',
        cep: '01234567',
        complemento: 'Apto 101',
        referencia: null,
        taxaEntrega: 5.50,
        tempoEntregaMinutos: 30,
        ativo: true,
        padrao: false,
      );

      final enderecoCompleto = endereco.enderecoCompleto;
      expect(enderecoCompleto, 'Rua das Flores, 123, Apto 101 - Centro, São Paulo - SP, 01234-567');
    });

    test('deve calcular endereço completo sem complemento', () {
      final endereco = Endereco(
        id: 1,
        clienteId: 1,
        apelido: 'Casa',
        logradouro: 'Rua das Flores, 123',
        bairro: 'Centro',
        cidade: 'São Paulo',
        estado: 'SP',
        cep: '01234567',
        complemento: null,
        referencia: null,
        taxaEntrega: 5.50,
        tempoEntregaMinutos: 30,
        ativo: true,
        padrao: false,
      );

      final enderecoCompleto = endereco.enderecoCompleto;
      expect(enderecoCompleto, 'Rua das Flores, 123 - Centro, São Paulo - SP, 01234-567');
    });
  });
}