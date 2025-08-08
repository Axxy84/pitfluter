import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/mesa_service.dart';
import '../../services/impressao_service.dart';

class MesasAbertasScreen extends StatefulWidget {
  const MesasAbertasScreen({super.key});

  @override
  State<MesasAbertasScreen> createState() => _MesasAbertasScreenState();
}

class _MesasAbertasScreenState extends State<MesasAbertasScreen> {
  final MesaService _mesaService = MesaService();
  final ImpressaoService _impressaoService = ImpressaoService();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  
  List<Map<String, dynamic>> _mesasAbertas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarMesasAbertas();
  }

  Future<void> _carregarMesasAbertas() async {
    setState(() => _isLoading = true);
    
    final mesas = await _mesaService.getMesasAbertas();
    
    setState(() {
      _mesasAbertas = mesas;
      _isLoading = false;
    });
  }

  Future<void> _mostrarDetalhesMesa(Map<String, dynamic> mesa) async {
    final detalhes = await _mesaService.getDetalhesMesa(mesa['mesa']['id']);
    
    if (detalhes == null || !mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mesa ${detalhes['mesa']['numero']}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Pedidos:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...((detalhes['pedidos'] as List).map((pedido) => 
                Card(
                  child: ListTile(
                    title: Text('Pedido #${pedido['numero']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (pedido['itens_pedido'] != null)
                          ...((pedido['itens_pedido'] as List).map((item) =>
                            Text('${item['quantidade']}x ${item['produtos']?['nome'] ?? 'Produto'}')
                          )),
                      ],
                    ),
                    trailing: Text(
                      _currencyFormat.format(pedido['total'] ?? 0),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 16),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    _currencyFormat.format(detalhes['total']),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Botões principais
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_shopping_cart, size: 20),
                    label: const Text('Add Consumo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () => _adicionarConsumo(mesa['mesa']['id'], setDialogState),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.receipt, size: 20),
                    label: const Text('Comanda'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () async {
                      await _imprimirComanda(detalhes);
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.print, size: 20),
                    label: const Text('Conta'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () async {
                      await _impressaoService.imprimirContaMesa(detalhes);
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.payment, size: 20),
                    label: const Text('Fechar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () => _fecharContaMesa(mesa['mesa']['id']),
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calcularPrecoTotal(Map<String, dynamic> produto, int quantidade) {
    double preco = 0.0;
    
    if (produto['tipo_produto'] == 'pizza') {
      // Para pizza, usar o preço selecionado
      preco = (produto['preco_selecionado'] ?? 0.0).toDouble();
    } else {
      // Para outros produtos
      preco = (produto['preco_unitario'] ?? produto['preco'] ?? 0.0).toDouble();
    }
    
    return preco * quantidade;
  }

  Future<void> _imprimirComanda(Map<String, dynamic> detalhes) async {
    try {
      // Criar estrutura de comanda simplificada
      final comanda = {
        'mesa': detalhes['mesa'],
        'pedidos': detalhes['pedidos'],
        'total': detalhes['total'],
        'tipo': 'comanda',
      };
      
      await _impressaoService.imprimirContaMesa(comanda);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comanda impressa com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao imprimir comanda: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _adicionarConsumo(int mesaId, StateSetter setDialogState) async {
    final supabase = Supabase.instance.client;
    
    // Buscar produtos disponíveis com preços
    final produtosResponse = await supabase
        .from('produtos_produto')
        .select('*, produtos_produtopreco(*)')
        .eq('ativo', true)
        .order('nome');
    
    if (!mounted) return;
    
    Map<String, dynamic>? produtoSelecionado;
    int quantidade = 1;
    final observacoesController = TextEditingController();
    final searchController = TextEditingController();
    List<Map<String, dynamic>> produtosFiltrados = List.from(produtosResponse);
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Adicionar Consumo'),
          content: SizedBox(
            width: 500,
            height: 400,
            child: Column(
              children: [
                // Campo de busca
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar produto',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      produtosFiltrados = produtosResponse.where((produto) {
                        final nome = produto['nome']?.toString().toLowerCase() ?? '';
                        final busca = value.toLowerCase();
                        return nome.contains(busca);
                      }).toList();
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Lista de produtos
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: produtosFiltrados.length,
                      itemBuilder: (context, index) {
                        final produto = produtosFiltrados[index];
                        
                        // Determinar o preço baseado no tipo de produto
                        double preco = 0.0;
                        String precoTexto = '';
                        
                        if (produto['tipo_produto'] == 'pizza' && produto['produtos_produtopreco'] != null) {
                          // Para pizzas, mostrar faixa de preço ou menor preço
                          final precos = produto['produtos_produtopreco'] as List;
                          if (precos.isNotEmpty) {
                            final precosValores = precos.map((p) => (p['preco'] ?? 0.0) as num).toList();
                            precosValores.sort();
                            preco = precosValores.first.toDouble();
                            if (precosValores.length > 1) {
                              precoTexto = 'A partir de ${_currencyFormat.format(preco)}';
                            } else {
                              precoTexto = _currencyFormat.format(preco);
                            }
                          }
                        } else {
                          // Para outros produtos, usar preco_unitario
                          preco = (produto['preco_unitario'] ?? produto['preco'] ?? 0.0).toDouble();
                          precoTexto = _currencyFormat.format(preco);
                        }
                        
                        final isSelected = produtoSelecionado?['id'] == produto['id'];
                        
                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          title: Text(produto['nome'] ?? 'Sem nome'),
                          subtitle: Text(produto['descricao'] ?? ''),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                precoTexto,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (produto['tipo_produto'] == 'pizza')
                                Text(
                                  'Pizza',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              produtoSelecionado = produto;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Se for pizza, mostrar seleção de tamanho
                if (produtoSelecionado != null && produtoSelecionado!['tipo_produto'] == 'pizza' && produtoSelecionado!['produtos_produtopreco'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tamanho:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...(produtoSelecionado!['produtos_produtopreco'] as List).map((precoItem) {
                        return RadioListTile<String>(
                          title: Text(precoItem['tamanho'] ?? 'Tamanho'),
                          subtitle: Text(_currencyFormat.format(precoItem['preco'] ?? 0)),
                          value: precoItem['tamanho'] ?? '',
                          groupValue: produtoSelecionado!['tamanho_selecionado'],
                          onChanged: (value) {
                            setState(() {
                              produtoSelecionado!['tamanho_selecionado'] = value;
                              produtoSelecionado!['preco_selecionado'] = precoItem['preco'];
                            });
                          },
                        );
                      }),
                      const Divider(),
                    ],
                  ),
                const SizedBox(height: 16),
                // Quantidade
                Row(
                  children: [
                    const Text('Quantidade:'),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: quantidade > 1 ? () {
                        setState(() {
                          quantidade--;
                        });
                      } : null,
                    ),
                    Text(
                      quantidade.toString(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          quantidade++;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Observações
                TextField(
                  controller: observacoesController,
                  decoration: const InputDecoration(
                    labelText: 'Observações (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                // Total
                if (produtoSelecionado != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _currencyFormat.format(_calcularPrecoTotal(produtoSelecionado!, quantidade)),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: (produtoSelecionado == null || 
                         (produtoSelecionado!['tipo_produto'] == 'pizza' && produtoSelecionado!['tamanho_selecionado'] == null))
                        ? null 
                        : () async {
                double preco = 0.0;
                String observacoesCompletas = observacoesController.text;
                
                if (produtoSelecionado!['tipo_produto'] == 'pizza') {
                  preco = (produtoSelecionado!['preco_selecionado'] ?? 0.0).toDouble();
                  observacoesCompletas = '${produtoSelecionado!['tamanho_selecionado']} - $observacoesCompletas'.trim();
                } else {
                  preco = (produtoSelecionado!['preco_unitario'] ?? produtoSelecionado!['preco'] ?? 0.0).toDouble();
                }
                
                final itemData = {
                  'produto_id': produtoSelecionado!['id'],
                  'quantidade': quantidade,
                  'preco_unitario': preco,
                  'total': preco * quantidade,
                  'observacoes': observacoesCompletas,
                };
                
                // Salvar contexto antes da operação async
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                
                final success = await _mesaService.adicionarConsumo(mesaId, itemData);
                
                if (success) {
                  if (!mounted) return;
                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Consumo adicionado com sucesso!')),
                  );
                  
                  // Recarregar detalhes da mesa
                  navigator.pop();
                  _carregarMesasAbertas();
                } else {
                  if (!mounted) return;
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Erro ao adicionar consumo'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
    
    observacoesController.dispose();
    searchController.dispose();
  }

  Future<void> _fecharContaMesa(int mesaId) async {
    Navigator.of(context).pop();
    
    final formaPagamento = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forma de Pagamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Dinheiro'),
              onTap: () => Navigator.of(context).pop('Dinheiro'),
            ),
            ListTile(
              title: const Text('Cartão de Crédito'),
              onTap: () => Navigator.of(context).pop('Cartão'),
            ),
            ListTile(
              title: const Text('Cartão de Débito'),
              onTap: () => Navigator.of(context).pop('Cartão'),
            ),
            ListTile(
              title: const Text('PIX'),
              onTap: () => Navigator.of(context).pop('PIX'),
            ),
          ],
        ),
      ),
    );

    if (formaPagamento == null) return;

    final success = await _mesaService.fecharContaMesa(mesaId, formaPagamento);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta fechada com sucesso!')),
      );
      _carregarMesasAbertas();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao fechar conta'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesas Abertas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarMesasAbertas,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mesasAbertas.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.table_restaurant, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma mesa aberta',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _mesasAbertas.length,
                    itemBuilder: (context, index) {
                      final mesa = _mesasAbertas[index];
                      final numeroMesa = mesa['mesa']?['numero'] ?? 0;
                      final total = mesa['total'] ?? 0.0;
                      
                      return Card(
                        elevation: 4,
                        child: InkWell(
                          onTap: () => _mostrarDetalhesMesa(mesa),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.table_restaurant,
                                  size: 48,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Mesa $numeroMesa',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _currencyFormat.format(total),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}