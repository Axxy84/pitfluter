// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://dcdcgzdjlkbbqkcdpxwa.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRjZGNnemRqbGtiYnFrY2RweHdhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgxNzgxNDcsImV4cCI6MjA0Mzc1NDE0N30.8CglvLj0cs4Fls-K5JCvP4-JkGJ5sv79dOnYfAcY7rs',
  );

  final supabase = Supabase.instance.client;
  
  print('\n${'=' * 80}');
  print('🍕 CRIANDO PIZZAS DOCES COM PREÇOS NO SUPABASE');
  print('=' * 80);
  
  try {
    // 1. Criar ou buscar categoria Pizzas Doces
    print('\n📁 Verificando categoria Pizzas Doces...');
    
    int? categoriaId;
    
    // Buscar categoria existente
    final categoriasExistentes = await supabase
        .from('categorias')
        .select('id, nome')
        .or('nome.eq.Pizzas Doces,nome.ilike.%doce%');
    
    if (categoriasExistentes.isNotEmpty) {
      categoriaId = categoriasExistentes[0]['id'];
      print('✅ Categoria encontrada: ID $categoriaId');
    } else {
      // Criar nova categoria
      final novaCategoria = await supabase
          .from('categorias')
          .insert({'nome': 'Pizzas Doces', 'ativo': true})
          .select()
          .single();
      
      categoriaId = novaCategoria['id'];
      print('✅ Categoria criada: ID $categoriaId');
    }
    
    // 2. Verificar/criar tamanhos
    print('\n📏 Verificando tamanhos...');
    
    final tamanhosExistentes = await supabase
        .from('produtos_tamanho')
        .select('id, nome')
        .order('id');
    
    print('Tamanhos existentes: ${tamanhosExistentes.map((t) => t['nome']).toList()}');
    
    // Criar tamanhos se não existirem
    final tamanhosNecessarios = ['P', 'M', 'G', 'GG'];
    final tamanhoIds = <String, int>{};
    
    for (var tamanhoNome in tamanhosNecessarios) {
      Map<String, dynamic>? tamanhoExiste;
      try {
        tamanhoExiste = tamanhosExistentes.firstWhere(
          (t) => t['nome'] == tamanhoNome,
        );
      } catch (e) {
        tamanhoExiste = null;
      }
      
      if (tamanhoExiste != null) {
        tamanhoIds[tamanhoNome] = tamanhoExiste['id'];
      } else {
        final novoTamanho = await supabase
            .from('produtos_tamanho')
            .insert({'nome': tamanhoNome})
            .select()
            .single();
        tamanhoIds[tamanhoNome] = novoTamanho['id'];
        print('✅ Tamanho $tamanhoNome criado: ID ${novoTamanho['id']}');
      }
    }
    
    // 3. Lista de pizzas doces para criar
    final pizzasDoces = [
      {
        'nome': 'Pizza de Chocolate',
        'descricao': 'Pizza doce com chocolate ao leite e morangos',
        'preco': 35.00,
      },
      {
        'nome': 'Pizza de Morango com Nutella',
        'descricao': 'Pizza doce com Nutella e morangos frescos',
        'preco': 40.00,
      },
      {
        'nome': 'Pizza Romeu e Julieta',
        'descricao': 'Pizza doce com goiabada e queijo',
        'preco': 35.00,
      },
      {
        'nome': 'Pizza de Banana com Canela',
        'descricao': 'Pizza doce com banana e canela',
        'preco': 30.00,
      },
      {
        'nome': 'Pizza de Brigadeiro',
        'descricao': 'Pizza doce com brigadeiro e granulado',
        'preco': 35.00,
      },
      {
        'nome': 'Pizza de Chocolate Branco',
        'descricao': 'Pizza doce com chocolate branco e frutas vermelhas',
        'preco': 40.00,
      },
      {
        'nome': 'Pizza de Doce de Leite',
        'descricao': 'Pizza doce com doce de leite e coco ralado',
        'preco': 35.00,
      },
    ];
    
    // 4. Criar pizzas doces
    print('\n🍕 Criando pizzas doces...');
    
    for (var pizzaInfo in pizzasDoces) {
      // Verificar se já existe
      final pizzaExiste = await supabase
          .from('produtos')
          .select('id, nome')
          .eq('nome', pizzaInfo['nome']!)
          .maybeSingle();
      
      int pizzaId;
      
      if (pizzaExiste != null) {
        pizzaId = pizzaExiste['id'];
        print('⚠️ Pizza já existe: ${pizzaInfo['nome']} (ID: $pizzaId)');
      } else {
        // Criar nova pizza
        final novaPizza = await supabase
            .from('produtos')
            .insert({
              'nome': pizzaInfo['nome'],
              'descricao': pizzaInfo['descricao'],
              'categoria_id': categoriaId,
              'tipo_produto': 'pizza',
              'preco_unitario': pizzaInfo['preco'],
              'ativo': true,
            })
            .select()
            .single();
        
        pizzaId = novaPizza['id'];
        print('✅ Pizza criada: ${pizzaInfo['nome']} (ID: $pizzaId)');
      }
      
      // 5. Criar preços por tamanho
      print('  💰 Configurando preços por tamanho...');
      
      final precosPorTamanho = {
        'P': 30.00,
        'M': 40.00,
        'G': 50.00,
        'GG': 60.00,
      };
      
      for (var entry in precosPorTamanho.entries) {
        final tamanhoNome = entry.key;
        final preco = entry.value;
        final tamanhoId = tamanhoIds[tamanhoNome];
        
        if (tamanhoId == null) continue;
        
        // Verificar se já existe preço
        final precoExiste = await supabase
            .from('produtos_precos')
            .select('id')
            .eq('produto_id', pizzaId)
            .eq('tamanho_id', tamanhoId)
            .maybeSingle();
        
        if (precoExiste == null) {
          await supabase
              .from('produtos_precos')
              .insert({
                'produto_id': pizzaId,
                'tamanho_id': tamanhoId,
                'preco': preco,
                'preco_promocional': preco,
              });
          print('    ✅ Preço criado: Tamanho $tamanhoNome = R\$ $preco');
        } else {
          print('    ⚠️ Preço já existe para tamanho $tamanhoNome');
        }
      }
    }
    
    // 6. Verificação final
    print('\n📊 VERIFICAÇÃO FINAL:');
    print('-' * 60);
    
    final pizzasComPrecos = await supabase
        .from('produtos')
        .select('id, nome, produtos_precos(preco, produtos_tamanho(nome))')
        .or('nome.ilike.%doce%,nome.ilike.%chocolate%,nome.ilike.%brigadeiro%,nome.ilike.%nutella%');
    
    for (var pizza in pizzasComPrecos) {
      final precos = pizza['produtos_precos'] as List;
      
      if (precos.isNotEmpty) {
        print('\n✅ ${pizza['nome']}:');
        for (var preco in precos) {
          final tamanho = preco['produtos_tamanho']?['nome'] ?? 'N/A';
          final valor = preco['preco'];
          print('  • Tamanho $tamanho: R\$ $valor');
        }
      } else {
        print('\n⚠️ ${pizza['nome']}: SEM PREÇOS POR TAMANHO');
      }
    }
    
    print('\n${'=' * 80}');
    print('✅ PROCESSO CONCLUÍDO!');
    print('=' * 80);
    
  } catch (e) {
    print('\n❌ Erro: $e');
  }
}