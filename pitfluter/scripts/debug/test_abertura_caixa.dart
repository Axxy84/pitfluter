// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/core/constants/supabase_constants.dart';
import 'lib/services/caixa_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Abertura Caixa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final CaixaService _caixaService = CaixaService();
  String _status = 'Verificando estado do caixa...';
  bool _caixaAberto = false;

  @override
  void initState() {
    super.initState();
    // Verificar caixa após o widget ser montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarEAbrirCaixa();
    });
  }

  Future<void> _verificarEAbrirCaixa() async {
    try {
      final estado = await _caixaService.verificarEstadoCaixa();
      
      if (mounted) {
        setState(() {
          _caixaAberto = estado.aberto;
          _status = estado.aberto 
            ? 'Caixa está ABERTO (ID: ${estado.id})' 
            : 'Caixa está FECHADO';
        });
        
        // Se o caixa estiver fechado, mostrar dialog para abrir
        if (!estado.aberto) {
          _mostrarDialogAbrirCaixa();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Erro ao verificar caixa: $e';
          _caixaAberto = false;
        });
        // Mostrar dialog mesmo com erro
        _mostrarDialogAbrirCaixa();
      }
    }
  }

  void _mostrarDialogAbrirCaixa() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final TextEditingController valorController = TextEditingController(text: '100,00');
        
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.point_of_sale, color: Colors.green),
              SizedBox(width: 8),
              Text('Abrir Caixa'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Para iniciar as operações do dia, é necessário abrir o caixa.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valorController,
                decoration: const InputDecoration(
                  labelText: 'Valor Inicial (R\$)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _status = 'Abertura cancelada pelo usuário';
                });
              },
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () async {
                try {
                  final valorText = valorController.text.replaceAll(',', '.');
                  final valor = double.tryParse(valorText) ?? 0.0;
                  
                  await _caixaService.abrirCaixa(valor, 'Abertura de caixa - Teste');
                  
                  if (context.mounted) Navigator.of(context).pop();
                  
                  setState(() {
                    _status = 'Caixa aberto com sucesso! Valor inicial: R\$ ${valor.toStringAsFixed(2)}';
                    _caixaAberto = true;
                  });
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Caixa aberto com sucesso! Valor inicial: R\$ ${valor.toStringAsFixed(2)}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) Navigator.of(context).pop();
                  setState(() {
                    _status = 'Erro ao abrir caixa: $e';
                  });
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao abrir caixa: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.lock_open),
              label: const Text('Abrir Caixa'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fecharCaixa() async {
    try {
      await _caixaService.fecharCaixa();
      
      setState(() {
        _status = 'Caixa fechado com sucesso!';
        _caixaAberto = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Caixa fechado com sucesso!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = 'Erro ao fechar caixa: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fechar caixa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste de Abertura de Caixa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _caixaAberto ? Icons.lock_open : Icons.lock,
              size: 100,
              color: _caixaAberto ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              _status,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _verificarEAbrirCaixa,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Verificar Novamente'),
                ),
                const SizedBox(width: 20),
                if (_caixaAberto)
                  ElevatedButton.icon(
                    onPressed: _fecharCaixa,
                    icon: const Icon(Icons.lock),
                    label: const Text('Fechar Caixa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}