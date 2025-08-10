// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lhvfacztsbflrtfibeek.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );
  
  print('=== TESTE DE BUSCA DE PRODUTOS ===\n');
  
  try {
    // 1. Buscar produtos com suas categorias (exatamente como no app)
    print('1. Buscando produtos com categorias...');
    final produtosResponse = await supabase
        .from('produtos')
        .select('*, categorias(id, nome)')
        .order('nome');
    
    print('Total de produtos: ${produtosResponse.length}\n');
    
    // 2. Verificar pizzas doces
    print('2. Identificando pizzas doces...');
    int countPizzasDoces = 0;
    
    for (var produto in produtosResponse) {
      final categoria = produto['categorias'];
      final nomeProduto = produto['nome']?.toString().toLowerCase() ?? '';
      final tipoProduto = produto['tipo_produto']?.toString().toLowerCase() ?? '';
      
      bool isPizzaDoce = nomeProduto.contains('doce') ||
                         nomeProduto.contains('chocolate') ||
                         nomeProduto.contains('nutella') ||
                         nomeProduto.contains('brigadeiro') ||
                         nomeProduto.contains('romeu') ||
                         nomeProduto.contains('morango');
      
      if (isPizzaDoce) {
        countPizzasDoces++;
        print('  ✓ ${produto['nome']}');
        print('    - ID: ${produto['id']}');
        print('    - Categoria: ${categoria?['nome'] ?? 'SEM CATEGORIA'} (ID: ${categoria?['id']})');
        print('    - Tipo: $tipoProduto');
        print('    - Preço unitário: R\$ ${produto['preco_unitario']}');
        
        // Buscar preços por tamanho
        final precos = await supabase
            .from('produtos_precos')
            .select('*, produtos_tamanho(nome)')
            .eq('produto_id', produto['id']);
        
        if (precos.isNotEmpty) {
          print('    - Preços por tamanho:');
          for (var preco in precos) {
            print('      • ${preco['produtos_tamanho']['nome']}: R\$ ${preco['preco']}');
          }
        }
        print('');
      }
    }
    
    print('Total de pizzas doces encontradas: $countPizzasDoces\n');
    
    // 3. Verificar categorias
    print('3. Categorias disponíveis:');
    final categorias = await supabase
        .from('categorias')
        .select('*')
        .order('id');
    
    for (var cat in categorias) {
      print('  - ID ${cat['id']}: ${cat['nome']}');
      
      // Contar produtos desta categoria
      final count = produtosResponse.where((p) => 
        p['categorias'] != null && p['categorias']['id'] == cat['id']
      ).length;
      
      print('    Total de produtos: $count');
    }
    
    // 4. Verificar se categoria Pizzas tem as doces
    print('\n4. Produtos da categoria Pizzas (ID: 1):');
    final pizzas = produtosResponse.where((p) => 
      p['categorias'] != null && p['categorias']['id'] == 1
    ).toList();
    
    for (var pizza in pizzas) {
      print('  - ${pizza['nome']}');
    }
    
    print('\n=== TESTE CONCLUÍDO ===');
    
  } catch (e, stackTrace) {
    print('❌ Erro: $e');
    print('Stack trace: $stackTrace');
  }
  
  exit(0);
}