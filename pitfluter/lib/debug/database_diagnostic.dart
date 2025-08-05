import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseDiagnostic {
  static final _supabase = Supabase.instance.client;

  static Future<void> runDiagnostic() async {
    print('🔍 INICIANDO DIAGNÓSTICO COMPLETO DO BANCO DE DADOS');
    print('=' * 60);
    
    try {
      await _discoverAllTables();
      await _checkTables();
      await _checkCategorias();
      await _checkProdutos();
      await _checkPrecos();
      await _searchPizzaTables();
      await _checkRelationships();
    } catch (e) {
      print('❌ ERRO GERAL NO DIAGNÓSTICO: $e');
    }
    
    print('=' * 60);
    print('✅ DIAGNÓSTICO CONCLUÍDO');
  }

  static Future<void> _discoverAllTables() async {
    print('\n🔍 DESCOBRINDO TODAS AS TABELAS NO BANCO:');
    
    // Tentar várias formas de descobrir tabelas
    final possibleTables = [
      'produtos_produto', 'produtos_categoria', 'produtos_tamanho', 'produtos_produtopreco',
      'produtos', 'products', 'pizza', 'pizzas', 'categorias', 'categories',
      'produto_precos', 'product_prices', 'precos', 'prices',
      'tamanhos', 'sizes', 'pedidos', 'orders', 'clientes', 'customers',
      'ingredientes', 'ingredients', 'sabores', 'flavors'
    ];
    
    final existingTables = <String>[];
    
    for (final table in possibleTables) {
      try {
        final response = await _supabase.from(table).select('*').limit(1);
        existingTables.add(table);
        print('✅ $table: ${response.length} registros');
      } catch (e) {
        // Tabela não existe - ignorar
      }
    }
    
    print('\n📋 RESUMO DAS TABELAS ENCONTRADAS:');
    if (existingTables.isEmpty) {
      print('❌ Nenhuma tabela encontrada!');
    } else {
      for (final table in existingTables) {
        print('   ✅ $table');
      }
    }
  }

  static Future<void> _searchPizzaTables() async {
    print('\n🍕 PROCURANDO ESPECIFICAMENTE POR PIZZAS:');
    
    final pizzaTables = ['pizza', 'pizzas', 'receitas', 'recipes', 'sabores_pizza'];
    
    for (final table in pizzaTables) {
      try {
        final response = await _supabase.from(table).select('*').limit(5);
        print('🍕 Tabela $table encontrada!');
        print('   📊 Total de registros: ${response.length}');
        
        if (response.isNotEmpty) {
          print('   📝 Primeiros registros:');
          for (int i = 0; i < (response.length > 3 ? 3 : response.length); i++) {
            final item = response[i];
            print('      ID: ${item['id']} | Nome: ${item['nome'] ?? item['name'] ?? 'N/A'}');
          }
        }
      } catch (e) {
        print('   ❌ Tabela $table não encontrada');
      }
    }
  }

  static Future<void> _checkTables() async {
    print('\n📋 VERIFICANDO TABELAS EXISTENTES:');
    try {
      // Tentar acessar cada tabela para ver se existe
      final tables = ['produtos_categoria', 'produtos_produto', 'produtos_produtopreco', 'produtos_tamanho'];
      
      for (final table in tables) {
        try {
          final response = await _supabase.from(table).select('*').limit(1);
          print('✅ Tabela $table: EXISTE (${response.length} registros encontrados)');
        } catch (e) {
          print('❌ Tabela $table: ERRO - $e');
        }
      }
    } catch (e) {
      print('❌ Erro ao verificar tabelas: $e');
    }
  }

  static Future<void> _checkCategorias() async {
    print('\n📂 VERIFICANDO CATEGORIAS:');
    try {
      final response = await _supabase.from('produtos_categoria').select('*');
      print('📊 Total de categorias: ${response.length}');
      
      if (response.isNotEmpty) {
        print('📝 Primeiras categorias:');
        for (int i = 0; i < (response.length > 3 ? 3 : response.length); i++) {
          final categoria = response[i];
          print('   ID: ${categoria['id']} | Nome: ${categoria['nome']}');
        }
      } else {
        print('⚠️  Nenhuma categoria encontrada!');
      }
    } catch (e) {
      print('❌ Erro ao buscar categorias: $e');
    }
  }

  static Future<void> _checkProdutos() async {
    print('\n🍕 VERIFICANDO PRODUTOS EM DETALHES:');
    try {
      final response = await _supabase.from('produtos_produto').select('*');
      print('📊 Total de produtos: ${response.length}');
      
      if (response.isNotEmpty) {
        print('\n📝 TODOS OS PRODUTOS ENCONTRADOS:');
        for (int i = 0; i < response.length; i++) {
          final produto = response[i];
          print('   🔸 ${i + 1}. ${produto['nome']}');
          print('      ID: ${produto['id']}');
          print('      Categoria ID: ${produto['categoria_id'] ?? 'null'}');
          print('      Descrição: ${produto['descricao'] ?? 'null'}');
          print('      Ativo: ${produto['ativo']}');
          print('      Imagem URL: ${produto['imagem_url'] ?? 'null'}');
          
          // Mostrar todas as colunas disponíveis
          print('      Todas as colunas: ${produto.keys.join(', ')}');
          print('');
        }
        
        // Análise dos produtos
        final pizzas = response.where((p) => 
          (p['nome'] as String).toLowerCase().contains('pizza') ||
          (p['nome'] as String).toLowerCase().contains('margherita') ||
          (p['nome'] as String).toLowerCase().contains('calabresa')
        ).toList();
        
        final bebidas = response.where((p) => 
          (p['nome'] as String).toLowerCase().contains('coca') ||
          (p['nome'] as String).toLowerCase().contains('água') ||
          (p['nome'] as String).toLowerCase().contains('refrigerante')
        ).toList();
        
        print('🍕 ANÁLISE POR TIPO:');
        print('   Possíveis Pizzas: ${pizzas.length}');
        for (final pizza in pizzas) {
          print('      - ${pizza['nome']}');
        }
        
        print('   Possíveis Bebidas: ${bebidas.length}');
        for (final bebida in bebidas) {
          print('      - ${bebida['nome']}');
        }
        
      } else {
        print('⚠️  Nenhum produto encontrado!');
      }
    } catch (e) {
      print('❌ Erro ao buscar produtos: $e');
    }
  }

  static Future<void> _checkPrecos() async {
    print('\n💰 VERIFICANDO PREÇOS:');
    try {
      final response = await _supabase.from('produtos_produtopreco').select('*');
      print('📊 Total de preços: ${response.length}');
      
      if (response.isNotEmpty) {
        print('📝 Primeiros preços:');
        for (int i = 0; i < (response.length > 5 ? 5 : response.length); i++) {
          final preco = response[i];
          print('   Produto ID: ${preco['produto_id']} | Preço: R\$ ${preco['preco']} | Tamanho: ${preco['tamanho_id']}');
        }
      } else {
        print('⚠️  Nenhum preço encontrado!');
      }
    } catch (e) {
      print('❌ Erro ao buscar preços: $e');
    }
  }

  static Future<void> _checkRelationships() async {
    print('\n🔗 TESTANDO RELACIONAMENTOS:');
    try {
      // Testar query com joins
      print('🔍 Testando query com JOIN (produtos + categorias):');
      final response1 = await _supabase
          .from('produtos_produto')
          .select('id, nome, categoria_id, produtos_categoria(id, nome)')
          .limit(3);
      
      print('✅ Query produtos + categorias: ${response1.length} resultados');
      for (final item in response1) {
        print('   ${item['nome']} -> Categoria: ${item['produtos_categoria']?['nome'] ?? 'N/A'}');
      }

      print('\n🔍 Testando query com JOIN (produtos + preços):');
      final response2 = await _supabase
          .from('produtos_produto')
          .select('id, nome, produtos_produtopreco(preco, tamanho_id)')
          .limit(3);
      
      print('✅ Query produtos + preços: ${response2.length} resultados');
      for (final item in response2) {
        final precos = item['produtos_produtopreco'] as List<dynamic>? ?? [];
        print('   ${item['nome']} -> ${precos.length} preços');
      }

    } catch (e) {
      print('❌ Erro ao testar relacionamentos: $e');
    }
  }

}