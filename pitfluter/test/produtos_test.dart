// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://lhvfacztsbflrtfibeek.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
    );
  });

  test('Verificar carregamento de produtos', () async {
    final supabase = Supabase.instance.client;

    // Testar query de produtos
    final produtosResponse = await supabase.from('produtos').select('''
          *,
          produtos_precos (
            preco,
            preco_promocional,
            tamanho_id
          ),
          categorias (
            id,
            nome
          )
        ''').order('nome');

    expect(produtosResponse, isNotEmpty);
    print('✅ Produtos carregados: ${produtosResponse.length}');
    
    // Verificar estrutura dos produtos
    for (final produto in produtosResponse.take(3)) {
      expect(produto['nome'], isNotNull);
      expect(produto['ativo'], isNotNull);
      
      print('📦 ${produto['nome']}');
      print('   Categoria: ${produto['categorias']?['nome']}');
      print('   Preços: ${produto['produtos_precos']}');
    }
  });

  test('Verificar carregamento de categorias', () async {
    final supabase = Supabase.instance.client;

    final categoriasResponse = await supabase
        .from('categorias')
        .select('*')
        .eq('ativo', true)
        .order('nome');

    expect(categoriasResponse, isNotEmpty);
    print('✅ Categorias carregadas: ${categoriasResponse.length}');
  });
}