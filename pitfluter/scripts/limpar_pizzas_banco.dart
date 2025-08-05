#!/usr/bin/env dart
/*
Script para limpar automaticamente todas as pizzas com preços incorretos do banco de dados
ATENÇÃO: Este script irá DELETAR dados do banco. Use com cuidado!
*/

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🔥 SCRIPT DE LIMPEZA AUTOMÁTICA DE PIZZAS');
  print('=' * 60);
  print('⚠️  ATENÇÃO: Este script irá DELETAR pizzas do banco de dados!');
  print('⚠️  Certifique-se de que você quer continuar.');
  print('');
  
  // Configurar Supabase (você precisa ajustar estas configurações)
  const supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  const supabaseKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
  
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    
    final supabase = Supabase.instance.client;
    
    // 1. BUSCAR TODAS AS PIZZAS
    print('🔍 BUSCANDO TODAS AS PIZZAS NO BANCO...');
    final response = await supabase
        .from('produtos_produto')
        .select('*')
        .order('nome');
    
    // Filtrar apenas pizzas
    final pizzas = response.where((produto) {
      final nome = produto['nome']?.toString().toLowerCase() ?? '';
      final categoria = produto['categoria']?.toString().toLowerCase() ?? '';
      final tipoProduto = produto['tipo_produto']?.toString().toLowerCase() ?? '';
      
      return nome.contains('pizza') || 
             categoria.contains('pizza') || 
             tipoProduto.contains('pizza') ||
             nome.contains('margherita') ||
             nome.contains('calabresa') ||
             nome.contains('vegetariana') ||
             nome.contains('portuguesa') ||
             nome.contains('napolitana') ||
             nome.contains('mozzarella') ||
             nome.contains('queijo');
    }).toList();
    
    print('🍕 PIZZAS ENCONTRADAS: ${pizzas.length}');
    print('-' * 50);
    
    // 2. LISTAR PIZZAS QUE SERÃO DELETADAS
    for (int i = 0; i < pizzas.length; i++) {
      final pizza = pizzas[i];
      print('${i + 1:2d}. ${pizza['nome']} - R\$ ${pizza['preco_unitario'] ?? pizza['preco'] ?? 0}');
    }
    
    if (pizzas.isEmpty) {
      print('✅ Nenhuma pizza encontrada para deletar.');
      return;
    }
    
    print('');
    print('⚠️  CONFIRME: ${pizzas.length} pizzas serão DELETADAS permanentemente!');
    print('⚠️  Digite "CONFIRMAR_DELETAR" para continuar ou qualquer outra coisa para cancelar:');
    
    // Simular confirmação (em um script real, você usaria stdin)
    // final confirmacao = stdin.readLineSync();
    final confirmacao = 'CANCELAR'; // Mudança esta linha para 'CONFIRMAR_DELETAR' se quiser executar
    
    if (confirmacao != 'CONFIRMAR_DELETAR') {
      print('❌ OPERAÇÃO CANCELADA pelo usuário.');
      return;
    }
    
    // 3. DELETAR TODAS AS PIZZAS
    print('🔥 INICIANDO DELEÇÃO AUTOMÁTICA...');
    
    int deletadas = 0;
    int erros = 0;
    
    for (final pizza in pizzas) {
      try {
        await supabase
            .from('produtos_produto')
            .delete()
            .eq('id', pizza['id']);
        
        deletadas++;
        print('✅ Deletada: ${pizza['nome']}');
        
        // Pequena pausa para não sobrecarregar o banco
        await Future.delayed(Duration(milliseconds: 100));
        
      } catch (e) {
        erros++;
        print('❌ Erro ao deletar ${pizza['nome']}: $e');
      }
    }
    
    print('');
    print('🎯 RESULTADO FINAL:');
    print('✅ Pizzas deletadas: $deletadas');
    print('❌ Erros: $erros');
    print('📊 Total processadas: ${deletadas + erros}/${pizzas.length}');
    
    if (deletadas > 0) {
      print('');
      print('🎉 LIMPEZA CONCLUÍDA COM SUCESSO!');
      print('💡 Agora você pode adicionar as pizzas com preços corretos.');
    }
    
  } catch (e) {
    print('❌ ERRO GERAL: $e');
    print('');
    print('💡 DICAS PARA CORRIGIR:');
    print('1. Verifique se SUPABASE_URL e SUPABASE_KEY estão corretos');
    print('2. Verifique se a tabela "produtos_produto" existe');
    print('3. Verifique as permissões de DELETE no Supabase');
  }
}