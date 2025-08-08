// Script simples para testar a conectividade do banco
// Execute com: flutter run quick_caixa_test.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Credenciais corretas do Supabase
  const supabaseUrl = 'https://lhvfacztsbflrtfibeek.supabase.co';
  const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo';
  
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    
    final supabase = Supabase.instance.client;
    
    // DEBUG: Testando conectividade com Supabase...
    
    // 1. Testar conexão básica
    // DEBUG: 1. Verificando tabela caixa...
    await supabase.from('caixa').select().limit(1);
    // DEBUG: Tabela caixa acessível
    
    // 2. Verificar último caixa
    final ultimoCaixa = await supabase
        .from('caixa')
        .select()
        .order('data_abertura', ascending: false)
        .limit(1);
        
    if (ultimoCaixa.isEmpty) {
      // DEBUG: Nenhum caixa encontrado - caixa considerado fechado
    } else {
      // DEBUG: Último caixa - ID: ${ultimoCaixa.first['id']}, Aberto: ${ultimoCaixa.first['data_fechamento'] == null}
    }
    
    // 3. Simular inserção de caixa (se não houver nenhum)
    if (ultimoCaixa.isEmpty) {
      // DEBUG: 2. Criando caixa de teste...
      await supabase.from('caixa').insert({
        'data_abertura': DateTime.now().toIso8601String(),
        'saldo_inicial': 100.0,
        'observacoes': 'Caixa de teste criado automaticamente',
        'usuario_id': 1,
      });
      // DEBUG: Caixa de teste criado
      
      // Verificar novamente
      final novoCaixa = await supabase
          .from('caixa')
          .select()
          .order('data_abertura', ascending: false)
          .limit(1);
          
      if (novoCaixa.isNotEmpty) {
        // DEBUG: Estado atual: Aberto: ${novoCaixa.first['data_fechamento'] == null}
      }
    }
    
    // DEBUG: Teste completo! Verifique os logs acima.
    
  } catch (e) {
    // DEBUG: ERRO: $e
    
    if (e.toString().contains('credentials')) {
      // DEBUG: Dica: Verifique se as credenciais do Supabase estão corretas
    }
    if (e.toString().contains('network')) {
      // DEBUG: Dica: Verifique sua conexão com a internet
    }
    if (e.toString().contains('table')) {
      // DEBUG: Dica: Verifique se a tabela "caixa" existe no Supabase
    }
  }
}