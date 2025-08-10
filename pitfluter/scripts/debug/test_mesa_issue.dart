// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://akfmfdmsanobdaznfdjw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFrZm1mZG1zYW5vYmRhem5mZGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2NTQxMzgsImV4cCI6MjA0ODIzMDEzOH0.EfF8CeAehGgJy7sZg5LXnQgWKdPTwnQOiN5pjrPFzuo',
  );

  final supabase = Supabase.instance.client;
  
  // === TESTANDO PROBLEMA DAS MESAS ===
  
  // 1. Verificar estrutura da tabela pedidos
  // 1. Buscando colunas da tabela pedidos...
  try {
    final response = await supabase
        .from('pedidos')
        .select()
        .limit(1);
    
    if (response.isNotEmpty) {
      // Colunas encontradas: ${response[0].keys.toList()}
      // Exemplo de pedido: $response
    }
  } catch (e) {
    // Erro ao buscar pedidos: $e
  }
  
  // 2. Buscando pedidos com mesa_id não nulo...
  try {
    final response = await supabase
        .from('pedidos')
        .select('id, numero, mesa_id, total, created_at, tipo')
        .not('mesa_id', 'is', null);
    
    // Pedidos com mesa encontrados: ${response.length}
    for (final _ in response) {
      // Pedido #${pedido['numero']}: Mesa ${pedido['mesa_id']}, Total: ${pedido['total']}, Tipo: ${pedido['tipo']}
    }
  } catch (e) {
    // Erro: $e
  }
  
  // 3. Verificando se existe coluna status...
  try {
    await supabase
        .from('pedidos')
        .select('status')
        .limit(1);
    // Coluna status existe!
  } catch (e) {
    if (e.toString().contains('column') || e.toString().contains('status')) {
      // ❌ Coluna status NÃO existe na tabela pedidos
    } else {
      // Erro: $e
    }
  }
  
  // 4. Buscando mesas...
  try {
    final response = await supabase
        .from('mesas')
        .select()
        .limit(5);
    
    // Mesas encontradas: ${response.length}
    for (final _ in response) {
      // Mesa ${mesa['numero']}: ${mesa['ocupada'] ? 'OCUPADA' : 'LIVRE'}
    }
  } catch (e) {
    // Erro ao buscar mesas: $e
  }
  
  // === FIM DO TESTE ===
  
  // Finalizar
  Supabase.instance.client.dispose();
}