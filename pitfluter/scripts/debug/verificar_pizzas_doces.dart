// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://akfmfdmsanobdaznfdjw.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFrZm1mZG1zYW5vYmRhem5mZGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2NTQxMzgsImV4cCI6MjA0ODIzMDEzOH0.EfF8CeAehGgJy7sZg5LXnQgWKdPTwnQOiN5pjrPFzuo',
  );
  
  // === VERIFICANDO PIZZAS DOCES ===
  
  try {
    // 1. Verificar categorias
    // 1. Buscando todas as categorias...
    final categorias = await supabase
        .from('produtos_categoria')
        .select('id, nome, ativo');
    
    // Categorias encontradas:
    for (final _ in categorias) {
      // ${cat['nome']} (ID: ${cat['id']}, Ativo: ${cat['ativo']})
    }
    
    // 2. Verificar se existe Pizzas Doces
    final pizzasDoces = categorias.where((cat) => cat['nome'] == 'Pizzas Doces').toList();
    if (pizzasDoces.isEmpty) {
      // ❌ Categoria "Pizzas Doces" NÃO existe!
      // Executando criação da categoria...
      
      // Criar categoria
      await supabase
          .from('produtos_categoria')
          .insert({
            'nome': 'Pizzas Doces',
            'descricao': 'Pizzas doces especiais',
            'ativo': true,
          })
          .select()
          .single();
      
      // ✅ Categoria criada com ID: ${novaCategoria['id']}
    } else {
      // ✅ Categoria "Pizzas Doces" já existe com ID: ${pizzasDoces.first['id']}
      
      // Verificar se está ativa
      if (pizzasDoces.first['ativo'] == false) {
        // ⚠️  Mas está INATIVA! Ativando...
        await supabase
            .from('produtos_categoria')
            .update({'ativo': true})
            .eq('id', pizzasDoces.first['id']);
        // ✅ Categoria ativada!
      }
    }
    
    // 3. Verificar se existem produtos nessa categoria
    final catId = pizzasDoces.isNotEmpty ? pizzasDoces.first['id'] : null;
    if (catId != null) {
      final produtos = await supabase
          .from('produtos_produto')
          .select('nome')
          .eq('categoria_id', catId);
      
      // Produtos na categoria Pizzas Doces: ${produtos.length}
      if (produtos.isNotEmpty) {
        for (final _ in produtos) {
          // ${p['nome']}
        }
      }
    }
    
    // === VERIFICAÇÃO CONCLUÍDA ===
    
  } catch (e) {
    // ❌ Erro: $e
  }
}