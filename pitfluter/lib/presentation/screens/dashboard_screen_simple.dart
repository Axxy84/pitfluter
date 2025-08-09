import 'package:flutter/material.dart';
import '../../services/caixa_service.dart';

class DashboardScreenSimple extends StatefulWidget {
  const DashboardScreenSimple({super.key});

  @override
  State<DashboardScreenSimple> createState() => _DashboardScreenSimpleState();
}

class _DashboardScreenSimpleState extends State<DashboardScreenSimple> {
  final CaixaService _caixaService = CaixaService();
  bool _caixaAberto = false;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    
    // FORÇAR verificação e dialog após 1 segundo
    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted || _dialogShown) return;
      
      try {
        final estado = await _caixaService.verificarEstadoCaixa();
        
        if (mounted) {
          setState(() {
            _caixaAberto = estado.aberto;
          });
          
          // SE CAIXA FECHADO, MOSTRAR DIALOG IMEDIATAMENTE
          if (!estado.aberto && !_dialogShown) {
            _dialogShown = true;
            _mostrarDialogSimples();
          }
        }
      } catch (e) {
        // EM CASO DE ERRO, MOSTRAR DIALOG
        if (mounted && !_dialogShown) {
          setState(() {
            _caixaAberto = false;
          });
          _dialogShown = true;
          _mostrarDialogSimples();
        }
      }
    });
  }

  void _mostrarDialogSimples() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('🔓 Caixa Fechado'),
          content: const Text(
            'O caixa está fechado.\n\n'
            'Para começar a registrar vendas, você precisa abrir o caixa.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pushNamed(context, '/caixa');
              },
              child: const Text('Abrir Depois'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _abrirCaixaRapido();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Abrir Agora'),
            ),
          ],
        );
      },
    );
  }

  void _abrirCaixaRapido() async {
    try {
      await _caixaService.abrirCaixa(0.0, 'Abertura rápida', 'Operador');
      
      if (mounted) {
        setState(() {
          _caixaAberto = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Caixa aberto com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: $e'),
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
        title: const Text('Dashboard Teste'),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _caixaAberto ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  _caixaAberto ? Icons.lock_open : Icons.lock,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  _caixaAberto ? 'Caixa Aberto' : 'Caixa Fechado',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _caixaAberto ? '✅ Caixa está ABERTO' : '❌ Caixa está FECHADO',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            if (!_caixaAberto)
              ElevatedButton.icon(
                onPressed: () {
                  _dialogShown = false;
                  _mostrarDialogSimples();
                },
                icon: const Icon(Icons.lock_open),
                label: const Text('Mostrar Dialog de Abertura'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}