// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lhvfacztsbflrtfibeek.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );
  
  print('=== TESTE QUERY DIRETA (IGUAL AO _ProdutoCard) ===\n');
  
  try {
    // Primeiro, pegar um ID de pizza doce
    final produtos = await supabase
        .from('produtos')
        .select('id, nome')
        .ilike('nome', '%chocolate%')
        .limit(1);
    
    if (produtos.isNotEmpty) {
      final produtoId = produtos[0]['id'];
      final produtoNome = produtos[0]['nome'];
      
      print('Testando com: $produtoNome (ID: $produtoId)\n');
      
      // Query IDÊNTICA ao que o _ProdutoCard faz agora
      print('Executando query direta...');
      final response = await supabase
          .from('produtos_precos')
          .select('*, produtos_tamanho(nome)')
          .eq('produto_id', produtoId);
      
      print('Resposta recebida: ${response.length} preços\n');
      
      if (response.isNotEmpty) {
        print('✅ PREÇOS ENCONTRADOS:');
        for (var preco in response) {
          final tamanho = preco['produtos_tamanho']?['nome'] ?? 'N/A';
          print('  - $tamanho: R\$ ${preco['preco']}');
        }
        
        print('\n🎉 A QUERY FUNCIONA! Os preços devem aparecer no app!');
      } else {
        print('❌ Nenhum preço encontrado para este produto');
      }
    } else {
      print('❌ Nenhuma pizza de chocolate encontrada');
    }
    
  } catch (e, stackTrace) {
    print('❌ ERRO: $e');
    print('Stack trace: $stackTrace');
  }
  
  exit(0);
}