// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
// ignore_for_file: avoid_print

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pitfluter/core/constants/supabase_constants.dart';
import 'package:pitfluter/services/caixa_service.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  final caixaService = CaixaService();
  
  try {
    print('Verificando estado do caixa...');
    final estado = await caixaService.verificarEstadoCaixa();
    
    if (estado.aberto) {
      print('Caixa está aberto. Fechando...');
      await caixaService.fecharCaixa();
      print('✅ Caixa fechado com sucesso!');
    } else {
      print('✅ Caixa já está fechado.');
    }
  } catch (e) {
    print('❌ Erro: $e');
  }
}