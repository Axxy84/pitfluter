// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lhvfacztsbflrtfibeek.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );
  
  print('=== VERIFICANDO PIZZAS DOCES NO BANCO ===\n');
  
  try {
    // 1. Verificar categorias disponíveis
    print('1. Buscando todas as categorias...');
    final categorias = await supabase
        .from('categorias')
        .select('id, nome')
        .order('nome');
    
    print('Categorias encontradas:');
    for (final cat in categorias) {
      print('  - ${cat['nome']} (ID: ${cat['id']})');
    }
    
    // 2. Verificar se existe categoria de pizza doce
    print('\n2. Procurando categoria de pizzas doces...');
    final pizzasDoces = categorias.where((cat) => 
      cat['nome'].toString().toLowerCase().contains('pizza') &&
      cat['nome'].toString().toLowerCase().contains('doce')
    ).toList();
    
    if (pizzasDoces.isEmpty) {
      print('❌ Nenhuma categoria de "Pizzas Doces" encontrada!');
      
      // Procurar qualquer categoria com pizza
      final pizzas = categorias.where((cat) => 
        cat['nome'].toString().toLowerCase().contains('pizza')
      ).toList();
      
      print('\nCategorias de pizza encontradas:');
      for (final cat in pizzas) {
        print('  - ${cat['nome']} (ID: ${cat['id']})');
      }
    } else {
      print('✅ Categoria de pizzas doces encontrada:');
      for (final cat in pizzasDoces) {
        print('  - ${cat['nome']} (ID: ${cat['id']})');
      }
    }
    
    // 3. Buscar produtos de pizza doce
    print('\n3. Buscando produtos de pizza doce...');
    final produtosPizzaDoce = await supabase
        .from('produtos')
        .select('id, nome, preco_unitario, categoria_id, tipo_produto')
        .or('nome.ilike.%doce%,tipo_produto.eq.pizza_doce');
    
    print('Produtos de pizza doce encontrados: ${produtosPizzaDoce.length}');
    for (final produto in produtosPizzaDoce) {
      print('  - ${produto['nome']} (ID: ${produto['id']}, Cat: ${produto['categoria_id']}, Tipo: ${produto['tipo_produto']})');
    }
    
    // 4. Verificar preços dos produtos de pizza doce
    if (produtosPizzaDoce.isNotEmpty) {
      print('\n4. Verificando preços por tamanho...');
      for (final produto in produtosPizzaDoce) {
        final precos = await supabase
            .from('produtos_precos')
            .select('*, tamanhos(nome)')
            .eq('produto_id', produto['id']);
        
        if (precos.isNotEmpty) {
          print('\n  ${produto['nome']}:');
          for (final preco in precos) {
            print('    - Tamanho ${preco['tamanhos']['nome']}: R\$ ${preco['preco']}');
          }
        } else {
          print('\n  ${produto['nome']}: SEM PREÇOS POR TAMANHO');
          if (produto['preco_unitario'] != null) {
            print('    - Preço unitário: R\$ ${produto['preco_unitario']}');
          }
        }
      }
    }
    
    // 5. Verificar tamanhos disponíveis
    print('\n5. Tamanhos disponíveis no sistema:');
    final tamanhos = await supabase
        .from('tamanhos')
        .select('id, nome')
        .order('id');
    
    for (final tamanho in tamanhos) {
      print('  - ${tamanho['nome']} (ID: ${tamanho['id']})');
    }
    
    print('\n=== VERIFICAÇÃO CONCLUÍDA ===');
    
  } catch (e) {
    print('❌ Erro: $e');
  }
  
  exit(0);
}