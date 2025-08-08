import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://vjryqdcaihzkkbhcntre.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZqcnlxZGNhaWh6a2tiaGNudHJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU2MDk1MTEsImV4cCI6MjA1MTE4NTUxMX0.DDc1CNMy9OlVRAPRGb-Jq4TjJwHxYB5MlvchM51vaQU',
  );

  final supabase = Supabase.instance.client;

  print('Verificando pedidos no Supabase...\n');

  try {
    // Buscar TODOS os pedidos
    final todosPedidos = await supabase
        .from('pedidos')
        .select()
        .order('created_at', ascending: false);
    
    print('Total de pedidos no banco: ${todosPedidos.length}');
    
    if (todosPedidos.isNotEmpty) {
      print('\nÚltimos pedidos:');
      for (var i = 0; i < (todosPedidos.length < 5 ? todosPedidos.length : 5); i++) {
        final p = todosPedidos[i];
        print('  #${p['numero']} - ${p['created_at']} - R\$ ${p['total']} - ${p['forma_pagamento']}');
      }
    }
    
    // Buscar pedidos de hoje
    final hoje = DateTime.now();
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
    
    print('\nBuscando pedidos a partir de: ${inicioHoje.toIso8601String()}');
    
    final pedidosHoje = await supabase
        .from('pedidos')
        .select()
        .gte('created_at', inicioHoje.toIso8601String());
    
    print('Pedidos de hoje: ${pedidosHoje.length}');
    
    if (pedidosHoje.isNotEmpty) {
      double total = 0;
      for (final p in pedidosHoje) {
        total += (p['total'] ?? 0).toDouble();
      }
      print('Total vendido hoje: R\$ $total');
    }
    
  } catch (e) {
    print('Erro: $e');
  }
}