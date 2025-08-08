import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://hkqbqzxlzxxgdeqmqhpy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhrcWJxenhsenhYZ2RlcW1xaHB5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzA3Mjk3MTMsImV4cCI6MjA0NjMwNTcxM30.8GlVJzZz-JiRXJxH3YQK2K62zpxgMdcHsYlP17kkhmU',
  );

  final supabase = Supabase.instance.client;

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
      print('⚠️ Tabela vazia ou não encontrada');
      
      // Tentar inserir um pedido de teste
      print('\n🧪 Tentando criar pedido de teste...');
      
      final testData = {
        'numero': 'TEST-001',
        'subtotal': 10.0,
        'total': 10.0,
        'status': 'aberto',
        'data_hora_criacao': DateTime.now().toIso8601String(),
      };
      
      try {
        final response = await supabase
            .from('pedidos')
            .insert(testData)
            .select()
            .single();
        
        print('✅ Pedido de teste criado com sucesso!');
        print('Campos retornados:');
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
        print('❌ Erro ao criar pedido de teste: $e');
      }
    }
    
  } catch (e) {
    print('❌ Erro ao verificar estrutura: $e');
  }
}