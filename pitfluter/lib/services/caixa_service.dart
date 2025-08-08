import 'package:supabase_flutter/supabase_flutter.dart';

class EstadoCaixa {
  final bool aberto;
  final String? dataAbertura;
  final double? saldoInicial;
  final int? id;

  EstadoCaixa({
    required this.aberto,
    this.dataAbertura,
    this.saldoInicial,
    this.id,
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
      print('🔍 [CaixaService] Verificando estado do caixa...');
      
      final response = await _supabase
          .from('caixa')
          .select()
          .order('data_abertura', ascending: false)
          .limit(1);
      
      print('📊 [CaixaService] Resposta do banco: ${response.length} registros');
      
      if (response.isEmpty) {
        print('   ⚠️ Nenhum caixa encontrado no banco');
        return EstadoCaixa(aberto: false);
      }
      
      final ultimoCaixa = response.first;
      final bool aberto = ultimoCaixa['data_fechamento'] == null;
      
      print('   📦 Último caixa:');
      print('      ID: ${ultimoCaixa['id']}');
      print('      Data abertura: ${ultimoCaixa['data_abertura']}');
      print('      Data fechamento: ${ultimoCaixa['data_fechamento']}');
      print('      Está aberto: $aberto');
      
      return EstadoCaixa(
        aberto: aberto,
        dataAbertura: ultimoCaixa['data_abertura'],
        saldoInicial: ultimoCaixa['saldo_inicial']?.toDouble(),
        id: ultimoCaixa['id'],
      );
      
    } catch (e) {
      print('❌ [CaixaService] Erro: $e');
      throw Exception('Erro ao verificar estado do caixa: $e');
    }
  }

  Future<void> abrirCaixa(double saldoInicial, String observacoes) async {
    final estado = await verificarEstadoCaixa();
    if (estado.aberto) {
      throw Exception('Já existe um caixa aberto');
    }
    
    await _supabase.from('caixa').insert({
      'data_abertura': DateTime.now().toIso8601String(),
      'saldo_inicial': saldoInicial,
      'observacoes': observacoes,
      'usuario_id': 1, // TODO: Integrar com auth quando disponível
    });
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
          'data_fechamento': DateTime.now().toIso8601String(),
          'saldo_final': resumo.saldoFinal,
          'total_vendas': resumo.totalVendas,
          'total_dinheiro': resumo.totalDinheiro,
          'total_cartao': resumo.totalCartao,
          'total_pix': resumo.totalPix,
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
      print('🔍 Buscando pedidos a partir de: ${estado.dataAbertura}');
      
      // Buscar vendas do período do caixa aberto
      final pedidos = await _supabase
          .from('pedidos')
          .select()
          .gte('created_at', estado.dataAbertura!);
      
      print('📊 Total de pedidos encontrados: ${pedidos.length}');
      
      for (final pedido in pedidos) {
        print('   Pedido #${pedido['numero']}: R\$ ${pedido['total']} - ${pedido['forma_pagamento']}');
        
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
      print('💰 Total de vendas: R\$ $totalVendas');
    } catch (e) {
      print('❌ Erro ao buscar pedidos: $e');
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