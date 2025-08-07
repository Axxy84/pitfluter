import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://ggjoslfubjokzvqunmrp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdnam9zbGZ1YmpvaXp2cXVubXJwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjI4OTcyNzAsImV4cCI6MjAzODQ3MzI3MH0.VjJyMA5OQ6-p_kXWbOmTKMoLqJCEimKrVQxGiwdBdYE',
  );

  final supabase = Supabase.instance.client;

  try {
    // 1. Verificar produtos
    print('\n=== PRODUTOS ===');
    final produtos = await supabase
        .from('produtos_produto')
        .select('*')
        .limit(10);
    
    for (var p in produtos) {
      print('${p['nome']}: R\$ ${p['preco_unitario'] ?? "SEM PREÇO"}');
    }
    
    // 2. Verificar categorias
    print('\n=== CATEGORIAS ===');
    final categorias = await supabase
        .from('produtos_categoria')
        .select('*');
    
    for (var c in categorias) {
      print('${c['id']}: ${c['nome']}');
    }
    
    // 3. Sugerir preços exemplo
    print('\n=== SUGESTÃO DE UPDATE ===');
    print('Para adicionar preços, execute no Supabase SQL Editor:');
    print('''
-- Pizzas Tradicionais
UPDATE produtos_produto 
SET preco_unitario = 45.00 
WHERE tipo_produto = 'pizza' AND categoria_id IN (SELECT id FROM produtos_categoria WHERE nome LIKE '%Tradicional%');

-- Pizzas Promocionais
UPDATE produtos_produto 
SET preco_unitario = 35.00 
WHERE tipo_produto = 'pizza' AND categoria_id IN (SELECT id FROM produtos_categoria WHERE nome LIKE '%Promocional%');

-- Bordas
UPDATE produtos_produto 
SET preco_unitario = 15.00 
WHERE tipo_produto = 'borda';

-- Bebidas
UPDATE produtos_produto 
SET preco_unitario = 8.00 
WHERE tipo_produto IN ('bebida', 'refrigerante', 'suco');

-- Sobremesas
UPDATE produtos_produto 
SET preco_unitario = 12.00 
WHERE categoria_id IN (SELECT id FROM produtos_categoria WHERE nome LIKE '%Sobremesa%');
    ''');
    
  } catch (e) {
    print('Erro: $e');
  }
  
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(child: Text('Verificação concluída - veja o console')),
    ),
  ));
}