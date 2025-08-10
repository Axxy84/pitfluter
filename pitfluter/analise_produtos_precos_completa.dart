// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lhvfacztsbflrtfibeek.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );
  
  print('============================================================');
  print('      ANÁLISE DETALHADA DA TABELA PRODUTOS_PRECOS');
  print('============================================================\n');
  
  try {
    // 1. Total de registros em produtos_precos
    print('=== ANÁLISE 1: TOTAL DE REGISTROS ===');
    final produtosPrecos = await supabase
        .from('produtos_precos')
        .select('*');
    
    print('Total de registros em produtos_precos: ${produtosPrecos.length}\n');
    
    // 2. Produtos únicos em produtos_precos
    print('=== ANÁLISE 2: PRODUTOS ÚNICOS ===');
    final produtosUnicos = <int>{};
    for (final preco in produtosPrecos) {
      if (preco['produto_id'] != null) {
        produtosUnicos.add(preco['produto_id'] as int);
      }
    }
    print('Produtos únicos em produtos_precos: ${produtosUnicos.length}\n');
    
    // 3. Tamanhos únicos em produtos_precos
    print('=== ANÁLISE 3: TAMANHOS ÚNICOS ===');
    final tamanhosUnicos = <int>{};
    for (final preco in produtosPrecos) {
      if (preco['tamanho_id'] != null) {
        tamanhosUnicos.add(preco['tamanho_id'] as int);
      }
    }
    print('Tamanhos únicos em produtos_precos: ${tamanhosUnicos.length}\n');
    
    // 4. Buscar informações dos tamanhos
    print('=== ANÁLISE 4: DETALHES DOS TAMANHOS ===');
    final tamanhos = await supabase
        .from('tamanhos')
        .select('*')
        .order('id');
        
    print('Tamanhos cadastrados na tabela tamanhos: ${tamanhos.length}');
    for (final tamanho in tamanhos) {
      final tamId = tamanho['id'] as int;
      final count = produtosPrecos.where((p) => p['tamanho_id'] == tamId).length;
      print('  - ID ${tamId}: ${tamanho['nome']} (usado em $count preços)');
    }
    print('');
    
    // 5. Sample de registros
    print('=== ANÁLISE 5: SAMPLE DE REGISTROS (primeiros 10) ===');
    final produtos = await supabase
        .from('produtos')
        .select('id, nome, tipo_produto');
        
    final produtosMap = <int, Map<String, dynamic>>{};
    for (final produto in produtos) {
      produtosMap[produto['id']] = produto;
    }
    
    final tamanhosMap = <int, Map<String, dynamic>>{};
    for (final tamanho in tamanhos) {
      tamanhosMap[tamanho['id']] = tamanho;
    }
    
    print('ID | Produto ID | Produto Nome | Tamanho ID | Tamanho Nome | Preço');
    print('---|------------|--------------|------------|--------------|-------');
    
    for (int i = 0; i < 10 && i < produtosPrecos.length; i++) {
      final preco = produtosPrecos[i];
      final produtoId = preco['produto_id'];
      final tamanhoId = preco['tamanho_id'];
      final produtoNome = produtosMap[produtoId]?['nome'] ?? 'N/A';
      final tamanhoNome = tamanhosMap[tamanhoId]?['nome'] ?? 'N/A';
      
      print('${preco['id']?.toString().padLeft(2)} | ${produtoId?.toString().padLeft(10)} | ${produtoNome.toString().padRight(12)} | ${tamanhoId?.toString().padLeft(10)} | ${tamanhoNome.toString().padRight(12)} | ${preco['preco']}');
    }
    print('');
    
    // 6. Verificação de duplicatas
    print('=== ANÁLISE 6: VERIFICAÇÃO DE DUPLICATAS ===');
    final combinacoes = <String, int>{};
    for (final preco in produtosPrecos) {
      final key = '${preco['produto_id']}-${preco['tamanho_id']}';
      combinacoes[key] = (combinacoes[key] ?? 0) + 1;
    }
    
    final duplicatas = combinacoes.entries.where((entry) => entry.value > 1).toList();
    if (duplicatas.isEmpty) {
      print('✅ Nenhuma duplicata encontrada!');
    } else {
      print('❌ Duplicatas encontradas:');
      for (final dup in duplicatas) {
        final parts = dup.key.split('-');
        final produtoId = int.parse(parts[0]);
        final tamanhoId = int.parse(parts[1]);
        final produtoNome = produtosMap[produtoId]?['nome'] ?? 'N/A';
        final tamanhoNome = tamanhosMap[tamanhoId]?['nome'] ?? 'N/A';
        print('  - Produto: $produtoNome (ID: $produtoId) + Tamanho: $tamanhoNome (ID: $tamanhoId) = ${dup.value} registros');
      }
    }
    print('');
    
    // 7. Produtos com mais/menos tamanhos
    print('=== ANÁLISE 7: PRODUTOS COM MAIS/MENOS TAMANHOS ===');
    final produtoTamanhos = <int, Set<int>>{};
    for (final preco in produtosPrecos) {
      final produtoId = preco['produto_id'] as int;
      final tamanhoId = preco['tamanho_id'] as int;
      produtoTamanhos.putIfAbsent(produtoId, () => <int>{}).add(tamanhoId);
    }
    
    final produtoTamanhosLista = produtoTamanhos.entries.map((entry) {
      final produtoId = entry.key;
      final tamanhosSet = entry.value;
      final produtoNome = produtosMap[produtoId]?['nome'] ?? 'N/A';
      final tipoProduto = produtosMap[produtoId]?['tipo_produto'] ?? 'N/A';
      return {
        'id': produtoId,
        'nome': produtoNome,
        'tipo': tipoProduto,
        'qtd_tamanhos': tamanhosSet.length,
        'tamanhos': tamanhosSet.map((id) => tamanhosMap[id]?['nome'] ?? 'N/A').join(', ')
      };
    }).toList();
    
    produtoTamanhosLista.sort((a, b) => (b['qtd_tamanhos'] as int).compareTo(a['qtd_tamanhos'] as int));
    
    print('Top 20 produtos por quantidade de tamanhos:');
    print('ID | Nome | Tipo | Qtd Tamanhos | Tamanhos');
    print('---|------|------|--------------|----------');
    
    for (int i = 0; i < 20 && i < produtoTamanhosLista.length; i++) {
      final item = produtoTamanhosLista[i];
      print('${item['id']?.toString().padLeft(2)} | ${item['nome'].toString().substring(0, item['nome'].toString().length > 20 ? 20 : item['nome'].toString().length).padRight(20)} | ${item['tipo'].toString().padRight(6)} | ${item['qtd_tamanhos']?.toString().padLeft(12)} | ${item['tamanhos']}');
    }
    print('');
    
    // 8. Produtos sem preços configurados
    print('=== ANÁLISE 8: PRODUTOS SEM PREÇOS CONFIGURADOS ===');
    final produtosSemPreco = <Map<String, dynamic>>[];
    for (final produto in produtos) {
      final produtoId = produto['id'] as int;
      final temPreco = produtosPrecos.any((p) => p['produto_id'] == produtoId);
      if (!temPreco) {
        produtosSemPreco.add(produto);
      }
    }
    
    print('Produtos sem nenhum preço configurado: ${produtosSemPreco.length}');
    if (produtosSemPreco.isNotEmpty) {
      for (final produto in produtosSemPreco.take(10)) {
        print('  - ID ${produto['id']}: ${produto['nome']} (${produto['tipo_produto']})');
      }
      if (produtosSemPreco.length > 10) {
        print('  ... e mais ${produtosSemPreco.length - 10} produtos');
      }
    }
    print('');
    
    // 9. Comparação: produtos vs produtos_precos
    print('=== ANÁLISE 9: COMPARAÇÃO PRODUTOS vs PRODUTOS_PRECOS ===');
    final produtosAtivos = produtos.where((p) => p['ativo'] == true).length;
    print('Total de produtos ativos: $produtosAtivos');
    print('Total de produtos em produtos_precos: ${produtosUnicos.length}');
    print('Produtos que NÃO estão em produtos_precos: ${produtosSemPreco.length}');
    print('Total de tamanhos cadastrados: ${tamanhos.length}');
    print('Total de tamanhos usados em produtos_precos: ${tamanhosUnicos.length}');
    print('');
    
    // 10. Cálculo teórico vs real
    print('=== ANÁLISE 10: CÁLCULO TEÓRICO vs REAL ===');
    final produtosComPreco = produtosUnicos.length;
    final tamanhosUsados = tamanhosUnicos.length;
    final teoricoMaximo = produtosComPreco * tamanhosUsados;
    final realAtual = produtosPrecos.length;
    final diferenca = realAtual - teoricoMaximo;
    final percentualPreenchimento = (realAtual / teoricoMaximo * 100).toStringAsFixed(2);
    
    print('Produtos com preço: $produtosComPreco');
    print('Tamanhos usados: $tamanhosUsados');
    print('Teórico máximo (produtos × tamanhos): $teoricoMaximo');
    print('Real atual: $realAtual');
    print('Diferença: $diferenca');
    print('Percentual de preenchimento: $percentualPreenchimento%');
    print('');
    
    // 11. Produtos por tipo com contagem de preços
    print('=== ANÁLISE 11: PRODUTOS POR TIPO COM PREÇOS ===');
    final tiposProduto = <String, Map<String, int>>{};
    
    for (final produto in produtos) {
      if (produto['ativo'] == true) {
        final tipo = produto['tipo_produto']?.toString() ?? 'SEM_TIPO';
        final produtoId = produto['id'] as int;
        final qtdPrecos = produtosPrecos.where((p) => p['produto_id'] == produtoId).length;
        
        if (!tiposProduto.containsKey(tipo)) {
          tiposProduto[tipo] = {'qtd_produtos': 0, 'qtd_precos': 0};
        }
        
        tiposProduto[tipo]!['qtd_produtos'] = tiposProduto[tipo]!['qtd_produtos']! + 1;
        tiposProduto[tipo]!['qtd_precos'] = tiposProduto[tipo]!['qtd_precos']! + qtdPrecos;
      }
    }
    
    print('Tipo | Qtd Produtos | Qtd Preços | Média Preços/Produto');
    print('-----|--------------|------------|---------------------');
    
    final tiposOrdenados = tiposProduto.entries.toList();
    tiposOrdenados.sort((a, b) => b.value['qtd_precos']!.compareTo(a.value['qtd_precos']!));
    
    for (final entry in tiposOrdenados) {
      final tipo = entry.key;
      final dados = entry.value;
      final media = dados['qtd_produtos']! > 0 
          ? (dados['qtd_precos']! / dados['qtd_produtos']!).toStringAsFixed(2)
          : '0.00';
      print('${tipo.padRight(5)} | ${dados['qtd_produtos']?.toString().padLeft(12)} | ${dados['qtd_precos']?.toString().padLeft(10)} | ${media.padLeft(19)}');
    }
    print('');
    
    // 12. Distribuição de preços por faixa
    print('=== ANÁLISE 12: DISTRIBUIÇÃO DE PREÇOS POR FAIXA ===');
    final faixas = <String, List<double>>{
      '0-10': [],
      '10-20': [],
      '20-30': [],
      '30-40': [],
      '40-50': [],
      '50+': []
    };
    
    for (final preco in produtosPrecos) {
      final valor = (preco['preco'] as num?)?.toDouble() ?? 0.0;
      
      if (valor < 10) {
        faixas['0-10']!.add(valor);
      } else if (valor < 20) {
        faixas['10-20']!.add(valor);
      } else if (valor < 30) {
        faixas['20-30']!.add(valor);
      } else if (valor < 40) {
        faixas['30-40']!.add(valor);
      } else if (valor < 50) {
        faixas['40-50']!.add(valor);
      } else {
        faixas['50+']!.add(valor);
      }
    }
    
    print('Faixa  | Quantidade | Preço Médio');
    print('-------|------------|-------------');
    
    for (final entry in faixas.entries) {
      final faixa = entry.key;
      final valores = entry.value;
      final quantidade = valores.length;
      final media = quantidade > 0 
          ? (valores.reduce((a, b) => a + b) / quantidade).toStringAsFixed(2)
          : '0.00';
      print('${faixa.padRight(6)} | ${quantidade.toString().padLeft(10)} | ${media.padLeft(11)}');
    }
    
    print('\n============================================================');
    print('                      RESUMO FINAL');
    print('============================================================');
    print('• Total de registros em produtos_precos: ${produtosPrecos.length}');
    print('• Produtos únicos com preços: ${produtosUnicos.length}');
    print('• Tamanhos únicos utilizados: ${tamanhosUnicos.length}');
    print('• Produtos sem preços: ${produtosSemPreco.length}');
    print('• Duplicatas encontradas: ${duplicatas.length}');
    print('• Relação teórica: ${produtosUnicos.length} × ${tamanhosUnicos.length} = $teoricoMaximo');
    print('• Diferença real vs teórico: $diferenca');
    print('• Percentual de preenchimento: $percentualPreenchimento%');
    print('============================================================');
    
    // Explicação do porque temos 524 registros
    print('\n🔍 EXPLICAÇÃO DOS 524 REGISTROS:');
    if (duplicatas.isEmpty && diferenca == 0) {
      print('✅ Os 524 registros são exatamente o resultado de:');
      print('   ${produtosUnicos.length} produtos únicos × ${tamanhosUnicos.length} tamanhos = $teoricoMaximo registros');
      print('   Cada produto ativo tem um preço para cada tamanho disponível.');
    } else if (diferenca > 0) {
      print('⚠️  Temos MAIS registros que o esperado:');
      print('   Esperado: ${produtosUnicos.length} × ${tamanhosUnicos.length} = $teoricoMaximo');
      print('   Real: $realAtual');
      print('   Diferença: +$diferenca registros extras');
      if (duplicatas.isNotEmpty) {
        print('   Isso pode ser devido às ${duplicatas.length} duplicatas encontradas.');
      }
    } else {
      print('⚠️  Temos MENOS registros que o esperado:');
      print('   Esperado: ${produtosUnicos.length} × ${tamanhosUnicos.length} = $teoricoMaximo');
      print('   Real: $realAtual');
      print('   Diferença: $diferenca registros faltando');
      print('   Alguns produtos podem não ter preços para todos os tamanhos.');
    }
    
  } catch (e, stackTrace) {
    print('❌ Erro durante a análise: $e');
    print('Stack trace: $stackTrace');
  }
  
  exit(0);
}