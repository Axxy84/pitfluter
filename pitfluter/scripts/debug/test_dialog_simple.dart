// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/presentation/screens/dashboard_screen_simple.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://lhvfacztsbflrtfibeek.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo',
  );
  
  // DEBUG: TESTE DO DIALOG DE ABERTURA DE CAIXA
  // DEBUG: O dialog deve aparecer automaticamente em 1 segundo se o caixa estiver fechado
  
  runApp(MaterialApp(
    home: const DashboardScreenSimple(),
    routes: {
      '/caixa': (context) => Scaffold(
        appBar: AppBar(title: const Text('Tela de Caixa')),
        body: const Center(child: Text('Tela de Caixa')),
      ),
    },
  ));
}