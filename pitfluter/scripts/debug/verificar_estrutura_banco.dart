// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lhvfacztsbflrtfibeek.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );
  
  print('=== VERIFICANDO ESTRUTURA DO BANCO ===\n');
  
  try {
    // 1. Verificar produtos com tipo_produto = pizza_doce
    print('1. Buscando produtos com tipo_produto = pizza_doce...');
    final pizzasDoces = await supabase
        .from('produtos')
        .select('*')
        .eq('tipo_produto', 'pizza_doce');
    
    print('Produtos encontrados: ${pizzasDoces.length}');
    for (final produto in pizzasDoces) {
      print('  ID: ${produto['id']}');
      print('  Nome: ${produto['nome']}');
      print('  Tipo: ${produto['tipo_produto']}');
      print('  Preço unitário: ${produto['preco_unitario']}');
      print('  Categoria: ${produto['categoria_id']}');
      print('  ---');
    }
    
    // 2. Verificar produtos_tamanho
    if (pizzasDoces.isNotEmpty) {
      print('\n2. Verificando produtos_tamanho...');
      for (final produto in pizzasDoces) {
        final tamanhos = await supabase
            .from('produtos_tamanho')
            .select('*')
            .eq('produto_id', produto['id']);
        
        if (tamanhos.isNotEmpty) {
          print('\n  ${produto['nome']}:');
          for (final tamanho in tamanhos) {
            print('    - Tamanho: ${tamanho['tamanho']}');
            print('      Preço: R\$ ${tamanho['preco']}');
          }
        } else {
          print('\n  ${produto['nome']}: SEM TAMANHOS/PREÇOS');
        }
      }
    }
    
    // 3. Buscar TODOS produtos que tenham a palavra "doce"
    print('\n3. Buscando TODOS produtos com "doce" no nome...');
    final produtosDoce = await supabase
        .from('produtos')
        .select('*')
        .ilike('nome', '%doce%');
    
    print('Produtos com "doce" no nome: ${produtosDoce.length}');
    for (final produto in produtosDoce) {
      print('  - ${produto['nome']} (tipo: ${produto['tipo_produto']})');
    }
    
    // 4. Verificar estrutura da tabela produtos_tamanho
    print('\n4. Amostra de produtos_tamanho...');
    final amostra = await supabase
        .from('produtos_tamanho')
        .select('*')
        .limit(5);
    
    for (final item in amostra) {
      print('  Produto ID: ${item['produto_id']}, Tamanho: ${item['tamanho']}, Preço: ${item['preco']}');
    }
    
    print('\n=== VERIFICAÇÃO CONCLUÍDA ===');
    
  } catch (e) {
    print('❌ Erro: $e');
  }
  
  exit(0);
}