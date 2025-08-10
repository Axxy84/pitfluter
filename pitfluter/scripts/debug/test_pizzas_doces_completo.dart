// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lhvfacztsbflrtfibeek.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );
  
  print('=== TESTE COMPLETO DE PIZZAS DOCES ===\n');
  
  try {
    // 1. Buscar todos os produtos que contenham "doce", "chocolate", etc
    print('1. Buscando produtos doces por nome...');
    final produtosDoces = await supabase
        .from('produtos')
        .select('*')
        .or('nome.ilike.%doce%,nome.ilike.%chocolate%,nome.ilike.%brigadeiro%,nome.ilike.%nutella%,nome.ilike.%morango%,nome.ilike.%romeu%');
    
    print('Produtos doces encontrados: ${produtosDoces.length}');
    
    if (produtosDoces.isEmpty) {
      print('\n❌ NENHUMA PIZZA DOCE ENCONTRADA!');
      print('Vamos criar as pizzas doces...\n');
      
      // 2. Buscar ou criar categoria
      print('2. Verificando categoria...');
      var categorias = await supabase
          .from('categorias')
          .select('id, nome')
          .or('nome.ilike.%pizza%,nome.eq.Pizzas');
      
      int categoriaId;
      if (categorias.isEmpty) {
        print('Criando categoria Pizzas...');
        final novaCategoria = await supabase
            .from('categorias')
            .insert({'nome': 'Pizzas'})
            .select()
            .single();
        categoriaId = novaCategoria['id'];
      } else {
        categoriaId = categorias.first['id'];
        print('Usando categoria existente: ${categorias.first['nome']} (ID: $categoriaId)');
      }
      
      // 3. Buscar tamanhos
      print('\n3. Verificando tamanhos...');
      final tamanhos = await supabase
          .from('produtos_tamanho')
          .select('id, nome')
          .order('id');
      
      if (tamanhos.isEmpty) {
        print('Criando tamanhos...');
        final tamanhosData = [
          {'nome': 'P'},
          {'nome': 'M'},
          {'nome': 'G'},
          {'nome': 'GG'},
        ];
        
        await supabase
            .from('produtos_tamanho')
            .insert(tamanhosData);
        
        // Buscar novamente
        final tamanhosCriados = await supabase
            .from('produtos_tamanho')
            .select('id, nome')
            .order('id');
        print('Tamanhos criados: ${tamanhosCriados.map((t) => t['nome']).toList()}');
      } else {
        print('Tamanhos existentes: ${tamanhos.map((t) => t['nome']).toList()}');
      }
      
      // 4. Criar pizzas doces
      print('\n4. Criando pizzas doces...');
      final pizzasDoces = [
        {'nome': 'Pizza de Chocolate', 'descricao': 'Pizza doce com chocolate ao leite e morangos'},
        {'nome': 'Pizza de Morango com Nutella', 'descricao': 'Pizza doce com Nutella e morangos'},
        {'nome': 'Pizza Romeu e Julieta', 'descricao': 'Pizza doce com goiabada e queijo'},
        {'nome': 'Pizza de Banana com Canela', 'descricao': 'Pizza doce com banana e canela'},
        {'nome': 'Pizza de Brigadeiro', 'descricao': 'Pizza doce com brigadeiro e granulado'},
        {'nome': 'Pizza de Chocolate Branco', 'descricao': 'Pizza doce com chocolate branco'},
        {'nome': 'Pizza de Doce de Leite', 'descricao': 'Pizza doce com doce de leite'},
      ];
      
      for (var pizza in pizzasDoces) {
        try {
          print('Criando: ${pizza['nome']}');
          
          final produto = await supabase
              .from('produtos')
              .insert({
                'nome': pizza['nome'],
                'categoria_id': categoriaId,
                'tipo_produto': 'pizza',
                'preco_unitario': 35.00
              })
              .select()
              .single();
          
          final produtoId = produto['id'];
          print('  ✓ Produto criado com ID: $produtoId');
          
          // Criar preços por tamanho
          final tamanhosRefresh = await supabase
              .from('produtos_tamanho')
              .select('id, nome');
          
          final precos = [
            {'tamanho': 'P', 'preco': 30.00},
            {'tamanho': 'M', 'preco': 40.00},
            {'tamanho': 'G', 'preco': 50.00},
            {'tamanho': 'GG', 'preco': 60.00},
          ];
          
          for (var precoInfo in precos) {
            final tamanho = tamanhosRefresh.firstWhere(
              (t) => t['nome'] == precoInfo['tamanho'],
              orElse: () => {'id': null}
            );
            
            if (tamanho['id'] != null) {
              await supabase
                  .from('produtos_precos')
                  .insert({
                    'produto_id': produtoId,
                    'tamanho_id': tamanho['id'],
                    'preco': precoInfo['preco'],
                    'preco_promocional': precoInfo['preco']
                  });
              print('    - Preço ${precoInfo['tamanho']}: R\$ ${precoInfo['preco']}');
            }
          }
        } catch (e) {
          print('  ❌ Erro ao criar ${pizza['nome']}: $e');
        }
      }
    } else {
      // Listar pizzas existentes e seus preços
      for (var produto in produtosDoces) {
        print('\n📦 ${produto['nome']}');
        print('  ID: ${produto['id']}');
        print('  Tipo: ${produto['tipo_produto']}');
        print('  Categoria: ${produto['categoria_id']}');
        print('  Preço unitário: R\$ ${produto['preco_unitario']}');
        
        // Buscar preços por tamanho
        final precos = await supabase
            .from('produtos_precos')
            .select('*, produtos_tamanho(nome)')
            .eq('produto_id', produto['id']);
        
        if (precos.isEmpty) {
          print('  ⚠️ SEM PREÇOS POR TAMANHO!');
        } else {
          print('  Preços por tamanho:');
          for (var preco in precos) {
            final tamanho = preco['produtos_tamanho']?['nome'] ?? 'N/A';
            print('    - $tamanho: R\$ ${preco['preco']}');
          }
        }
      }
    }
    
    print('\n=== TESTE CONCLUÍDO ===');
    
  } catch (e, stackTrace) {
    print('❌ Erro: $e');
    print('Stack trace: $stackTrace');
  }
  
  exit(0);
}