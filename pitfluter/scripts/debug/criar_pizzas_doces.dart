// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://akfmfdmsanobdaznfdjw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFrZm1mZG1zYW5vYmRhem5mZGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2NTQxMzgsImV4cCI6MjA0ODIzMDEzOH0.EfF8CeAehGgJy7sZg5LXnQgWKdPTwnQOiN5pjrPFzuo',
  );
  
  final supabase = Supabase.instance.client;
  
  print('=== CRIANDO PIZZAS DOCES ===\n');
  
  try {
    // 1. Buscar ou criar categoria "Pizzas Doces"
    print('1. Verificando categoria Pizzas Doces...');
    
    var categorias = await supabase
        .from('categorias')
        .select('id, nome')
        .ilike('nome', '%pizza%doce%');
    
    int categoriaId;
    
    if (categorias.isEmpty) {
      print('Categoria não encontrada. Criando...');
      
      final novaCategoria = await supabase
          .from('categorias')
          .insert({
            'nome': 'Pizzas Doces',
            'ativo': true
          })
          .select()
          .single();
      
      categoriaId = novaCategoria['id'];
      print('✅ Categoria criada com ID: $categoriaId');
    } else {
      categoriaId = categorias.first['id'];
      print('✅ Categoria encontrada com ID: $categoriaId');
    }
    
    // 2. Buscar tamanhos disponíveis
    print('\n2. Buscando tamanhos...');
    final tamanhos = await supabase
        .from('tamanhos')
        .select('id, nome')
        .order('id');
    
    print('Tamanhos encontrados:');
    for (var tamanho in tamanhos) {
      print('  - ${tamanho['nome']} (ID: ${tamanho['id']})');
    }
    
    // 3. Criar pizzas doces se não existirem
    print('\n3. Criando pizzas doces...');
    
    final pizzasDoces = [
      {
        'nome': 'Pizza de Chocolate',
        'descricao': 'Pizza doce com chocolate ao leite, granulado e morangos',
        'tipo': 'pizza_doce'
      },
      {
        'nome': 'Pizza de Morango com Nutella',
        'descricao': 'Pizza doce com Nutella e morangos frescos',
        'tipo': 'pizza_doce'
      },
      {
        'nome': 'Pizza Romeu e Julieta',
        'descricao': 'Pizza doce com goiabada e queijo',
        'tipo': 'pizza_doce'
      },
      {
        'nome': 'Pizza de Banana com Canela',
        'descricao': 'Pizza doce com banana, açúcar e canela',
        'tipo': 'pizza_doce'
      },
      {
        'nome': 'Pizza de Brigadeiro',
        'descricao': 'Pizza doce com brigadeiro e granulado',
        'tipo': 'pizza_doce'
      }
    ];
    
    for (var pizza in pizzasDoces) {
      // Verificar se já existe
      final existe = await supabase
          .from('produtos')
          .select('id')
          .eq('nome', pizza['nome']!)
          .maybeSingle();
      
      if (existe != null) {
        print('Pizza "${pizza['nome']}" já existe');
        continue;
      }
      
      // Criar produto
      final produto = await supabase
          .from('produtos')
          .insert({
            'nome': pizza['nome'],
            'descricao': pizza['descricao'],
            'categoria_id': categoriaId,
            'tipo_produto': pizza['tipo'],
            'preco_unitario': 35.00, // Preço base
            'ativo': true
          })
          .select()
          .single();
      
      print('✅ Pizza "${pizza['nome']}" criada com ID: ${produto['id']}');
      
      // Criar preços por tamanho
      final precos = [
        {'tamanho': 'P', 'preco': 25.00},
        {'tamanho': 'M', 'preco': 35.00},
        {'tamanho': 'G', 'preco': 45.00},
        {'tamanho': 'GG', 'preco': 55.00},
      ];
      
      for (var precoInfo in precos) {
        // Buscar ID do tamanho
        final tamanho = tamanhos.firstWhere(
          (t) => t['nome'] == precoInfo['tamanho'],
          orElse: () => {'id': null}
        );
        
        if (tamanho['id'] != null) {
          await supabase
              .from('produtos_precos')
              .insert({
                'produto_id': produto['id'],
                'tamanho_id': tamanho['id'],
                'preco': precoInfo['preco'],
                'preco_promocional': precoInfo['preco']
              });
          
          print('  - Preço ${precoInfo['tamanho']}: R\$ ${precoInfo['preco']}');
        }
      }
    }
    
    print('\n=== PIZZAS DOCES CRIADAS COM SUCESSO ===');
    
  } catch (e) {
    print('❌ Erro: $e');
  }
  
  exit(0);
}