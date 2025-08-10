import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/caixa_service.dart';
import '../layouts/main_layout.dart';

class InicialScreen extends StatefulWidget {
  const InicialScreen({super.key});

  @override
  State<InicialScreen> createState() => _InicialScreenState();
}

class _InicialScreenState extends State<InicialScreen> {
  final CaixaService _caixaService = CaixaService();
  bool _verificando = true;
  bool _mostrandoDialog = false;

  @override
  void initState() {
    super.initState();
    // Verificar caixa imediatamente
    _verificarCaixa();
  }

  Future<void> _verificarCaixa() async {
    // Pequeno delay para garantir que a tela está montada
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    try {
      final estado = await _caixaService.verificarEstadoCaixa();
      
      if (!mounted) return;
      
      if (estado.aberto) {
        // Caixa já está aberto, ir direto para o app
        _navegarParaApp();
      } else {
        // Caixa fechado, mostrar dialog
        setState(() {
          _verificando = false;
        });
        _mostrarDialogAbrirCaixa();
      }
    } catch (e) {
      // Em caso de erro, mostrar dialog de abertura
      if (!mounted) return;
      
      setState(() {
        _verificando = false;
      });
      _mostrarDialogAbrirCaixa();
    }
  }

  void _navegarParaApp() {
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainLayout(),
      ),
    );
  }

  void _mostrarDialogAbrirCaixa() {
    if (_mostrandoDialog || !mounted) return;
    
    setState(() {
      _mostrandoDialog = true;
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final TextEditingController nomeController = TextEditingController();
        final TextEditingController valorController = TextEditingController(text: '0,00');
        bool processando = false;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.point_of_sale, color: Colors.green, size: 32),
                  SizedBox(width: 12),
                  Text('Abertura de Caixa'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Para iniciar as operações do dia, é necessário abrir o caixa.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Operador',
                      hintText: 'Digite seu nome',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                    enabled: !processando,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: valorController,
                    decoration: const InputDecoration(
                      labelText: 'Valor Inicial (R\$)',
                      hintText: '0,00',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        String text = newValue.text.replaceAll(',', '.');
                        if (text.isEmpty) return newValue;
                        
                        try {
                          final value = double.parse(text);
                          final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
                          return TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          );
                        } catch (e) {
                          return oldValue;
                        }
                      }),
                    ],
                    enabled: !processando,
                    onSubmitted: processando ? null : (_) async {
                      setDialogState(() {
                        processando = true;
                      });
                      await _abrirCaixa(nomeController, valorController, dialogContext);
                      setDialogState(() {
                        processando = false;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Digite o valor do fundo de caixa inicial.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                FilledButton.icon(
                  onPressed: processando ? null : () async {
                    setDialogState(() {
                      processando = true;
                    });
                    await _abrirCaixa(nomeController, valorController, dialogContext);
                    setDialogState(() {
                      processando = false;
                    });
                  },
                  icon: processando 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.lock_open),
                  label: Text(processando ? 'Abrindo...' : 'Abrir Caixa'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        _mostrandoDialog = false;
      });
    });
  }

  Future<void> _abrirCaixa(
    TextEditingController nomeController,
    TextEditingController valorController,
    BuildContext dialogContext,
  ) async {
    try {
      final nome = nomeController.text.trim();
      final valorText = valorController.text.replaceAll(',', '.');
      final valor = double.tryParse(valorText) ?? 0.0;
      
      if (nome.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, digite o nome do operador'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      if (valor < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O valor inicial não pode ser negativo'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      await _caixaService.abrirCaixa(valor, 'Abertura de caixa do dia', nome);
      
      // Pop the dialog first
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Caixa aberto com sucesso! Operador: $nome | Valor inicial: R\$ ${valor.toStringAsFixed(2)}'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Navegar para o app principal
      _navegarParaApp();
      
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao abrir caixa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_pizza,
              size: 100,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Pit-Stop',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 40),
            if (_verificando) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Verificando estado do caixa...',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              Icon(
                Icons.point_of_sale,
                size: 48,
                color: colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Aguardando abertura do caixa',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}