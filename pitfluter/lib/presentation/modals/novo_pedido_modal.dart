import 'package:flutter/material.dart';

class NovoPedidoModal extends StatefulWidget {
  const NovoPedidoModal({super.key});

  @override
  State<NovoPedidoModal> createState() => _NovoPedidoModalState();
}

class _NovoPedidoModalState extends State<NovoPedidoModal> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _observacoesController = TextEditingController();
  
  String? _clienteSelecionado;
  String? _produtoSelecionado;
  String? _tamanhoSelecionado;
  int _quantidade = 1;
  double _valorTotal = 0.0;

  // Dados mockados
  final List<String> _clientes = [
    'João Silva',
    'Maria Santos',
    'Pedro Costa',
    'Ana Oliveira',
  ];

  final List<Map<String, dynamic>> _produtos = [
    {'nome': 'Pizza Margherita', 'preco': 28.90},
    {'nome': 'Pizza Calabresa', 'preco': 32.90},
    {'nome': 'Pizza Portuguesa', 'preco': 36.90},
    {'nome': 'Pizza Quatro Queijos', 'preco': 38.90},
  ];

  final List<Map<String, dynamic>> _tamanhos = [
    {'nome': 'Pequena', 'multiplicador': 0.8},
    {'nome': 'Média', 'multiplicador': 1.0},
    {'nome': 'Grande', 'multiplicador': 1.3},
  ];

  @override
  void dispose() {
    _clienteController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Pedido'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: _salvarPedido,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              'Salvar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção Cliente
              _buildSection(
                'Cliente',
                Icons.person,
                _buildClienteSection(),
              ),
              
              const SizedBox(height: 24),
              
              // Seção Produto
              _buildSection(
                'Produto',
                Icons.local_pizza,
                _buildProdutoSection(),
              ),
              
              const SizedBox(height: 24),
              
              // Seção Observações
              _buildSection(
                'Observações',
                Icons.note_alt,
                _buildObservacoesSection(),
              ),
              
              const SizedBox(height: 24),
              
              // Resumo
              _buildResumo(),
              
              const SizedBox(height: 24),
              
              // Botões
              _buildBotoes(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String titulo, IconData icon, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFDC2626)),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildClienteSection() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _clienteSelecionado,
          decoration: const InputDecoration(
            labelText: 'Selecionar Cliente',
            border: OutlineInputBorder(),
          ),
          items: _clientes.map((cliente) {
            return DropdownMenuItem(
              value: cliente,
              child: Text(cliente),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _clienteSelecionado = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, selecione um cliente';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        const Text(
          'Ou digite o nome de um novo cliente:',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _clienteController,
          decoration: const InputDecoration(
            labelText: 'Nome do Cliente',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildProdutoSection() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _produtoSelecionado,
          decoration: const InputDecoration(
            labelText: 'Produto',
            border: OutlineInputBorder(),
          ),
          items: _produtos.map((produto) {
            return DropdownMenuItem<String>(
              value: produto['nome'] as String,
              child: Text('${produto['nome']} - R\$ ${produto['preco'].toStringAsFixed(2)}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _produtoSelecionado = value;
              _calcularTotal();
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, selecione um produto';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        DropdownButtonFormField<String>(
          value: _tamanhoSelecionado,
          decoration: const InputDecoration(
            labelText: 'Tamanho',
            border: OutlineInputBorder(),
          ),
          items: _tamanhos.map((tamanho) {
            return DropdownMenuItem<String>(
              value: tamanho['nome'] as String,
              child: Text(tamanho['nome'] as String),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _tamanhoSelecionado = value;
              _calcularTotal();
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, selecione um tamanho';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            const Text('Quantidade:'),
            const SizedBox(width: 16),
            IconButton(
              onPressed: _quantidade > 1 ? () {
                setState(() {
                  _quantidade--;
                  _calcularTotal();
                });
              } : null,
              icon: const Icon(Icons.remove),
            ),
            Text(
              _quantidade.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _quantidade++;
                  _calcularTotal();
                });
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildObservacoesSection() {
    return TextFormField(
      controller: _observacoesController,
      decoration: const InputDecoration(
        labelText: 'Observações do pedido',
        hintText: 'Ex: Sem cebola, massa fina...',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildResumo() {
    return Card(
      color: const Color(0xFFDC2626).withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.receipt, color: Color(0xFFDC2626)),
                SizedBox(width: 8),
                Text(
                  'Resumo do Pedido',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_produtoSelecionado != null && _tamanhoSelecionado != null) ...[
              Text('Produto: $_produtoSelecionado ($_tamanhoSelecionado)'),
              Text('Quantidade: $_quantidade'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'R\$ ${_valorTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                'Selecione um produto para ver o resumo',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBotoes() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _salvarPedido,
            child: const Text('Salvar Pedido'),
          ),
        ),
      ],
    );
  }

  void _calcularTotal() {
    if (_produtoSelecionado != null && _tamanhoSelecionado != null) {
      final produto = _produtos.firstWhere((p) => p['nome'] == _produtoSelecionado);
      final tamanho = _tamanhos.firstWhere((t) => t['nome'] == _tamanhoSelecionado);
      
      final precoBase = produto['preco'] as double;
      final multiplicador = tamanho['multiplicador'] as double;
      
      setState(() {
        _valorTotal = precoBase * multiplicador * _quantidade;
      });
    }
  }

  void _salvarPedido() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_produtoSelecionado == null || _tamanhoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um produto e tamanho'),
        ),
      );
      return;
    }

    // Aqui seria a lógica para salvar o pedido
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pedido salvo com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );

    // Volta para a tela anterior após 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }
}