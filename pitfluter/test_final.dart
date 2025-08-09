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
  
  // DEBUG: TESTE FINAL DO DIALOG
  
  // Verificar estado atual
  final estado = await caixaService.verificarEstadoCaixa();
  // DEBUG: Estado do caixa: ${estado.aberto ? "ABERTO" : "FECHADO"}
  
  if (estado.aberto) {
    // DEBUG: O caixa está aberto! O dialog NÃO aparecerá.
    // DEBUG: Execute "flutter run fechar_caixa.dart" primeiro.
  } else {
    // DEBUG: O caixa está fechado! O dialog DEVE aparecer.
  }
  
  runApp(MyTestApp(caixaAberto: estado.aberto));
}

class MyTestApp extends StatelessWidget {
  final bool caixaAberto;
  
  const MyTestApp({super.key, required this.caixaAberto});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TestScreen(caixaAberto: caixaAberto),
    );
  }
}

class TestScreen extends StatefulWidget {
  final bool caixaAberto;
  
  const TestScreen({super.key, required this.caixaAberto});
  
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  void initState() {
    super.initState();
    
    if (!widget.caixaAberto) {
      // Mostrar dialog após 1 segundo
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('🎉 SUCESSO!'),
              content: const Text(
                'O dialog apareceu automaticamente!\n\n'
                'O caixa está fechado e o sistema detectou isso corretamente.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste do Dialog'),
        backgroundColor: widget.caixaAberto ? Colors.green : Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.caixaAberto ? Icons.lock_open : Icons.lock,
              size: 100,
              color: widget.caixaAberto ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 20),
            Text(
              widget.caixaAberto 
                ? 'Caixa está ABERTO' 
                : 'Caixa está FECHADO',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.caixaAberto 
                ? 'O dialog NÃO deve aparecer' 
                : 'O dialog DEVE aparecer em 1 segundo...',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}