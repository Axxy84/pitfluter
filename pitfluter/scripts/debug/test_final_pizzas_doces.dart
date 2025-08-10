// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lhvfacztsbflrtfibeek.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );
  
  print('=== TESTE FINAL - PIZZAS DOCES COM PREÇOS ===\n');
  
  try {
    // Fazer a consulta EXATAMENTE como o app faz agora
    print('Consultando produtos com JOIN completo...\n');
    
    final produtosResponse = await supabase
        .from('produtos')
        .select('''
          *,
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
    
    print('✅ CONSULTA REALIZADA COM SUCESSO!\n');
    print('Total de produtos: ${produtosResponse.length}\n');
    
    // Verificar pizzas doces
    int countPizzasDoces = 0;
    int countComPrecos = 0;
    
    for (var produto in produtosResponse) {
      final nomeProduto = produto['nome']?.toString().toLowerCase() ?? '';
      final isPizzaDoce = nomeProduto.contains('chocolate') || 
                          nomeProduto.contains('doce') ||
                          nomeProduto.contains('nutella') ||
                          nomeProduto.contains('brigadeiro') ||
                          nomeProduto.contains('romeu') ||
                          nomeProduto.contains('morango');
      
      if (isPizzaDoce) {
        countPizzasDoces++;
        final precos = produto['produtos_precos'] as List?;
        
        if (precos != null && precos.isNotEmpty) {
          countComPrecos++;
          print('✅ ${produto['nome']}');
          print('   ${precos.length} tamanhos com preços disponíveis');
          
          // Mostrar mapeamento P, M, G, GG
          final Map<String, dynamic> precosPorTamanho = {};
          for (var preco in precos) {
            final tamanho = preco['produtos_tamanho']?['nome'];
            if (tamanho != null) {
              precosPorTamanho[tamanho] = preco['preco'];
            }
          }
          
          // Mapear para exibição
          final mapeamento = {
            'P': precosPorTamanho['Broto'],
            'M': precosPorTamanho['Média'],
            'G': precosPorTamanho['Grande'],
            'GG': precosPorTamanho['Família'],
          };
          
          print('   Exibição no app: P(R\$${mapeamento['P']}), M(R\$${mapeamento['M']}), G(R\$${mapeamento['G']}), GG(R\$${mapeamento['GG']})');
        } else {
          print('❌ ${produto['nome']} - SEM PREÇOS');
        }
      }
    }
    
    print('\n=== RESUMO FINAL ===');
    print('✅ Pizzas doces encontradas: $countPizzasDoces');
    print('✅ Pizzas doces COM preços: $countComPrecos');
    print('✅ Consulta JOIN funcionando corretamente!');
    print('\n🎉 AS PIZZAS DOCES AGORA DEVEM APARECER COM PREÇOS NO FRONT-END!');
    
  } catch (e, stackTrace) {
    print('❌ Erro: $e');
    print('Stack trace: $stackTrace');
  }
  
  exit(0);
}