import 'package:supabase_flutter/supabase_flutter.dart';

class EstadoCaixa {
  final bool aberto;
  final String? dataAbertura;
  final double? saldoInicial;
  final int? id;
  final String? nomeOperador;

  EstadoCaixa({
    required this.aberto,
    this.dataAbertura,
    this.saldoInicial,
    this.id,
    this.nomeOperador,
  });
}

class ResumoCaixa {
  final double saldoFinal;
  final double totalVendas;
  final double totalDinheiro;
  final double totalCartao;
  final double totalPix;
  final int quantidadeVendas;

  ResumoCaixa({
    required this.saldoFinal,
    required this.totalVendas,
    required this.totalDinheiro,
    required this.totalCartao,
    required this.totalPix,
    required this.quantidadeVendas,
  });
}

class CaixaService {
  final _supabase = Supabase.instance.client;

  Future<EstadoCaixa> verificarEstadoCaixa() async {
    try {
      // DEBUG: Fazendo consulta na tabela caixa
      
      final response = await _supabase
          .from('caixa')
          .select()
          .order('data_abertura', ascending: false)
          .limit(1);
      
      // DEBUG: Consulta executada. Registros encontrados: ${response.length}
      
      if (response.isEmpty) {
        // DEBUG: Nenhum caixa encontrado, retornando aberto: false
        return EstadoCaixa(aberto: false);
      }
      
      final ultimoCaixa = response.first;
      final bool aberto = ultimoCaixa['hora_fechamento'] == null;
      
      // DEBUG: Último caixa - ID: ${ultimoCaixa['id']}, Data fechamento: ${ultimoCaixa['hora_fechamento']}, Aberto: $aberto
      
      final estado = EstadoCaixa(
        aberto: aberto,
        dataAbertura: ultimoCaixa['data_abertura'],
        saldoInicial: ultimoCaixa['valor_inicial']?.toDouble(),
        id: ultimoCaixa['id'],
        nomeOperador: ultimoCaixa['operador_nome'],
      );
      
      // DEBUG: Estado retornado: Aberto: ${estado.aberto}, ID: ${estado.id}
      return estado;
      
    } catch (e) {
      // DEBUG: ERRO ao verificar estado do caixa: $e
      throw Exception('Erro ao verificar estado do caixa: $e');
    }
  }

  Future<void> abrirCaixa(double saldoInicial, String observacoes, [String? nomeUsuario]) async {
    final estado = await verificarEstadoCaixa();
    if (estado.aberto) {
      throw Exception('Já existe um caixa aberto');
    }
    
    // Se foi fornecido um nome, criar/buscar operador
    int operadorId = 1; // Default
    if (nomeUsuario != null && nomeUsuario.isNotEmpty) {
      try {
        // Primeiro tenta buscar o operador pelo nome
        final operadores = await _supabase
            .from('operadores')
            .select('id')
            .eq('nome', nomeUsuario)
            .limit(1);
        
        if (operadores.isNotEmpty) {
          operadorId = operadores.first['id'];
        } else {
          // Se não existe, cria um novo operador
          final novoOperador = await _supabase
              .from('operadores')
              .insert({'nome': nomeUsuario, 'ativo': true})
              .select('id')
              .single();
          operadorId = novoOperador['id'];
        }
      } catch (e) {
        // Se houver erro, usa o operador padrão
        operadorId = 1;
      }
    }
    
    final dadosCaixa = {
      'data_abertura': DateTime.now().toIso8601String(),
      'valor_inicial': saldoInicial,
      'observacoes': observacoes,
      'operador_id': operadorId,
    };
    
    // Adiciona nome_operador se foi fornecido
    if (nomeUsuario != null && nomeUsuario.isNotEmpty) {
      dadosCaixa['operador_nome'] = nomeUsuario;
    }
    
    await _supabase.from('caixa').insert(dadosCaixa);
  }

  Future<void> fecharCaixa() async {
    final estado = await verificarEstadoCaixa();
    if (!estado.aberto) {
      throw Exception('Não há caixa aberto');
    }
    
    if (estado.id == null) {
      throw Exception('ID do caixa não encontrado');
    }
    
    final resumo = await calcularResumoCaixa();
    
    final result = await _supabase
        .from('caixa')
        .update({
          'hora_fechamento': DateTime.now().toIso8601String(),
          'valor_final': resumo.saldoFinal,
          'valor_vendas': resumo.totalVendas,
          'valor_dinheiro': resumo.totalDinheiro,
          'valor_cartao': resumo.totalCartao,
          'valor_pix': resumo.totalPix,
        })
        .eq('id', estado.id!)
        .select();
        
    if (result.isEmpty) {
      throw Exception('Falha ao atualizar o caixa - nenhum registro foi alterado');
    }
  }

  Future<ResumoCaixa> calcularResumoCaixa() async {
    final estado = await verificarEstadoCaixa();
    
    if (!estado.aberto || estado.id == null) {
      throw Exception('Não há caixa aberto');
    }
    
    double totalVendas = 0;
    double totalDinheiro = 0;
    double totalCartao = 0;
    double totalPix = 0;
    int quantidadeVendas = 0;
    
    try {
      // Buscar vendas do período do caixa aberto
      final pedidos = await _supabase
          .from('pedidos')
          .select()
          .gte('created_at', estado.dataAbertura!);
      
      for (final pedido in pedidos) {
        final total = (pedido['total'] ?? 0).toDouble();
        totalVendas += total;
        
        switch (pedido['forma_pagamento']) {
          case 'Dinheiro':
            totalDinheiro += total;
            break;
          case 'Cartão':
            totalCartao += total;
            break;
          case 'PIX':
            totalPix += total;
            break;
        }
      }
      
      quantidadeVendas = pedidos.length;
    } catch (e) {
      // Se não conseguir buscar pedidos (tabela não existe, etc.), continua com valores zerados
      // Não foi possível buscar pedidos (tabela pode não existir), continua com valores zerados
    }
    
    final saldoInicial = estado.saldoInicial ?? 0;
    
    return ResumoCaixa(
      saldoFinal: saldoInicial + totalVendas,
      totalVendas: totalVendas,
      totalDinheiro: totalDinheiro,
      totalCartao: totalCartao,
      totalPix: totalPix,
      quantidadeVendas: quantidadeVendas,
    );
  }

  Future<Map<String, dynamic>> obterDadosCaixaAtual() async {
    final estado = await verificarEstadoCaixa();
    
    if (!estado.aberto) {
      throw Exception('Não há caixa aberto');
    }
    
    final resumo = await calcularResumoCaixa();
    
    return {
      'estado': estado,
      'resumo': resumo,
    };
  }
}