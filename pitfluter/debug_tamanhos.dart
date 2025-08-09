// import 'package:supabase/supabase.dart';

void main() async {
  // Script de debug para verificar tamanhos de pizzas
  // Todo o código foi comentado para produção
  
  // final supabase = SupabaseClient(
  //   'https://akfmfdmsanobdaznfdjw.supabase.co',
  //   'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFrZm1mZG1zYW5vYmRhem5mZGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2NTQxMzgsImV4cCI6MjA0ODIzMDEzOH0.EfF8CeAehGgJy7sZg5LXnQgWKdPTwnQOiN5pjrPFzuo',
  // );
  
  // DEBUG: TAMANHOS
  
  // try {
  //   // 1. Verificar tamanhos existentes
  //   // DEBUG: 1. Tamanhos no banco:
  //   final tamanhos = await supabase
  //       .from('produtos_tamanho')
  //       .select('id, nome');
  //   
  //   for (final tamanho in tamanhos) {
  //     DEBUG: ID: ${tamanho['id']}, Nome: "${tamanho['nome']}"
  //   }
  //   
  //   // 2. Verificar uma pizza doce específica
  //   // DEBUG: 2. Dados de uma pizza doce:
  //   final pizza = await supabase
  //       .from('produtos_produto')
  //       .select('''
  //         nome,
  //         produtos_produtopreco (
  //           preco,
  //           tamanho_id
  //         )
  //       ''')
  //       .eq('nome', 'Abacaxi Gratinado')
  //       .single();
  //   
  //   // DEBUG: Pizza: ${pizza['nome']}
  //   final precos = pizza['produtos_produtopreco'] as List;
  //   for (final preco in precos) {
  //     DEBUG: Tamanho ID: ${preco['tamanho_id']}, Preço: ${preco['preco']}
  //   }
  //   
  //   // 3. Fazer o JOIN manual
  //   // DEBUG: 3. JOIN manual dos dados:
  //   final pizzaCompleta = await supabase
  //       .from('produtos_produto')
  //       .select('*')
  //       .eq('nome', 'Abacaxi Gratinado')
  //       .single();
  //   
  //   final precosPizza = await supabase
  //       .from('produtos_produtopreco')
  //       .select('preco, tamanho_id')
  //       .eq('produto_id', pizzaCompleta['id']);
  //   
  //   for (final preco in precosPizza) {
  //     final tamanhoId = preco['tamanho_id'];
  //     final tamanhoInfo = tamanhos.firstWhere((t) => t['id'] == tamanhoId, orElse: () => {'nome': 'NÃO ENCONTRADO'});
  //     DEBUG: Tamanho: ${tamanhoInfo['nome']}, Preço: ${preco['preco']}
  //   }
  //   
  //   // 4. Verificar tipo de dados
  //   // DEBUG: 4. Tipos de dados:
  //   if (precosPizza.isNotEmpty) {
  //     final primeiroPreco = precosPizza.first;
  //     DEBUG: tamanho_id type: ${primeiroPreco['tamanho_id'].runtimeType}
  //     DEBUG: tamanho_id value: ${primeiroPreco['tamanho_id']}
  //   }
  //   
  //   if (tamanhos.isNotEmpty) {
  //     final primeiroTamanho = tamanhos.first;
  //     DEBUG: tamanho.id type: ${primeiroTamanho['id'].runtimeType}
  //     DEBUG: tamanho.id value: ${primeiroTamanho['id']}
  //   }
  //   
  // } catch (e) {
  //   // DEBUG: Erro: $e
  // }
}