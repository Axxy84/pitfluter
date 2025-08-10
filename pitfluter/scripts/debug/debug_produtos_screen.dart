// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://lhvfacztsbflrtfibeek.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );
  
  print('=== DEBUG PRODUTOS SCREEN ===\n');
  
  try {
    // 1. Simular _loadData() - Carregar categorias
    print('PASSO 1: Carregando categorias...');
    final todasCategoriasResponse = await supabase
        .from('categorias')
        .select('*')
        .order('nome');
    
    print('Categorias encontradas: ${todasCategoriasResponse.length}');
    for (var cat in todasCategoriasResponse) {
      print('  - ${cat['nome']} (ID: ${cat['id']})');
    }
    
    // 2. Simular _loadProdutos() - COM A CONSULTA CORRETA
    print('\nPASSO 2: Carregando produtos COM PREÇOS (JOIN)...');
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
    
    print('Produtos carregados: ${produtosResponse.length}');
    
    // 3. Verificar estrutura dos dados das pizzas doces
    print('\nPASSO 3: Analisando estrutura das pizzas doces...\n');
    
    for (var produto in produtosResponse) {
      final nomeProduto = produto['nome']?.toString().toLowerCase() ?? '';
      if (nomeProduto.contains('chocolate') || nomeProduto.contains('doce')) {
        print('📦 ${produto['nome']}');
        print('  Estrutura do produto:');
        print('    - id: ${produto['id']}');
        print('    - tipo_produto: ${produto['tipo_produto']}');
        print('    - preco_unitario: ${produto['preco_unitario']}');
        print('    - categoria_id: ${produto['categoria_id']}');
        print('    - categorias: ${produto['categorias']}');
        
        final precos = produto['produtos_precos'];
        print('    - produtos_precos: ${precos?.runtimeType}');
        
        if (precos == null) {
          print('      ❌ produtos_precos é NULL!');
        } else if (precos is! List) {
          print('      ❌ produtos_precos NÃO é uma Lista! É: ${precos.runtimeType}');
        } else if (precos.isEmpty) {
          print('      ⚠️ produtos_precos está VAZIO!');
        } else {
          print('      ✅ produtos_precos tem ${precos.length} itens');
          
          // Simular o que _ProdutoCard faz
          print('\n  SIMULANDO _ProdutoCard._usarPrecosCarregados():');
          final produtoPrecos = produto['produtos_precos'];
          
          if (produtoPrecos != null && produtoPrecos is List) {
            print('    ✅ Preços seriam carregados no card!');
            for (var preco in produtoPrecos) {
              final tamanho = preco['produtos_tamanho']?['nome'] ?? 'N/A';
              print('      - $tamanho: R\$ ${preco['preco']}');
            }
          } else {
            print('    ❌ Preços NÃO seriam carregados no card!');
          }
        }
        
        print('');
        break; // Analisar apenas uma pizza doce
      }
    }
    
    // 4. Testar filtro por categoria
    print('PASSO 4: Testando filtro por categoria "Pizzas"...');
    final pizzas = produtosResponse.where((produto) {
      final categoria = produto['categorias'];
      return categoria != null && categoria['id'] == 1;
    }).toList();
    
    print('Produtos na categoria Pizzas: ${pizzas.length}');
    for (var pizza in pizzas) {
      final precos = pizza['produtos_precos'] as List?;
      print('  - ${pizza['nome']}: ${precos?.length ?? 0} preços');
    }
    
  } catch (e, stackTrace) {
    print('❌ ERRO: $e');
    print('Stack trace: $stackTrace');
  }
  
  exit(0);
}