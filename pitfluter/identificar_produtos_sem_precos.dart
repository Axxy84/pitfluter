// ignore_for_file: avoid_print, unused_import
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lhvfacztsbflrtfibeek.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );
  
  print('============================================================');
  print('      IDENTIFICAÇÃO DOS 13 PRODUTOS SEM PREÇOS');
  print('============================================================\n');
  
  try {
    // 1. Primeiro, vamos descobrir a estrutura da tabela produtos
    print('=== ETAPA 0: VERIFICANDO ESTRUTURA DA TABELA PRODUTOS ===');
    final estrutura = await supabase
        .from('produtos')
        .select('*')
        .limit(1);
    
    if (estrutura.isNotEmpty) {
      print('Colunas disponíveis na tabela produtos:');
      final produto = estrutura.first;
      for (final key in produto.keys) {
        print('  - $key: ${produto[key].runtimeType}');
      }
    }
    print('');
    
    // 1. Buscar todos os produtos ativos
    print('=== ETAPA 1: BUSCANDO TODOS OS PRODUTOS ===');
    final produtos = await supabase
        .from('produtos')
        .select('*')
        .eq('ativo', true)
        .order('id');
    
    print('Total de produtos ativos: ${produtos.length}\n');
    
    // 2. Buscar todas as categorias para referência
    print('=== ETAPA 2: BUSCANDO CATEGORIAS ===');
    final categorias = await supabase
        .from('categorias')
        .select('id, nome')
        .order('id');
    
    final categoriasMap = <int, String>{};
    for (final categoria in categorias) {
      categoriasMap[categoria['id']] = categoria['nome'];
    }
    
    print('Total de categorias: ${categorias.length}\n');
    
    // 3. Buscar todos os produtos que têm preços configurados
    print('=== ETAPA 3: BUSCANDO PRODUTOS COM PREÇOS ===');
    final produtosComPrecos = await supabase
        .from('produtos_precos')
        .select('produto_id')
        .order('produto_id');
    
    final produtoIdsComPrecos = <int>{};
    for (final preco in produtosComPrecos) {
      if (preco['produto_id'] != null) {
        produtoIdsComPrecos.add(preco['produto_id'] as int);
      }
    }
    
    print('Produtos únicos com preços: ${produtoIdsComPrecos.length}');
    print('Total de registros de preços: ${produtosComPrecos.length}\n');
    
    // 4. Identificar produtos SEM preços
    print('=== ETAPA 4: IDENTIFICANDO PRODUTOS SEM PREÇOS ===');
    final produtosSemPrecos = <Map<String, dynamic>>[];
    
    for (final produto in produtos) {
      final produtoId = produto['id'] as int;
      if (!produtoIdsComPrecos.contains(produtoId)) {
        final categoria = categoriasMap[produto['categoria_id']] ?? 'SEM CATEGORIA';
        produtosSemPrecos.add({
          'id': produto['id'],
          'nome': produto['nome'],
          'categoria_id': produto['categoria_id'],
          'categoria_nome': categoria,
          'tipo_produto': produto['tipo_produto'],
          'preco': produto['preco'] ?? produto['preco_unitario'] ?? 'N/A',
          'ativo': produto['ativo'],
        });
      }
    }
    
    print('🔍 PRODUTOS SEM PREÇOS ENCONTRADOS: ${produtosSemPrecos.length}');
    print('');
    
    // 5. Exibir detalhes completos dos produtos sem preços
    print('=== DETALHES COMPLETOS DOS PRODUTOS SEM PREÇOS ===');
    print('');
    
    if (produtosSemPrecos.isEmpty) {
      print('✅ Todos os produtos ativos têm preços configurados!');
    } else {
      // Agrupar por categoria
      final produtosPorCategoria = <String, List<Map<String, dynamic>>>{};
      
      for (final produto in produtosSemPrecos) {
        final categoria = produto['categoria_nome'] as String;
        produtosPorCategoria.putIfAbsent(categoria, () => []).add(produto);
      }
      
      // Exibir por categoria
      int contador = 1;
      for (final categoria in produtosPorCategoria.keys.toList()..sort()) {
        print('📂 CATEGORIA: $categoria');
        print('   ${'-' * (categoria.length + 20)}');
        
        final produtosDaCategoria = produtosPorCategoria[categoria]!;
        produtosDaCategoria.sort((a, b) => a['nome'].compareTo(b['nome']));
        
        for (final produto in produtosDaCategoria) {
          print('   $contador. ID: ${produto['id']}');
          print('      Nome: ${produto['nome']}');
          print('      Tipo Produto: ${produto['tipo_produto']}');
          print('      Preço: ${produto['preco']}');
          print('      Status: ${produto['ativo'] ? 'ATIVO' : 'INATIVO'}');
          print('');
          contador++;
        }
      }
      
      // 6. Resumo por categoria
      print('=== RESUMO POR CATEGORIA ===');
      for (final categoria in produtosPorCategoria.keys.toList()..sort()) {
        final qtd = produtosPorCategoria[categoria]!.length;
        print('• $categoria: $qtd produtos sem preços');
      }
      print('');
      
      // 7. Lista simples dos IDs e nomes
      print('=== LISTA SIMPLES (ID + NOME) ===');
      produtosSemPrecos.sort((a, b) => a['id'].compareTo(b['id']));
      for (final produto in produtosSemPrecos) {
        print('ID ${produto['id']}: ${produto['nome']}');
      }
      print('');
      
      // 8. Verificação de produtos ativos
      print('=== ANÁLISE DE STATUS ===');
      final ativos = produtosSemPrecos.where((p) => p['ativo'] == true).length;
      final inativos = produtosSemPrecos.length - ativos;
      
      print('• Produtos ATIVOS sem preços: $ativos');
      print('• Produtos INATIVOS sem preços: $inativos');
      print('');
      
      if (ativos > 0) {
        print('⚠️  ATENÇÃO: Existem $ativos produtos ATIVOS que deveriam ter preços configurados!');
        print('');
      }
      
      // 9. Verificação de tipos de produto
      print('=== ANÁLISE POR TIPO DE PRODUTO ===');
      final tiposProduto = <String, int>{};
      for (final produto in produtosSemPrecos) {
        final tipo = produto['tipo_produto'] ?? 'SEM_TIPO';
        tiposProduto[tipo] = (tiposProduto[tipo] ?? 0) + 1;
      }
      
      for (final tipo in tiposProduto.keys.toList()..sort()) {
        print('• $tipo: ${tiposProduto[tipo]} produtos');
      }
      print('');
      
      // 10. SQL para inserir preços básicos (baseado no preco_unitario)
      if (ativos > 0) {
        print('=== SUGESTÃO DE SQL PARA CORREÇÃO ===');
        print('-- Para produtos que têm preco_unitario, usar esse valor:');
        
        final produtosComPreco = produtosSemPrecos
            .where((p) => p['ativo'] == true && p['preco'] != null && p['preco'] != 'N/A')
            .toList();
        
        if (produtosComPreco.isNotEmpty) {
          print('-- Primeiro, busque os IDs dos tamanhos:');
          print('SELECT id, nome FROM tamanhos ORDER BY id;');
          print('');
          print('-- Em seguida, para cada produto com preco_unitario, insira:');
          print('-- (Substitua TAMANHO_ID_P, TAMANHO_ID_M, etc. pelos IDs reais)');
          print('');
          
          for (final produto in produtosComPreco) {
            final id = produto['id'];
            final nome = produto['nome'];
            final preco = produto['preco'];
            
            print('-- Produto: $nome (ID: $id)');
            print('INSERT INTO produtos_precos (produto_id, tamanho_id, preco, ativo) VALUES');
            print('($id, TAMANHO_ID_P, $preco, true),');
            print('($id, TAMANHO_ID_M, $preco, true),');
            print('($id, TAMANHO_ID_G, $preco, true),');
            print('($id, TAMANHO_ID_GG, $preco, true);');
            print('');
          }
        }
        
        final produtosSemPreco = produtosSemPrecos
            .where((p) => p['ativo'] == true && (p['preco'] == null || p['preco'] == 'N/A'))
            .toList();
        
        if (produtosSemPreco.isNotEmpty) {
          print('-- Para produtos SEM preco, defina preços manualmente:');
          for (final produto in produtosSemPreco) {
            final id = produto['id'];
            final nome = produto['nome'];
            
            print('-- Produto: $nome (ID: $id) - DEFINIR PREÇOS MANUALMENTE');
            print('INSERT INTO produtos_precos (produto_id, tamanho_id, preco, ativo) VALUES');
            print('($id, TAMANHO_ID_P, 0.00, true),  -- DEFINIR PREÇO');
            print('($id, TAMANHO_ID_M, 0.00, true),  -- DEFINIR PREÇO');
            print('($id, TAMANHO_ID_G, 0.00, true),  -- DEFINIR PREÇO');
            print('($id, TAMANHO_ID_GG, 0.00, true); -- DEFINIR PREÇO');
            print('');
          }
        }
      }
    }
    
    print('============================================================');
    print('                      RESUMO FINAL');
    print('============================================================');
    print('• Total de produtos ativos: ${produtos.length}');
    print('• Produtos com preços configurados: ${produtoIdsComPrecos.length}');
    print('• Produtos SEM preços configurados: ${produtosSemPrecos.length}');
    
    if (produtosSemPrecos.length == 13) {
      print('✅ Confirmado: Exatamente 13 produtos sem preços encontrados!');
    } else if (produtosSemPrecos.length > 13) {
      print('⚠️  Encontrados ${produtosSemPrecos.length} produtos sem preços (mais que os 13 esperados)');
    } else {
      print('⚠️  Encontrados apenas ${produtosSemPrecos.length} produtos sem preços (menos que os 13 esperados)');
    }
    
    final ativosSemPrecos = produtosSemPrecos.where((p) => p['ativo'] == true).length;
    if (ativosSemPrecos > 0) {
      print('🚨 URGENTE: $ativosSemPrecos produtos ATIVOS precisam de preços!');
    } else {
      print('✅ Todos os produtos ATIVOS têm preços configurados.');
    }
    print('============================================================');
    
  } catch (e, stackTrace) {
    print('❌ Erro durante a análise: $e');
    print('Stack trace: $stackTrace');
  }
  
  exit(0);
}