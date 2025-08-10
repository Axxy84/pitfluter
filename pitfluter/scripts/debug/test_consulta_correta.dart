// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lhvfacztsbflrtfibeek.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );
  
  print('=== TESTE DE CONSULTA CORRETA COM JOIN ===\n');
  
  try {
    // Consulta CORRETA com JOIN através de relacionamentos
    print('1. Fazendo consulta com relacionamentos (JOIN)...\n');
    
    final response = await supabase
        .from('produtos')
        .select('''
          id,
          nome,
          tipo_produto,
          preco_unitario,
          categoria_id,
          categorias(id, nome),
          produtos_precos(
            id,
            preco,
            preco_promocional,
            tamanho_id,
            produtos_tamanho(
              id,
              nome
            )
          )
        ''')
        .order('nome');
    
    print('Produtos encontrados: ${response.length}\n');
    
    // Filtrar apenas pizzas doces
    for (var produto in response) {
      final nomeProduto = produto['nome']?.toString().toLowerCase() ?? '';
      final isPizzaDoce = nomeProduto.contains('chocolate') || 
                          nomeProduto.contains('doce') ||
                          nomeProduto.contains('nutella') ||
                          nomeProduto.contains('brigadeiro') ||
                          nomeProduto.contains('romeu') ||
                          nomeProduto.contains('morango');
      
      if (isPizzaDoce) {
        print('📦 ${produto['nome']}');
        print('  ID: ${produto['id']}');
        print('  Tipo: ${produto['tipo_produto']}');
        print('  Categoria: ${produto['categorias']?['nome'] ?? 'N/A'}');
        print('  Preço unitário: R\$ ${produto['preco_unitario']}');
        
        final precos = produto['produtos_precos'] as List<dynamic>?;
        if (precos != null && precos.isNotEmpty) {
          print('  Preços por tamanho:');
          for (var precoInfo in precos) {
            final tamanho = precoInfo['produtos_tamanho']?['nome'] ?? 'N/A';
            final preco = precoInfo['preco'];
            print('    - $tamanho: R\$ $preco');
          }
        } else {
          print('  ⚠️ Sem preços por tamanho');
        }
        print('');
      }
    }
    
    print('\n=== ESTRUTURA DE DADOS PARA DEBUG ===\n');
    // Mostrar estrutura completa de uma pizza doce
    final pizzaExemplo = response.cast<Map<String, dynamic>>().firstWhere(
      (p) => p['nome'].toString().toLowerCase().contains('chocolate'),
      orElse: () => <String, dynamic>{}
    );
    
    if (pizzaExemplo.isNotEmpty) {
      print('Estrutura completa de ${pizzaExemplo['nome']}:');
      print(pizzaExemplo);
    }
    
  } catch (e, stackTrace) {
    print('❌ Erro: $e');
    print('Stack trace: $stackTrace');
  }
  
  exit(0);
}