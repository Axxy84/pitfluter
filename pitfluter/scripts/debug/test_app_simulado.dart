// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lhvfacztsbflrtfibeek.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );
  
  print('=== SIMULANDO CARREGAMENTO DO APP ===\n');
  
  try {
    // 1. Carregar produtos exatamente como o app faz
    print('1. Carregando produtos com categorias...');
    final produtosResponse = await supabase
        .from('produtos')
        .select('*, categorias(id, nome)')
        .order('nome');
    
    print('Total de produtos carregados: ${produtosResponse.length}');
    
    // 2. Para cada pizza doce, carregar preços
    print('\n2. Carregando preços das pizzas doces...\n');
    
    for (var produto in produtosResponse) {
      final nomeProduto = produto['nome']?.toString().toLowerCase() ?? '';
      final isPizzaDoce = nomeProduto.contains('chocolate') || 
                          nomeProduto.contains('doce') ||
                          nomeProduto.contains('nutella') ||
                          nomeProduto.contains('brigadeiro') ||
                          nomeProduto.contains('romeu') ||
                          nomeProduto.contains('morango');
      
      if (isPizzaDoce) {
        print('📦 ${produto['nome']} (ID: ${produto['id']})');
        
        // Simular exatamente a query do _ProdutoCard
        try {
          final precosResponse = await supabase
              .from('produtos_precos')
              .select('*, produtos_tamanho(id, nome)')
              .eq('produto_id', produto['id']);
          
          print('  Preços carregados: ${precosResponse.length}');
          
          if (precosResponse.isEmpty) {
            print('  ⚠️ NENHUM PREÇO ENCONTRADO!');
          } else {
            // Mapear preços para exibição
            final Map<String, Map<String, dynamic>> precosPorTamanho = {};
            for (var preco in precosResponse) {
              final tamanhoInfo = preco['produtos_tamanho'];
              if (tamanhoInfo != null && tamanhoInfo['nome'] != null) {
                precosPorTamanho[tamanhoInfo['nome']] = preco;
                print('    - ${tamanhoInfo['nome']}: R\$ ${preco['preco']}');
              }
            }
            
            // Verificar mapeamento P, M, G, GG
            print('  Mapeamento para exibição:');
            final tamanhosBanco = {
              'P': 'Broto',
              'M': 'Média',
              'G': 'Grande',
              'GG': 'Família',
            };
            
            for (var entry in tamanhosBanco.entries) {
              final tamanhoExibir = entry.key;
              final tamanhoBanco = entry.value;
              final precoInfo = precosPorTamanho[tamanhoBanco];
              
              if (precoInfo != null) {
                print('    $tamanhoExibir (${tamanhoBanco}): R\$ ${precoInfo['preco']}');
              } else {
                print('    $tamanhoExibir (${tamanhoBanco}): SEM PREÇO');
              }
            }
          }
        } catch (e) {
          print('  ❌ Erro ao carregar preços: $e');
        }
        
        print('');
      }
    }
    
    print('=== SIMULAÇÃO CONCLUÍDA ===');
    
  } catch (e, stackTrace) {
    print('❌ Erro: $e');
    print('Stack trace: $stackTrace');
  }
  
  exit(0);
}