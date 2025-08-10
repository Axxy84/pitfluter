// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://dcdcgzdjlkbbqkcdpxwa.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRjZGNnemRqbGtiYnFrY2RweHdhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgxNzgxNDcsImV4cCI6MjA0Mzc1NDE0N30.8CglvLj0cs4Fls-K5JCvP4-JkGJ5sv79dOnYfAcY7rs',
  );

  final supabase = Supabase.instance.client;
  
  print('\n${'=' * 80}');
  print('🔍 VERIFICAÇÃO DE TAMANHOS E PREÇOS NO SUPABASE');
  print('=' * 80);
  
  try {
    // 1. Verificar tabela produtos_tamanho
    print('\n📊 Verificando tabela "produtos_tamanho":');
    print('-' * 60);
    
    try {
      final tamanhosProdutos = await supabase
          .from('produtos_tamanho')
          .select('*')
          .order('id');
      
      if (tamanhosProdutos.isNotEmpty) {
        print('✅ Encontrados ${tamanhosProdutos.length} tamanhos em produtos_tamanho:');
        for (var t in tamanhosProdutos) {
          print('  • ID ${t['id']}: ${t['nome']}');
        }
      } else {
        print('⚠️ Nenhum tamanho encontrado em produtos_tamanho');
      }
    } catch (e) {
      print('❌ Erro ao acessar produtos_tamanho: $e');
    }
    
    // 2. Verificar tabela tamanhos
    print('\n📊 Verificando tabela "tamanhos":');
    print('-' * 60);
    
    try {
      final tamanhos = await supabase
          .from('tamanhos')
          .select('*')
          .order('id');
      
      if (tamanhos.isNotEmpty) {
        print('✅ Encontrados ${tamanhos.length} tamanhos em tamanhos:');
        for (var t in tamanhos) {
          print('  • ID ${t['id']}: ${t['nome']}');
        }
      } else {
        print('⚠️ Nenhum tamanho encontrado em tamanhos');
      }
    } catch (e) {
      print('❌ Erro ao acessar tamanhos: $e');
    }
    
    // 3. Verificar produtos tipo pizza
    print('\n🍕 Verificando produtos do tipo pizza:');
    print('-' * 60);
    
    final pizzas = await supabase
        .from('produtos')
        .select('id, nome, tipo_produto, preco_unitario')
        .or('tipo_produto.eq.pizza,nome.ilike.%pizza%')
        .limit(5);
    
    if (pizzas.isNotEmpty) {
      print('✅ Encontradas ${pizzas.length} pizzas (mostrando até 5):');
      for (var p in pizzas) {
        print('  • ${p['nome']} (ID: ${p['id']}, Tipo: ${p['tipo_produto'] ?? 'N/A'})');
      }
      
      // 4. Verificar preços por tamanho para a primeira pizza
      final pizzaId = pizzas[0]['id'];
      final pizzaNome = pizzas[0]['nome'];
      
      print('\n💰 Verificando preços por tamanho para: $pizzaNome (ID: $pizzaId)');
      print('-' * 60);
      
      // Tentar com produtos_tamanho
      try {
        final precosProdutosTamanho = await supabase
            .from('produtos_precos')
            .select('*, produtos_tamanho(id, nome)')
            .eq('produto_id', pizzaId);
        
        if (precosProdutosTamanho.isNotEmpty) {
          print('✅ Preços encontrados (usando produtos_tamanho):');
          for (var preco in precosProdutosTamanho) {
            final tamanho = preco['produtos_tamanho'];
            final tamanhoNome = tamanho != null ? tamanho['nome'] : 'Sem tamanho';
            print('  • Tamanho $tamanhoNome: R\$ ${preco['preco']}');
          }
        } else {
          print('⚠️ Nenhum preço encontrado com produtos_tamanho');
        }
      } catch (e) {
        print('❌ Erro ao buscar com produtos_tamanho: $e');
      }
      
      // Tentar com tamanhos
      try {
        final precosTamanhos = await supabase
            .from('produtos_precos')
            .select('*, tamanhos(id, nome)')
            .eq('produto_id', pizzaId);
        
        if (precosTamanhos.isNotEmpty) {
          print('✅ Preços encontrados (usando tamanhos):');
          for (var preco in precosTamanhos) {
            final tamanho = preco['tamanhos'];
            final tamanhoNome = tamanho != null ? tamanho['nome'] : 'Sem tamanho';
            print('  • Tamanho $tamanhoNome: R\$ ${preco['preco']}');
          }
        } else {
          print('⚠️ Nenhum preço encontrado com tamanhos');
        }
      } catch (e) {
        print('❌ Erro ao buscar com tamanhos: $e');
      }
    } else {
      print('⚠️ Nenhuma pizza encontrada');
    }
    
    // 5. Verificar qual nome de tabela funciona
    print('\n🔍 TESTE DE ACESSO ÀS TABELAS:');
    print('-' * 60);
    
    // Teste 1: produtos_tamanho existe?
    try {
      await supabase.from('produtos_tamanho').select('id').limit(1);
      print('✅ Tabela "produtos_tamanho" EXISTE e está acessível');
    } catch (e) {
      print('❌ Tabela "produtos_tamanho" NÃO existe ou erro: ${e.toString().split('\n')[0]}');
    }
    
    // Teste 2: tamanhos existe?
    try {
      await supabase.from('tamanhos').select('id').limit(1);
      print('✅ Tabela "tamanhos" EXISTE e está acessível');
    } catch (e) {
      print('❌ Tabela "tamanhos" NÃO existe ou erro: ${e.toString().split('\n')[0]}');
    }
    
    // 6. Contar registros
    print('\n📊 ESTATÍSTICAS:');
    print('-' * 60);
    
    // Total de produtos
    final totalProdutos = await supabase
        .from('produtos')
        .select('id');
    print('  • Total de produtos: ${totalProdutos.length}');
    
    // Total de preços
    final totalPrecos = await supabase
        .from('produtos_precos')
        .select('id');
    print('  • Total de registros de preços: ${totalPrecos.length}');
    
    print('\n${'=' * 80}');
    print('✅ VERIFICAÇÃO CONCLUÍDA');
    print('=' * 80);
    
    print('\n💡 DIAGNÓSTICO:');
    print('-' * 60);
    print('Com base na verificação, o código Flutter deve usar:');
    print('1. O nome correto da tabela de tamanhos que existe no banco');
    print('2. Verificar se existem registros de preços associados aos tamanhos');
    print('3. Ajustar os nomes das tabelas no código se necessário');
    
  } catch (e) {
    print('\n❌ Erro geral: $e');
  }
}