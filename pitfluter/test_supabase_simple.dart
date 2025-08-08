import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://hkqbqzxlzxxgdeqmqhpy.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhrcWJxenhsenhYZ2RlcW1xaHB5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA3Mjk3MTMsImV4cCI6MjA0NjMwNTcxM30.8GlVJzZz-JiRXJxH3YQK2K62zpxgMdcHsYlP17kkhmU',
  );

  try {
    print('🔍 Verificando estrutura da tabela pedidos...\n');
    
    // Buscar um pedido para ver a estrutura
    final resultado = await supabase
        .from('pedidos')
        .select('*')
        .limit(1)
        .maybeSingle();
    
    if (resultado != null) {
      print('✅ Campos disponíveis na tabela pedidos:');
      resultado.keys.forEach((campo) {
        final valor = resultado[campo];
        final tipo = valor?.runtimeType ?? 'null';
        print('   - $campo (tipo: $tipo)');
      });
    } else {
      print('⚠️ Tabela vazia. Tentando criar pedido de teste...');
      
      // Tentar inserir um pedido de teste com diferentes nomes de campos
      final testData = {
        'numero_pedido': 'TEST-001',
        'tipo': 'balcao',
        'valor_total': 10.0,
        'forma_pagamento': 'Dinheiro',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      try {
        final response = await supabase
            .from('pedidos')
            .insert(testData)
            .select()
            .single();
        
        print('✅ Pedido criado! Campos retornados:');
        response.keys.forEach((campo) {
          print('   - $campo');
        });
        
        // Deletar pedido de teste
        await supabase
            .from('pedidos')
            .delete()
            .eq('id', response['id']);
        print('\n🗑️ Pedido de teste removido');
        
      } catch (e) {
        print('❌ Erro ao criar pedido: $e');
        print('\n💡 Tentando com campos alternativos...');
        
        // Tentar com outros nomes de campos
        final altData = {
          'numero': 'TEST-002',
          'tipo': 'balcao',
          'total': 10.0,
          'pagamento': 'Dinheiro',
        };
        
        try {
          final response2 = await supabase
              .from('pedidos')
              .insert(altData)
              .select()
              .single();
          
          print('✅ Pedido criado com campos alternativos! Campos:');
          response2.keys.forEach((campo) {
            print('   - $campo');
          });
          
          await supabase
              .from('pedidos')
              .delete()
              .eq('id', response2['id']);
              
        } catch (e2) {
          print('❌ Erro com campos alternativos: $e2');
        }
      }
    }
    
  } catch (e) {
    print('❌ Erro ao verificar estrutura: $e');
  } finally {
    supabase.dispose();
  }
}