// ignore_for_file: avoid_print, unused_import
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lhvfacztsbflrtfibeek.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );

  print('============================================================');
  print('      ANÁLISE COMPLEMENTAR DOS PREÇOS');
  print('============================================================\n');

  try {
    // 1. Buscar todos os tamanhos disponíveis
    print('=== TAMANHOS DISPONÍVEIS ===');
    final tamanhos = await supabase.from('tamanhos').select('*').order('id');

    final tamanhosMap = <int, String>{};
    for (final tamanho in tamanhos) {
      tamanhosMap[tamanho['id']] = tamanho['nome'];
      print('ID ${tamanho['id']}: ${tamanho['nome']}');
    }
    print('');

    // 2. Buscar produtos que TÊM preços
    print('=== PRODUTOS COM PREÇOS CONFIGURADOS ===');
    final produtosPrecos = await supabase
        .from('produtos_precos')
        .select('produto_id, tamanho_id, preco, ativo')
        .order('produto_id, tamanho_id');

    final produtos = await supabase
        .from('produtos')
        .select('id, nome, tipo_produto, categoria_id')
        .order('id');

    final produtosMap = <int, Map<String, dynamic>>{};
    for (final produto in produtos) {
      produtosMap[produto['id']] = produto;
    }

    // Agrupar preços por produto
    final precosPorProduto = <int, List<Map<String, dynamic>>>{};
    for (final preco in produtosPrecos) {
      final produtoId = preco['produto_id'] as int;
      precosPorProduto.putIfAbsent(produtoId, () => []).add(preco);
    }

    print('Produtos com preços configurados:');
    for (final produtoId in precosPorProduto.keys.toList()..sort()) {
      final produto = produtosMap[produtoId];
      final precos = precosPorProduto[produtoId]!;

      print(
          '\nID $produtoId: ${produto?['nome'] ?? 'N/A'} (${produto?['tipo_produto'] ?? 'N/A'})');
      for (final preco in precos) {
        final tamanhoId = preco['tamanho_id'] as int;
        final tamanhoNome = tamanhosMap[tamanhoId] ?? 'N/A';
        final precoValor = preco['preco'];
        final ativo = preco['ativo'];
        print(
            '  - Tamanho $tamanhoNome: R\$ $precoValor ${ativo ? '(ATIVO)' : '(INATIVO)'}');
      }
    }

    // 3. Verificar categorias completas
    print('\n=== ANÁLISE POR CATEGORIA ===');
    final categorias =
        await supabase.from('categorias').select('*').order('id');

    for (final categoria in categorias) {
      final categoriaId = categoria['id'] as int;
      final categoriaNome = categoria['nome'] as String;

      final produtosDaCategoria =
          produtos.where((p) => p['categoria_id'] == categoriaId).toList();
      final produtosComPreco = produtosDaCategoria
          .where((p) => precosPorProduto.containsKey(p['id']))
          .length;
      final produtosSemPreco = produtosDaCategoria.length - produtosComPreco;

      print('\n📂 $categoriaNome (ID: $categoriaId)');
      print('   Total de produtos: ${produtosDaCategoria.length}');
      print('   Com preços: $produtosComPreco');
      print('   Sem preços: $produtosSemPreco');

      if (produtosSemPreco > 0) {
        print('   Produtos sem preços:');
        for (final produto in produtosDaCategoria) {
          if (!precosPorProduto.containsKey(produto['id'])) {
            print('     - ID ${produto['id']}: ${produto['nome']}');
          }
        }
      }
    }

    // 4. Estatísticas finais
    print('\n=== ESTATÍSTICAS FINAIS ===');
    print('• Total de tamanhos cadastrados: ${tamanhos.length}');
    print(
        '• Total de produtos ativos: ${produtos.where((p) => p['ativo'] == true).length}');
    print('• Total de produtos: ${produtos.length}');
    print('• Produtos com preços: ${precosPorProduto.keys.length}');
    print(
        '• Produtos sem preços: ${produtos.length - precosPorProduto.keys.length}');
    print('• Total de registros de preços: ${produtosPrecos.length}');

    // Calcular teoria vs realidade
    final produtosComPrecosCount = precosPorProduto.keys.length;
    final tamanhosCount = tamanhos.length;
    final teoricoMaximo = produtosComPrecosCount * tamanhosCount;
    print(
        '• Teórico máximo ($produtosComPrecosCount produtos × $tamanhosCount} tamanhos): $teoricoMaximo');
    print(
        '• Percentual de completude: ${(produtosPrecos.length / teoricoMaximo * 100).toStringAsFixed(1)}%');
  } catch (e, stackTrace) {
    print('❌ Erro durante a análise: $e');
    print('Stack trace: $stackTrace');
  }

  exit(0);
}
