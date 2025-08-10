// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('\n==================================================');
  print('     TESTE DE CRIAÇÃO DE PIZZAS DOCES');
  print('==================================================\n');
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://dcdcgzdjlkbbqkcdpxwa.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRjZGNnemRqbGtiYnFrY2RweHdhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgxNzgxNDcsImV4cCI6MjA0Mzc1NDE0N30.8CglvLj0cs4Fls-K5JCvP4-JkGJ5sv79dOnYfAcY7rs',
  );

  final supabase = Supabase.instance.client;
  
  try {
    print('1. Verificando pizzas doces existentes...\n');
    
    final pizzasExistentes = await supabase
        .from('produtos')
        .select('id, nome, tipo_produto')
        .or('nome.ilike.%doce%,nome.ilike.%chocolate%,nome.ilike.%brigadeiro%');
    
    if (pizzasExistentes.isEmpty) {
      print('   ❌ Nenhuma pizza doce encontrada no banco!\n');
    } else {
      print('   ✅ ${pizzasExistentes.length} pizzas doces encontradas:\n');
      for (var pizza in pizzasExistentes) {
        print('      • ${pizza['nome']} (ID: ${pizza['id']})');
        
        // Verificar preços
        final precos = await supabase
            .from('produtos_precos')
            .select('preco, produtos_tamanho(nome)')
            .eq('produto_id', pizza['id']);
        
        if (precos.isEmpty) {
          print('        ⚠️ SEM PREÇOS POR TAMANHO');
        } else {
          for (var preco in precos) {
            final tamanho = preco['produtos_tamanho']?['nome'] ?? 'N/A';
            print('        - Tamanho $tamanho: R\$ ${preco['preco']}');
          }
        }
      }
    }
    
    print('\n2. Deseja criar/atualizar pizzas doces? (s/n)');
    print('   Digite "s" e pressione ENTER para criar pizzas doces');
    print('   Digite "n" e pressione ENTER para cancelar\n');
    
  } catch (e) {
    print('❌ ERRO: $e');
  }
}