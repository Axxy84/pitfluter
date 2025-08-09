import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://akfmfdmsanobdaznfdjw.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFrZm1mZG1zYW5vYmRhem5mZGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2NTQxMzgsImV4cCI6MjA0ODIzMDEzOH0.EfF8CeAehGgJy7sZg5LXnQgWKdPTwnQOiN5pjrPFzuo',
  );
  
  // === VERIFICANDO CAMPOS DA TABELA PRODUTOS ===
  
  try {
    final response = await supabase
        .from('produtos_produto')
        .select()
        .limit(1);
    
    if (response.isNotEmpty) {
      final produto = response.first;
      // Campos disponíveis no produto:
      produto.forEach((key, value) {
        // $key: $value (tipo: ${value.runtimeType})
      });
    } else {
      // Nenhum produto encontrado
    }
  } catch (e) {
    // Erro: $e
  }
}