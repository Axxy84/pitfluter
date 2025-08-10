// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://lhvfacztsbflrtfibeek.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );

  final supabase = Supabase.instance.client;

  try {
    print('🔍 Testando consulta de produtos...\n');

    // 1. Carregar categorias
    final categoriasResponse = await supabase
        .from('categorias')
        .select('*')
        .eq('ativo', true)
        .order('nome');
    
    print('✅ Categorias carregadas: ${categoriasResponse.length}');
    for (final cat in categoriasResponse) {
      print('   - ${cat['nome']} (ID: ${cat['id']})');
    }

    // 2. Carregar produtos com preços e categorias
    print('\n🔍 Buscando produtos...');
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

    print('✅ Produtos carregados: ${produtosResponse.length}');
    
    // Mostrar alguns produtos como exemplo
    for (final produto in produtosResponse.take(5)) {
      print('\n📦 ${produto['nome']}');
      print('   Categoria: ${produto['categorias']?['nome'] ?? 'N/A'}');
      print('   Ativo: ${produto['ativo']}');
      
      final precos = produto['produtos_precos'] as List?;
      if (precos != null && precos.isNotEmpty) {
        print('   Preços:');
        for (final preco in precos) {
          String tamanho = '';
          if (preco['tamanho_id'] == 1) tamanho = 'P';
          else if (preco['tamanho_id'] == 2) tamanho = 'M';
          else if (preco['tamanho_id'] == 3) tamanho = 'G';
          else if (preco['tamanho_id'] == 4) tamanho = 'F';
          
          final valor = preco['preco_promocional'] ?? preco['preco'];
          print('     $tamanho: R\$ ${valor.toStringAsFixed(2)}');
        }
      } else {
        print('   Preços: Não disponível');
      }
    }

    // 3. Verificar problema específico com produtos não aparecendo
    print('\n🔍 Verificando produtos ativos...');
    final produtosAtivos = produtosResponse.where((p) => p['ativo'] == true).toList();
    print('Total de produtos ativos: ${produtosAtivos.length}');
    
    // Verificar produtos por categoria
    print('\n📊 Produtos por categoria:');
    final Map<String, int> produtosPorCategoria = {};
    for (final produto in produtosResponse) {
      final categoriaNome = produto['categorias']?['nome'] ?? 'Sem categoria';
      produtosPorCategoria[categoriaNome] = (produtosPorCategoria[categoriaNome] ?? 0) + 1;
    }
    
    produtosPorCategoria.forEach((categoria, count) {
      print('   $categoria: $count produtos');
    });

  } catch (e) {
    print('❌ Erro ao buscar dados: $e');
  }
}