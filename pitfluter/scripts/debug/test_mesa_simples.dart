// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://akfmfdmsanobdaznfdjw.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFrZm1mZG1zYW5vYmRhem5mZGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2NTQxMzgsImV4cCI6MjA0ODIzMDEzOH0.EfF8CeAehGgJy7sZg5LXnQgWKdPTwnQOiN5pjrPFzuo',
  );
  
  // === TESTE SIMPLES DE MESAS ===
  
  // 1. Criar um pedido de teste com mesa
  // 1. Criando pedido de teste para Mesa 3...
  try {
    await supabase.from('pedidos').insert({
      'numero': 'TESTE-${DateTime.now().millisecondsSinceEpoch}',
      'mesa_id': 3,  // Mesa 3
      'tipo': 'balcao',
      'total': 50.00,
      'subtotal': 50.00,
      'taxa_entrega': 0,
      'desconto': 0,
      'forma_pagamento': 'Dinheiro',
      'observacoes': 'Pedido de teste para Mesa 3',
      'tempo_estimado_minutos': 30,
      // Não adicionar data_hora_entrega para manter como aberto
    });
    // ✅ Pedido criado com sucesso!
  } catch (e) {
    // ❌ Erro ao criar pedido: $e
  }
  
  // 2. Buscar pedidos de mesa abertos
  // 2. Buscando pedidos de mesa abertos...
  try {
    final response = await supabase
        .from('pedidos')
        .select('id, numero, mesa_id, total, created_at')
        .not('mesa_id', 'is', null)
        .isFilter('data_hora_entrega', null);
    
    // Pedidos de mesa encontrados: ${response.length}
    for (final _ in response) {
      // Pedido #${pedido['numero']}: Mesa ${pedido['mesa_id']}, Total: R\$ ${pedido['total']}
    }
  } catch (e) {
    // ❌ Erro ao buscar: $e
  }
  
  // === FIM DO TESTE ===
}