// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'dart:io';

void main() {
  print('=== SIMULANDO O PROBLEMA ===\n');
  
  // Simular um produto pizza doce vindo do banco COM preços
  final produtoComPrecos = {
    'id': 1,
    'nome': 'Pizza de Chocolate',
    'tipo_produto': 'pizza',
    'preco_unitario': 35.0,
    'categoria_id': 1,
    'categorias': {'id': 1, 'nome': 'Pizzas'},
    'produtos_precos': [
      {
        'id': 1,
        'preco': 25.0,
        'preco_promocional': 25.0,
        'tamanho_id': 1,
        'produtos_tamanho': {'id': 1, 'nome': 'Broto'}
      },
      {
        'id': 2,
        'preco': 35.0,
        'preco_promocional': 35.0,
        'tamanho_id': 2,
        'produtos_tamanho': {'id': 2, 'nome': 'Média'}
      },
      {
        'id': 3,
        'preco': 45.0,
        'preco_promocional': 45.0,
        'tamanho_id': 3,
        'produtos_tamanho': {'id': 3, 'nome': 'Grande'}
      },
      {
        'id': 4,
        'preco': 55.0,
        'preco_promocional': 55.0,
        'tamanho_id': 4,
        'produtos_tamanho': {'id': 4, 'nome': 'Família'}
      }
    ]
  };
  
  // Simular um produto pizza doce vindo do banco SEM preços
  final produtoSemPrecos = {
    'id': 2,
    'nome': 'Pizza de Brigadeiro',
    'tipo_produto': 'pizza',
    'preco_unitario': 35.0,
    'categoria_id': 1,
    'categorias': {'id': 1, 'nome': 'Pizzas'},
    'produtos_precos': null  // Ou uma lista vazia []
  };
  
  print('1. TESTANDO PRODUTO COM PREÇOS:');
  print('   Nome: ${produtoComPrecos['nome']}');
  
  // Simular _usarPrecosCarregados()
  final produtoPrecos = produtoComPrecos['produtos_precos'];
  print('   produtos_precos existe? ${produtoPrecos != null}');
  print('   produtos_precos é List? ${produtoPrecos is List}');
  
  if (produtoPrecos != null && produtoPrecos is List) {
    print('   ✅ Preços seriam carregados: ${produtoPrecos.length} itens');
    
    // Simular mapeamento
    final Map<String, dynamic> precosPorTamanho = {};
    for (var preco in produtoPrecos) {
      final tamanho = preco['produtos_tamanho']?['nome'];
      if (tamanho != null) {
        precosPorTamanho[tamanho] = preco['preco'];
      }
    }
    
    print('   Mapeamento:');
    print('     P (Broto): R\$ ${precosPorTamanho['Broto'] ?? 'N/A'}');
    print('     M (Média): R\$ ${precosPorTamanho['Média'] ?? 'N/A'}');
    print('     G (Grande): R\$ ${precosPorTamanho['Grande'] ?? 'N/A'}');
    print('     GG (Família): R\$ ${precosPorTamanho['Família'] ?? 'N/A'}');
  } else {
    print('   ❌ Preços NÃO seriam carregados!');
  }
  
  print('\n2. TESTANDO PRODUTO SEM PREÇOS:');
  print('   Nome: ${produtoSemPrecos['nome']}');
  
  final produtoPrecos2 = produtoSemPrecos['produtos_precos'];
  print('   produtos_precos existe? ${produtoPrecos2 != null}');
  print('   produtos_precos é List? ${produtoPrecos2 is List}');
  
  if (produtoPrecos2 != null && produtoPrecos2 is List) {
    print('   ✅ Preços seriam carregados: ${produtoPrecos2.length} itens');
  } else {
    print('   ❌ Preços NÃO seriam carregados!');
  }
  
  print('\n3. POSSÍVEIS CAUSAS DO PROBLEMA:');
  print('   - A consulta SQL não está incluindo produtos_precos');
  print('   - O campo produtos_precos está vindo null ou vazio');
  print('   - O _ProdutoCard está sendo criado antes dos dados chegarem');
  print('   - Há algum filtro removendo os preços');
  
  exit(0);
}