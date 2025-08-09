import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://akfmfdmsanobdaznfdjw.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFrZm1mZG1zYW5vYmRhem5mZGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2NTQxMzgsImV4cCI6MjA0ODIzMDEzOH0.EfF8CeAehGgJy7sZg5LXnQgWKdPTwnQOiN5pjrPFzuo',
  );
  
  // === VERIFICANDO PROBLEMA DAS MESAS ===
  
  // 1. Verificar pedidos com mesa_id
  // 1. Buscando pedidos com mesa_id...
  try {
    final response = await supabase
        .from('pedidos')
        .select('id, numero, mesa_id, total, created_at, tipo, data_hora_entrega')
        .not('mesa_id', 'is', null);
    
    // Pedidos com mesa encontrados: ${response.length}
    for (final _ in response) {
      // final finalizado = pedido['data_hora_entrega'] != null;
      // Pedido #${pedido['numero']}: Mesa ${pedido['mesa_id']}, Total: ${pedido['total']}, Status: ${finalizado ? "FINALIZADO" : "ABERTO"}
    }
  } catch (e) {
    // Erro: $e
  }
  
  // 2. Verificar pedidos de mesa não finalizados
  // 2. Buscando pedidos de mesa NÃO finalizados (sem data_hora_entrega)...
  try {
    final response = await supabase
        .from('pedidos')
        .select('id, numero, mesa_id, total, created_at')
        .not('mesa_id', 'is', null)
        .isFilter('data_hora_entrega', null);
    
    // Pedidos de mesa ABERTOS: ${response.length}
    for (final _ in response) {
      // Pedido #${pedido['numero']}: Mesa ${pedido['mesa_id']}, Total: ${pedido['total']}
    }
  } catch (e) {
    // Erro: $e
  }
  
  // 3. Verificar estado das mesas
  // 3. Verificando mesas...
  try {
    final response = await supabase
        .from('mesas')
        .select()
        .order('numero');
    
    // Mesas no sistema: ${response.length}
    for (final _ in response) {
      // Mesa ${mesa['numero']}: ${mesa['ocupada'] ? 'OCUPADA' : 'LIVRE'} (ID: ${mesa['id']})
    }
  } catch (e) {
    // Erro: $e
  }
  
  // === FIM DA VERIFICAÇÃO ===
}