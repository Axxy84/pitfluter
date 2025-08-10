// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://akfmfdmsanobdaznfdjw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFrZm1mZG1zYW5vYmRhem5mZGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2NTQxMzgsImV4cCI6MjA0ODIzMDEzOH0.EfF8CeAehGgJy7sZg5LXnQgWKdPTwnQOiN5pjrPFzuo',
  );
  
  final supabase = Supabase.instance.client;
  
  print('=== CRIANDO TAMANHOS SE NÃO EXISTIREM ===\n');
  
  try {
    // 1. Verificar tamanhos existentes
    final tamanhos = await supabase
        .from('tamanhos')
        .select('id, nome');
    
    print('Tamanhos existentes: ${tamanhos.length}');
    for (var t in tamanhos) {
      print('- ${t['nome']} (ID: ${t['id']})');
    }
    
    // 2. Criar tamanhos padrão se não existirem
    final tamanhosNecessarios = ['P', 'M', 'G', 'GG'];
    
    for (var nome in tamanhosNecessarios) {
      final existe = tamanhos.any((t) => t['nome'] == nome);
      if (!existe) {
        await supabase
            .from('tamanhos')
            .insert({'nome': nome});
        print('✅ Tamanho $nome criado');
      }
    }
    
    // 3. Adicionar preços para todas as pizzas
    print('\n=== ADICIONANDO PREÇOS PARA PIZZAS ===\n');
    
    // Buscar todas as pizzas
    final pizzas = await supabase
        .from('produtos')
        .select('id, nome, categoria_id, tipo_produto')
        .or('nome.ilike.%pizza%,tipo_produto.eq.pizza,tipo_produto.eq.pizza_doce');
    
    print('Pizzas encontradas: ${pizzas.length}');
    
    // Buscar tamanhos atualizados
    final tamanhosAtualizados = await supabase
        .from('tamanhos')
        .select('id, nome');
    
    // Para cada pizza
    for (var pizza in pizzas) {
      print('\nProcessando: ${pizza['nome']}');
      
      // Verificar preços existentes
      final precosExistentes = await supabase
          .from('produtos_precos')
          .select('tamanho_id')
          .eq('produto_id', pizza['id']);
      
      final tamanhosComPreco = precosExistentes.map((p) => p['tamanho_id']).toSet();
      
      // Adicionar preços faltantes
      for (var tamanho in tamanhosAtualizados) {
        if (!tamanhosComPreco.contains(tamanho['id'])) {
          final preco = _calcularPreco(tamanho['nome'], pizza['nome']);
          
          await supabase
              .from('produtos_precos')
              .insert({
                'produto_id': pizza['id'],
                'tamanho_id': tamanho['id'],
                'preco': preco,
                'preco_promocional': preco,
              });
          
          print('  + Tamanho ${tamanho['nome']}: R\$ $preco');
        }
      }
    }
    
    print('\n=== PROCESSO CONCLUÍDO ===');
    
  } catch (e) {
    print('❌ Erro: $e');
  }
  
  exit(0);
}

double _calcularPreco(String tamanho, String nomeProduto) {
  final isDoce = nomeProduto.toLowerCase().contains('doce') ||
                 nomeProduto.toLowerCase().contains('chocolate') ||
                 nomeProduto.toLowerCase().contains('nutella') ||
                 nomeProduto.toLowerCase().contains('brigadeiro');
  
  switch (tamanho) {
    case 'P':
      return isDoce ? 30.00 : 25.00;
    case 'M':
      return isDoce ? 40.00 : 35.00;
    case 'G':
      return isDoce ? 50.00 : 45.00;
    case 'GG':
    case 'Família':
      return isDoce ? 60.00 : 55.00;
    default:
      return 40.00;
  }
}

void exit(int code) {
  // Finalizar
}