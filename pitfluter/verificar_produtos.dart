import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://ggjoslfubjokzvqunmrp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdnam9zbGZ1YmpvaXp2cXVubXJwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjI4OTcyNzAsImV4cCI6MjAzODQ3MzI3MH0.VjJyMA5OQ6-p_kXWbOmTKMoLqJCEimKrVQxGiwdBdYE',
  );

  final supabase = Supabase.instance.client;

  try {
    // 1. Verificar produtos sem preço
    print('\n=== VERIFICANDO PRODUTOS ===\n');
    
    final produtos = await supabase
        .from('produtos_produto')
        .select('id, nome, preco_unitario, tipo_produto, categoria_id')
        .order('nome');
    
    print('Total de produtos: ${produtos.length}');
    
    // Agrupar por status de preço
    var comPreco = 0;
    var semPreco = 0;
    var produtosSemPreco = [];
    
    for (var produto in produtos) {
      if (produto['preco_unitario'] == null) {
        semPreco++;
        produtosSemPreco.add(produto);
      } else {
        comPreco++;
      }
    }
    
    print('Produtos COM preço: $comPreco');
    print('Produtos SEM preço: $semPreco');
    
    if (produtosSemPreco.isNotEmpty) {
      print('\n--- Produtos sem preço definido ---');
      for (var p in produtosSemPreco) {
        print('- ${p['nome']} (ID: ${p['id']}, Tipo: ${p['tipo_produto']})');
      }
    }
    
    // 2. Verificar categorias
    print('\n\n=== VERIFICANDO CATEGORIAS ===\n');
    
    final categorias = await supabase
        .from('produtos_categoria')
        .select('*')
        .order('nome');
    
    print('Total de categorias: ${categorias.length}');
    print('\nCategorias existentes:');
    for (var cat in categorias) {
      print('- ${cat['nome']} (ID: ${cat['id']}, Ativo: ${cat['ativo']})');
    }
    
    // 3. Verificar relação produtos x categorias
    print('\n\n=== PRODUTOS POR CATEGORIA ===\n');
    
    for (var cat in categorias) {
      final produtosDaCategoria = produtos.where((p) => p['categoria_id'] == cat['id']).toList();
      print('${cat['nome']}: ${produtosDaCategoria.length} produtos');
      if (produtosDaCategoria.isNotEmpty && produtosDaCategoria.length <= 5) {
        for (var p in produtosDaCategoria) {
          print('  - ${p['nome']}');
        }
      }
    }
    
    // 4. Verificar se existe categoria "Sobremesas" sendo usada
    final sobremesas = categorias.firstWhere(
      (c) => c['nome'].toString().toLowerCase().contains('sobremesa'),
      orElse: () => {},
    );
    
    if (sobremesas.isNotEmpty) {
      print('\n\n⚠️  CATEGORIA SOBREMESAS ENCONTRADA');
      print('ID: ${sobremesas['id']}');
      print('Nome: ${sobremesas['nome']}');
      
      final produtosSobremesas = produtos.where((p) => p['categoria_id'] == sobremesas['id']).toList();
      print('Produtos nesta categoria: ${produtosSobremesas.length}');
    }
    
  } catch (e) {
    print('Erro: $e');
  }
  
  print('\n\n=== ANÁLISE CONCLUÍDA ===');
}