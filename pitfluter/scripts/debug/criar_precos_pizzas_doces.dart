// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lhvfacztsbflrtfibeek.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );
  
  print('=== CRIANDO PREÇOS PARA PIZZAS DOCES ===\n');
  
  try {
    // 1. Buscar pizzas doces
    print('1. Buscando pizzas doces...');
    final pizzasDoces = await supabase
        .from('produtos')
        .select('*')
        .or('nome.ilike.%doce%,nome.ilike.%chocolate%,nome.ilike.%brigadeiro%,nome.ilike.%nutella%,nome.ilike.%morango%,nome.ilike.%romeu%');
    
    print('Pizzas doces encontradas: ${pizzasDoces.length}');
    
    // 2. Buscar tamanhos disponíveis
    print('\n2. Buscando tamanhos disponíveis...');
    final tamanhos = await supabase
        .from('produtos_tamanho')
        .select('id, nome')
        .order('id');
    
    print('Tamanhos encontrados:');
    for (var tamanho in tamanhos) {
      print('  - ${tamanho['nome']} (ID: ${tamanho['id']})');
    }
    
    // 3. Definir mapeamento de preços
    final precosMap = {
      'Broto': 25.00,
      'Média': 35.00,
      'Grande': 45.00,
      'Família': 55.00,
      '8 Pedaços': 40.00,
    };
    
    // 4. Criar preços para cada pizza doce
    print('\n3. Criando preços por tamanho...');
    for (var pizza in pizzasDoces) {
      print('\n📦 ${pizza['nome']}:');
      
      // Verificar preços existentes
      final precosExistentes = await supabase
          .from('produtos_precos')
          .select('tamanho_id')
          .eq('produto_id', pizza['id']);
      
      final tamanhosExistentes = precosExistentes.map((p) => p['tamanho_id']).toSet();
      
      for (var tamanho in tamanhos) {
        final tamanhoId = tamanho['id'];
        final tamanhoNome = tamanho['nome'];
        
        // Pular se já existe preço para este tamanho
        if (tamanhosExistentes.contains(tamanhoId)) {
          print('  ✓ Tamanho $tamanhoNome já tem preço');
          continue;
        }
        
        // Obter preço do mapeamento
        final preco = precosMap[tamanhoNome] ?? 35.00;
        
        try {
          await supabase
              .from('produtos_precos')
              .insert({
                'produto_id': pizza['id'],
                'tamanho_id': tamanhoId,
                'preco': preco,
                'preco_promocional': preco
              });
          print('  + Criado: $tamanhoNome = R\$ $preco');
        } catch (e) {
          print('  ❌ Erro ao criar preço para $tamanhoNome: $e');
        }
      }
    }
    
    // 5. Verificar resultado final
    print('\n=== VERIFICAÇÃO FINAL ===');
    for (var pizza in pizzasDoces) {
      final precos = await supabase
          .from('produtos_precos')
          .select('*, produtos_tamanho(nome)')
          .eq('produto_id', pizza['id']);
      
      print('\n${pizza['nome']}:');
      if (precos.isEmpty) {
        print('  ⚠️ Ainda sem preços');
      } else {
        for (var preco in precos) {
          final tamanho = preco['produtos_tamanho']?['nome'] ?? 'N/A';
          print('  - $tamanho: R\$ ${preco['preco']}');
        }
      }
    }
    
    print('\n=== PREÇOS CRIADOS COM SUCESSO! ===');
    
  } catch (e, stackTrace) {
    print('❌ Erro: $e');
    print('Stack trace: $stackTrace');
  }
  
  exit(0);
}