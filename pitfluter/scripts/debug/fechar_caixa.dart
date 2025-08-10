// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/services/caixa_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://lhvfacztsbflrtfibeek.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );
  
  final caixaService = CaixaService();
  
  try {
    // Verificando estado do caixa...
    final estado = await caixaService.verificarEstadoCaixa();
    
    if (estado.aberto) {
      // Caixa está aberto (ID: ${estado.id}). Fechando...
      await caixaService.fecharCaixa();
      // ✅ Caixa fechado com sucesso!
      // Agora você pode executar o app e o dialog deve aparecer.
    } else {
      // ✅ Caixa já está fechado.
      // O dialog deve aparecer quando você executar o app.
    }
  } catch (e) {
    // ❌ Erro: $e
  }
  
  // Execute o app com: flutter run -d linux
}