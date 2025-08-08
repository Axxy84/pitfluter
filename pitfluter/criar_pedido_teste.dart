import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://vjryqdcaihzkkbhcntre.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZqcnlxZGNhaWh6a2tiaGNudHJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU2MDk1MTEsImV4cCI6MjA1MTE4NTUxMX0.DDc1CNMy9OlVRAPRGb-Jq4TjJwHxYB5MlvchM51vaQU',
  );

  final supabase = Supabase.instance.client;

  try {
    print('🔥 Criando pedido de teste...\n');
    
    // Buscar próximo número
    final ultimoPedido = await supabase
        .from('pedidos')
        .select('numero')
        .order('numero', ascending: false)
        .limit(1);
    
    int proximoNumero = 1;
    if (ultimoPedido.isNotEmpty && ultimoPedido.first['numero'] != null) {
      proximoNumero = ultimoPedido.first['numero'] + 1;
    }
    
    // Criar pedido de teste
    final pedidoData = {
      'numero': proximoNumero,
      'tipo': 'balcao',
      'total': 45.50,
      'forma_pagamento': 'Dinheiro',
      'observacoes': 'Pedido de teste para dashboard',
      'created_at': DateTime.now().toIso8601String(),
    };
    
    print('Criando pedido #$proximoNumero...');
    
    final response = await supabase
        .from('pedidos')
        .insert(pedidoData)
        .select()
        .single();
    
    print('✅ Pedido criado com sucesso!');
    print('   ID: ${response['id']}');
    print('   Número: ${response['numero']}');
    print('   Total: R\$ ${response['total']}');
    print('   Tipo: ${response['tipo']}');
    print('   Pagamento: ${response['forma_pagamento']}');
    print('   Data: ${response['created_at']}');
    
    // Verificar se foi salvo
    print('\n🔍 Verificando se foi salvo...');
    final verifica = await supabase
        .from('pedidos')
        .select()
        .eq('id', response['id'])
        .single();
    
    if (verifica != null) {
      print('✅ Pedido confirmado no banco de dados!');
      
      // Buscar todos os pedidos de hoje
      final hoje = DateTime.now();
      final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
      
      final pedidosHoje = await supabase
          .from('pedidos')
          .select()
          .gte('created_at', inicioHoje.toIso8601String());
      
      print('\n📊 Total de pedidos hoje: ${pedidosHoje.length}');
      double totalHoje = 0;
      for (final p in pedidosHoje) {
        totalHoje += (p['total'] ?? 0).toDouble();
      }
      print('💰 Total vendido hoje: R\$ $totalHoje');
    }
    
  } catch (e) {
    print('❌ Erro: $e');
  }
}