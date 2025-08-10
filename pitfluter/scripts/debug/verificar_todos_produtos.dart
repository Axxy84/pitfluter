// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lhvfacztsbflrtfibeek.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );
  
  print('=== LISTANDO TODOS OS PRODUTOS ===\n');
  
  try {
    final produtos = await supabase
        .from('produtos')
        .select('*')
        .order('id');
    
    print('Total de produtos: ${produtos.length}\n');
    
    for (final produto in produtos) {
      print('ID: ${produto['id']}');
      print('Nome: ${produto['nome']}');
      print('Tipo: ${produto['tipo_produto']}');
      print('Preço Unitário: ${produto['preco_unitario']}');
      print('Categoria ID: ${produto['categoria_id']}');
      print('---\n');
    }
    
    // Verificar tipos distintos
    final tipos = <String>{};
    for (final produto in produtos) {
      if (produto['tipo_produto'] != null) {
        tipos.add(produto['tipo_produto'].toString());
      }
    }
    
    print('Tipos de produto únicos: $tipos');
    
    // Verificar produtos com nome contendo pizza
    final pizzas = produtos.where((p) => 
      p['nome'] != null && 
      p['nome'].toString().toLowerCase().contains('pizza')
    ).toList();
    
    print('\nProdutos com "pizza" no nome: ${pizzas.length}');
    for (final pizza in pizzas) {
      print('  - ${pizza['nome']} (tipo: ${pizza['tipo_produto']})');
    }
    
  } catch (e) {
    print('❌ Erro: $e');
  }
  
  exit(0);
}