import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://hkqbqzxlzxxgdeqmqhpy.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhrcWJxenhsenhYZ2RlcW1xaHB5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA3Mjk3MTMsImV4cCI6MjA0NjMwNTcxM30.8GlVJzZz-JiRXJxH3YQK2K62zpxgMdcHsYlP17kkhmU',
  );

  try {
    print('🔍 Verificando pedidos e caixa...\n');
    
    // 1. Verificar se há caixa aberto
    print('1️⃣ Verificando caixa aberto...');
    final caixaAberto = await supabase
        .from('caixa')
        .select()
        .isFilter('data_fechamento', null)
        .maybeSingle();
    
    if (caixaAberto != null) {
      print('✅ Caixa aberto encontrado:');
      print('   ID: ${caixaAberto['id']}');
      print('   Data abertura: ${caixaAberto['data_abertura']}');
      print('   Saldo inicial: R\$ ${caixaAberto['saldo_inicial']}');
      
      // 2. Buscar pedidos desde a abertura do caixa
      print('\n2️⃣ Buscando pedidos desde ${caixaAberto['data_abertura']}...');
      final pedidos = await supabase
          .from('pedidos')
          .select()
          .gte('created_at', caixaAberto['data_abertura'])
          .order('created_at');
      
      print('📊 Total de pedidos: ${pedidos.length}');
      
      if (pedidos.isNotEmpty) {
        double totalGeral = 0;
        for (final pedido in pedidos) {
          final total = pedido['total'] ?? 0;
          totalGeral += total;
          print('   Pedido #${pedido['numero'] ?? pedido['id']}:');
          print('      - Total: R\$ $total');
          print('      - Pagamento: ${pedido['forma_pagamento']}');
          print('      - Criado em: ${pedido['created_at']}');
        }
        print('\n💰 Total geral de vendas: R\$ $totalGeral');
      } else {
        print('   ⚠️ Nenhum pedido encontrado neste período');
      }
      
    } else {
      print('⚠️ Nenhum caixa aberto encontrado');
      
      // Verificar se há caixas fechados
      final ultimoCaixa = await supabase
          .from('caixa')
          .select()
          .order('data_abertura', ascending: false)
          .limit(1)
          .maybeSingle();
      
      if (ultimoCaixa != null) {
        print('   Último caixa: ${ultimoCaixa['data_abertura']} (FECHADO)');
      }
    }
    
    // 3. Verificar todos os pedidos recentes
    print('\n3️⃣ Últimos 5 pedidos no sistema:');
    final ultimosPedidos = await supabase
        .from('pedidos')
        .select()
        .order('created_at', ascending: false)
        .limit(5);
    
    for (final pedido in ultimosPedidos) {
      print('   #${pedido['numero'] ?? pedido['id']}: R\$ ${pedido['total']} - ${pedido['created_at']}');
    }
    
  } catch (e) {
    print('❌ Erro: $e');
  } finally {
    supabase.dispose();
  }
}