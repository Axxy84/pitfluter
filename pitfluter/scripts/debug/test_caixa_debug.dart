// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/services/caixa_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Credenciais corretas do Supabase
  await Supabase.initialize(
    url: 'https://lhvfacztsbflrtfibeek.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );
  
  // === DEBUG DO ESTADO DO CAIXA ===
  
  final supabase = Supabase.instance.client;
  final caixaService = CaixaService();
  
  try {
    // 1. Verificar se a tabela caixa existe e tem dados
    // 1. Verificando tabela caixa...
    final caixaResponse = await supabase
        .from('caixa')
        .select()
        .order('data_abertura', ascending: false)
        .limit(5);
    
    // Total de registros: ${caixaResponse.length}
    
    if (caixaResponse.isNotEmpty) {
      // Últimos registros:
      for (int i = 0; i < caixaResponse.length; i++) {
        // final caixa = caixaResponse[i];
        // final aberto = caixa['data_fechamento'] == null;
        // ID: ${caixa['id']}, Aberto: $aberto, Abertura: ${caixa['data_abertura']}
      }
    } else {
      // Nenhum registro encontrado na tabela caixa
    }
    
    // 2. Testar o CaixaService
    // 2. Testando CaixaService.verificarEstadoCaixa()...
    final estado = await caixaService.verificarEstadoCaixa();
    // Caixa aberto: ${estado.aberto}
    // Data abertura: ${estado.dataAbertura}
    // Saldo inicial: ${estado.saldoInicial}
    // ID: ${estado.id}
    
    // 3. Se caixa fechado, tentar forçar fechamento para testar
    if (estado.aberto) {
      // 3. Caixa está aberto. Forçando fechamento para teste...
      try {
        await caixaService.fecharCaixa();
        // ✅ Caixa fechado com sucesso
        
        // Verificar novamente
        // final novoEstado = await caixaService.verificarEstadoCaixa();
        // Novo estado - Aberto: ${novoEstado.aberto}
      } catch (e) {
        // ❌ Erro ao fechar caixa: $e
      }
    } else {
      // 3. Caixa já está fechado
    }
    
    // 4. Verificar tabela usuarios
    // 4. Verificando tabela usuarios...
    try {
      final usuarios = await supabase
          .from('usuarios')
          .select()
          .limit(5);
      // Total de usuários: ${usuarios.length}
      
      if (usuarios.isNotEmpty) {
        // Primeiros usuários:
        for (final _ in usuarios) {
          // ID: ${usuario['id']}, Nome: ${usuario['nome']}
        }
      }
    } catch (e) {
      // ❌ Erro ao buscar usuários: $e
    }
    
    // === FIM DO DEBUG ===
    
  } catch (e) {
    // ❌ ERRO GERAL: $e
    // Stack trace: ${StackTrace.current}
  }
}