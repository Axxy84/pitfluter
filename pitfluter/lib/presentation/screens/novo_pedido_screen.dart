import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../debug/database_diagnostic.dart'; // Comentado - muito verboso
import '../../services/impressao_service.dart';

class NovoPedidoScreen extends StatefulWidget {
  const NovoPedidoScreen({super.key});

  @override
  State<NovoPedidoScreen> createState() => _NovoPedidoScreenState();
}

class _NovoPedidoScreenState extends State<NovoPedidoScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _nomeRetiradaController = TextEditingController();
  final TextEditingController _nomeGarcomController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();
  final TextEditingController _buscaProdutoController = TextEditingController();
  final TextEditingController _taxaEntregaController = TextEditingController(text: '2.00');
  final Map<int, TextEditingController> _observacoesItemControllers = {};
  
  String _tipoPedido = 'delivery';
  String? _produtoSelecionado;
  String _tamanhoSelecionado = 'M';
  bool _doisSabores = false;
  String? _sabor1;
  String? _sabor2;
  int _quantidade = 1;
  int _mesaSelecionada = 1;
  
  final List<Map<String, dynamic>> _carrinho = [];
  double _subtotal = 0.0;
  double _taxaEntregaEditavel = 2.0;
  String _filtroTexto = '';
  bool _carregandoProdutos = false;
  List<Map<String, dynamic>> _produtosBanco = [];
  
  final Map<String, double> _multiplicadorTamanho = {
    'P': 0.8,
    'M': 1.0,
    'G': 1.3,
    'F': 1.6,
  };

  final List<Map<String, dynamic>> _pizzas = [
    {'nome': 'Margherita', 'preco': 32.0, 'imagem': '🍕'},
    {'nome': '4 Queijos', 'preco': 38.0, 'imagem': '🍕'},
    {'nome': 'Pepperoni', 'preco': 35.0, 'imagem': '🍕'},
    {'nome': 'Calabresa', 'preco': 30.0, 'imagem': '🍕'},
  ];

  final List<Map<String, dynamic>> _bebidas = [
    {'nome': 'Coca-Cola', 'preco': 8.0, 'imagem': '🥤'},
    {'nome': 'Guaraná', 'preco': 7.0, 'imagem': '🥤'},
    {'nome': 'Água', 'preco': 4.0, 'imagem': '💧'},
  ];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Pizzas, Bebidas, Bordas
    _carregarProdutos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _clienteController.dispose();
    _enderecoController.dispose();
    _nomeRetiradaController.dispose();
    _nomeGarcomController.dispose();
    _observacoesController.dispose();
    _buscaProdutoController.dispose();
    _taxaEntregaController.dispose();
    for (var controller in _observacoesItemControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _carregarProdutos() async {
    setState(() {
      _carregandoProdutos = true;
    });
    
    try {
      // Diagnóstico comentado - muito verboso
      // await DatabaseDiagnostic.runDiagnostic();
      
      final supabase = Supabase.instance.client;
      
      // Usar a MESMA query que funciona na tela de produtos!
      
      // Query para produtos - mesma que funciona na tela de produtos
      final produtosResponse = await supabase
          .from('produtos_produto')
          .select('''
            *,
            produtos_produtopreco (
              preco,
              preco_promocional,
              tamanho_id,
              produtos_tamanho (
                nome
              )
            ),
            produtos_categoria (
              id,
              nome
            )
          ''')
          .eq('ativo', true)
          .order('nome');
      
      
      setState(() {
        _produtosBanco = produtosResponse.map((produto) {
          // Usar produtos_categoria ao invés de categorias
          final categoria = produto['produtos_categoria'];
          final categoriaNome = categoria?['nome'] ?? 'Outros';
          
          // Extrair preço dos preços relacionados
          double precoBase = 40.0; // Preço padrão das pizzas promocionais
          final precos = produto['produtos_produtopreco'] as List?;
          if (precos != null && precos.isNotEmpty) {
            // Pegar o preço promocional se existir, senão o preço normal
            precoBase = (precos[0]['preco_promocional'] ?? precos[0]['preco'] ?? 40.0).toDouble();
          }
          
          return {
            'id': produto['id'],
            'nome': produto['nome'] as String,
            'descricao': produto['descricao'] ?? produto['ingredientes'] ?? '',
            'preco': precoBase,
            'categoriaId': produto['categoria_id'],
            'categoriaNome': categoriaNome,
            'imagemUrl': produto['imagem'],
            'imagem': _getEmojiPorCategoria(categoriaNome),
            'tipoProduto': produto['tipo_produto'] ?? 'pizza',
          };
        }).toList();
        _carregandoProdutos = false;
      });
      
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _carregandoProdutos = false;
        });
      }
      
      // Mostrar erro e usar dados mockados como fallback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar produtos: $e\nUsando dados de exemplo.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String _getEmojiPorCategoria(String categoria) {
    final cat = categoria.toLowerCase();
    if (cat.contains('pizza')) {
      return '🍕';
    } else if (cat.contains('bebida') || cat.contains('drink') || cat.contains('cerveja') || cat.contains('refrigerante')) {
      return '🥤';
    } else if (cat.contains('borda')) {
      return '🧀';
    } else if (cat.contains('sobremesa') || cat.contains('doce')) {
      return '🍰';
    } else {
      return '🍽️';
    }
  }

  List<Map<String, dynamic>> get _produtosAtuais {
    List<Map<String, dynamic>> produtos;
    
    if (_produtosBanco.isNotEmpty) {
      // Usar produtos do banco de dados com mesma lógica da tela produtos
      switch (_tabController.index) {
        case 0:
          // Pizzas - usar mesmo mapeamento da tela produtos
          produtos = _produtosBanco.where((p) {
            final categoria = p['categoriaNome'].toString().toLowerCase();
            final tipoProduto = p['tipoProduto'].toString().toLowerCase();
            final nomeProduto = p['nome'].toString().toLowerCase();
            
            // Palavras-chave para pizzas (mesmo critério da tela produtos)
            final palavrasChavePizza = ['pizza', 'pizzas especiais', 'pizzas salgadas', 'pizzas doces'];
            
            return palavrasChavePizza.any((palavra) => 
              categoria.contains(palavra.toLowerCase()) ||
              tipoProduto.contains(palavra.toLowerCase()) ||
              nomeProduto.contains('pizza')
            );
          }).toList();
          break;
        case 1:
          // Bebidas - usar mesmo mapeamento da tela produtos
          produtos = _produtosBanco.where((p) {
            final categoria = p['categoriaNome'].toString().toLowerCase();
            final tipoProduto = p['tipoProduto'].toString().toLowerCase();
            final nomeProduto = p['nome'].toString().toLowerCase();
            
            // Palavras-chave para bebidas (mesmo critério da tela produtos)
            final palavrasChaveBebida = ['bebida', 'bebidas', 'drink', 'drinks', 'cerveja', 'cervejas', 'refrigerante', 'suco'];
            
            return palavrasChaveBebida.any((palavra) => 
              categoria.contains(palavra.toLowerCase()) ||
              tipoProduto.contains(palavra.toLowerCase()) ||
              nomeProduto.contains(palavra.toLowerCase())
            );
          }).toList();
          break;
        case 2:
          // Bordas - usar mesmo mapeamento da tela produtos
          produtos = _produtosBanco.where((p) {
            final categoria = p['categoriaNome'].toString().toLowerCase();
            final tipoProduto = p['tipoProduto'].toString().toLowerCase();
            final nomeProduto = p['nome'].toString().toLowerCase();
            
            // Palavras-chave para bordas (mesmo critério da tela produtos)
            final palavrasChaveBorda = ['borda', 'bordas', 'bordas recheadas'];
            
            return palavrasChaveBorda.any((palavra) => 
              categoria.contains(palavra.toLowerCase()) ||
              tipoProduto.contains(palavra.toLowerCase()) ||
              nomeProduto.contains('borda')
            );
          }).toList();
          break;
        default:
          produtos = _produtosBanco;
      }
    } else {
      // Usar dados mockados como fallback
      switch (_tabController.index) {
        case 0:
          produtos = _pizzas;
          break;
        case 1:
          produtos = _bebidas;
          break;
        case 2:
          // Bordas mockadas como fallback
          produtos = [
            {'nome': 'Borda Catupiry', 'preco': 8.0, 'imagem': '🧀'},
            {'nome': 'Borda Chocolate', 'preco': 10.0, 'imagem': '🍫'},
          ];
          break;
        default:
          produtos = _pizzas;
      }
    }
    
    // Filtrar produtos se houver texto de busca
    if (_filtroTexto.isNotEmpty) {
      return produtos.where((produto) {
        return produto['nome'].toLowerCase().contains(_filtroTexto.toLowerCase());
      }).toList();
    }
    
    return produtos;
  }

  bool get _isPizza => _tabController.index == 0;
  
  double get _taxaEntrega {
    switch (_tipoPedido) {
      case 'delivery':
        return _taxaEntregaEditavel;
      case 'balcao':
      case 'mesa':
      default:
        return 0.0;
    }
  }
  
  String get _tempoEstimado {
    switch (_tipoPedido) {
      case 'delivery':
        return '40-60 min';
      case 'balcao':
        return '15-20 min';
      case 'mesa':
        return '20-30 min';
      default:
        return '30 min';
    }
  }
  
  String _getTipoTaxaLabel() {
    switch (_tipoPedido) {
      case 'delivery':
        return 'Taxa entrega:';
      default:
        return 'Taxa:';
    }
  }

  List<String> _getTamanhosDisponiveis() {
    if (_produtoSelecionado == null) return ['P', 'M', 'G', 'F'];
    
    // Verificar se é pizza delivery
    final produtos = _produtosAtuais;
    final produto = produtos.where((p) => p['nome'] == _produtoSelecionado).firstOrNull;
    if (produto != null) {
      final categoriaNome = produto['categoriaNome'] ?? '';
      final isPizzaDelivery = categoriaNome.toLowerCase().contains('delivery');
      
      if (isPizzaDelivery) {
        // Pizza Delivery só tem tamanho médio
        return ['M'];
      }
    }
    
    // Outras pizzas têm todos os tamanhos
    return ['P', 'M', 'G', 'F'];
  }

  double _calcularPreco() {
    if (_produtoSelecionado == null) return 0.0;
    
    final produtos = _produtosAtuais;
    final produto = produtos.where((p) => p['nome'] == _produtoSelecionado).firstOrNull;
    if (produto == null) return 0.0;
    
    double precoBase1 = (produto['preco'] as num).toDouble();
    
    if (_isPizza) {
      // Verificar se é pizza delivery (R$ 40,00 apenas para tamanho médio)
      final categoriaNome = produto['categoriaNome'] ?? '';
      final isPizzaDelivery = categoriaNome.toLowerCase().contains('delivery');
      
      if (isPizzaDelivery) {
        // Pizza Delivery SEMPRE R$ 40,00 (só tem tamanho médio disponível)
        return 40.0 * _quantidade;
      } else {
        // Aplicar multiplicador de tamanho para outras pizzas
        double preco1 = precoBase1 * _multiplicadorTamanho[_tamanhoSelecionado]!;
        
        if (_doisSabores && _sabor2 != null && _sabor2!.isNotEmpty) {
          final produto2 = produtos.where((p) => p['nome'] == _sabor2).firstOrNull;
          if (produto2 != null) {
            double precoBase2 = (produto2['preco'] as num).toDouble();
            double preco2 = precoBase2 * _multiplicadorTamanho[_tamanhoSelecionado]!;
            
            // SEMPRE pegar o MAIOR preço entre os 2 sabores
            double precoFinal = preco1 > preco2 ? preco1 : preco2;
            
            return precoFinal * _quantidade;
          }
        }
        
        return preco1 * _quantidade;
      }
    }
    
    return precoBase1 * _quantidade;
  }

  void _adicionarAoCarrinho() {
    if (_produtoSelecionado == null) return;
    
    HapticFeedback.lightImpact();
    
    String descricao = _produtoSelecionado!;
    if (_isPizza) {
      descricao += ' $_tamanhoSelecionado';
      if (_doisSabores && _sabor2 != null) {
        descricao += ' (½ $_produtoSelecionado + ½ $_sabor2)';
      }
    }
    
    final item = {
      'nome': _produtoSelecionado!,
      'descricao': descricao,
      'preco': _calcularPreco() / _quantidade,
      'quantidade': _quantidade,
      'total': _calcularPreco(),
      'observacao': '', // Campo para observações do item
    };
    
    setState(() {
      _carrinho.add(item);
      _calcularSubtotal();
      _limparSelecao();
    });
  }

  void _calcularSubtotal() {
    _subtotal = _carrinho.fold(0.0, (sum, item) => sum + item['total']);
  }

  void _limparSelecao() {
    _produtoSelecionado = null;
    _tamanhoSelecionado = 'M';
    _doisSabores = false;
    _sabor1 = null;
    _sabor2 = null;
    _quantidade = 1;
  }

  void _removerDoCarrinho(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      // Remover o controller de observações correspondente
      if (_observacoesItemControllers.containsKey(index)) {
        _observacoesItemControllers[index]?.dispose();
        _observacoesItemControllers.remove(index);
      }
      // Reorganizar os controllers restantes
      final novosControllers = <int, TextEditingController>{};
      _observacoesItemControllers.forEach((key, value) {
        if (key > index) {
          novosControllers[key - 1] = value;
        } else if (key < index) {
          novosControllers[key] = value;
        }
      });
      _observacoesItemControllers.clear();
      _observacoesItemControllers.addAll(novosControllers);
      
      _carrinho.removeAt(index);
      _calcularSubtotal();
    });
  }

  void _alterarQuantidadeCarrinho(int index, int novaQuantidade) {
    if (novaQuantidade <= 0) {
      _removerDoCarrinho(index);
      return;
    }
    
    setState(() {
      _carrinho[index]['quantidade'] = novaQuantidade;
      _carrinho[index]['total'] = _carrinho[index]['preco'] * novaQuantidade;
      _calcularSubtotal();
    });
  }

  /// Prepara dados do pedido para impressão
  Map<String, dynamic> _prepararDadosPedido() {
    final agora = DateTime.now();
    final numeroPedido = '${agora.millisecondsSinceEpoch}'.substring(7); // Últimos 6 dígitos
    
    return {
      'numeroPedido': numeroPedido.padLeft(6, '0'),
      'dataPedido': agora,
      'nomeCliente': _clienteController.text.trim().isEmpty 
          ? 'Cliente não informado' 
          : _clienteController.text.trim(),
      'telefoneCliente': null, // Adicionar campo se necessário
      'enderecoCliente': _tipoPedido == 'delivery' 
          ? _enderecoController.text.trim() 
          : null,
      'itens': _carrinho,
      'subtotal': _subtotal,
      'taxaEntrega': _taxaEntrega,
      'total': _subtotal + _taxaEntrega,
      'formaPagamento': 'A definir', // Adicionar seleção se necessário
      'observacoesPedido': _observacoesController.text.trim().isEmpty 
          ? null 
          : _observacoesController.text.trim(),
    };
  }

  /// Imprime a comanda do pedido
  Future<void> _imprimirComanda() async {
    if (_carrinho.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Carrinho vazio - adicione itens primeiro'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      if (!mounted) return;
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Preparando impressão...'),
            ],
          ),
        ),
      );

      // Preparar dados
      final dados = _prepararDadosPedido();
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Fechar loading
      
      // Imprimir
      final sucesso = await ImpressaoService.imprimirComanda(
        numeroPedido: dados['numeroPedido'],
        dataPedido: dados['dataPedido'],
        nomeCliente: dados['nomeCliente'],
        telefoneCliente: dados['telefoneCliente'],
        enderecoCliente: dados['enderecoCliente'],
        itens: dados['itens'],
        subtotal: dados['subtotal'],
        taxaEntrega: dados['taxaEntrega'],
        total: dados['total'],
        formaPagamento: dados['formaPagamento'],
        observacoesPedido: dados['observacoesPedido'],
      );
      
      if (!mounted) return;
      if (sucesso) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comanda impressa com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao imprimir comanda - tente novamente'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Fechar loading se estiver aberto
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                _buildColunaSelecao(),
                _buildColunaConfiguracao(),
                _buildColunaCarrinho(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Novo Pedido #000123',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          // Botão de debug para testar API
          IconButton(
            icon: const Icon(Icons.bug_report, size: 20),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Executando diagnóstico... Verifique o console'),
                  duration: Duration(seconds: 2),
                ),
              );
              await _carregarProdutos();
            },
            tooltip: 'Debug API',
          ),
          const SizedBox(width: 8),
          Text(
            'Total: R\$ ${(_subtotal + _taxaEntrega).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColunaSelecao() {
    return Expanded(
      flex: 45, // Aumentado de 40% para 45%
      child: Container(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Column(
          children: [
            _buildBuscaCliente(),
            _buildSeletorTipoPedido(),
            _buildCamposEspecificos(),
            _buildTabs(),
            _buildBuscaProduto(),
            Expanded(child: _buildGridProdutos()),
          ],
        ),
      ),
    );
  }

  Widget _buildBuscaCliente() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _clienteController,
        decoration: const InputDecoration(
          hintText: '🔍 Cliente (opcional)',
          border: OutlineInputBorder(borderSide: BorderSide.none),
          filled: true,
          fillColor: Color(0xFFF5F5F5),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSeletorTipoPedido() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de Pedido:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBotaoTipoPedido('delivery', '🚚', 'Delivery'),
              const SizedBox(width: 8),
              _buildBotaoTipoPedido('balcao', '🏪', 'Balcão'),
              const SizedBox(width: 8),
              _buildBotaoTipoPedido('mesa', '🪑', 'Mesa'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoTipoPedido(String tipo, String emoji, String label) {
    final isSelected = _tipoPedido == tipo;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _tipoPedido = tipo;
            _calcularSubtotal(); // Recalcular com nova taxa
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.red : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.red : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCamposEspecificos() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_tipoPedido == 'delivery') ...[
            _buildCampoTexto(
              controller: _enderecoController,
              label: '📍 Endereço de Entrega',
              hint: 'Rua, número, bairro...',
              obrigatorio: true,
            ),
            const SizedBox(height: 12),
            _buildCampoTexto(
              controller: _observacoesController,
              label: '📝 Observações de Entrega',
              hint: 'Complemento, referência...',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Tempo estimado: $_tempoEstimado',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_tipoPedido == 'balcao') ...[
            _buildCampoTexto(
              controller: _nomeRetiradaController,
              label: '👤 Nome para Retirada',
              hint: 'Nome do cliente...',
              obrigatorio: true,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Tempo estimado: $_tempoEstimado',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_tipoPedido == 'mesa') ...[
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🪑 Mesa',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<int>(
                        value: _mesaSelecionada,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: List.generate(10, (index) => index + 1).map((mesa) {
                          return DropdownMenuItem<int>(
                            value: mesa,
                            child: Text('Mesa $mesa'),
                          );
                        }).toList(),
                        onChanged: (valor) {
                          setState(() => _mesaSelecionada = valor!);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _buildCampoTexto(
                    controller: _nomeGarcomController,
                    label: '👨‍💼 Garçom (opcional)',
                    hint: 'Nome do garçom...',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Tempo estimado: $_tempoEstimado',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCampoTexto({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obrigatorio = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label${obrigatorio ? ' *' : ''}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: obrigatorio ? Colors.red.shade700 : Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      onTap: (_) => setState(() {
        _limparSelecao();
        _filtroTexto = '';
        _buscaProdutoController.clear();
      }),
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.red,
      indicatorWeight: 2,
      tabs: const [
        Tab(text: 'Pizzas'),
        Tab(text: 'Bebidas'),
        Tab(text: 'Bordas'),
      ],
    );
  }

  Widget _buildBuscaProduto() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _buscaProdutoController,
              decoration: InputDecoration(
                hintText: '🔍 Buscar produtos...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                suffixIcon: _filtroTexto.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            _filtroTexto = '';
                            _buscaProdutoController.clear();
                          });
                        },
                      )
                    : const Icon(Icons.search, color: Colors.grey),
              ),
              onChanged: (texto) {
                setState(() {
                  _filtroTexto = texto;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _produtosBanco.isNotEmpty ? Icons.cloud_done : Icons.cloud_off,
                  size: 16, 
                  color: _produtosBanco.isNotEmpty ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_produtosAtuais.length} items ${_produtosBanco.isNotEmpty ? '(DB)' : '(Mock)'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _produtosBanco.isNotEmpty ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridProdutos() {
    if (_carregandoProdutos) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Carregando produtos...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    final produtos = _produtosAtuais;
    
    if (produtos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum produto encontrado',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _produtosBanco.isEmpty 
                  ? 'Erro ao carregar do banco de dados'
                  : 'Tente buscar por outro termo',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            if (_produtosBanco.isEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _carregarProdutos,
                child: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Aumentado de 2 para 3 (cards menores)
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.9, // Ajustado para cards menores
      ),
      itemCount: produtos.length,
      itemBuilder: (context, index) {
        final produto = produtos[index];
        final isSelected = _produtoSelecionado == produto['nome'];
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _produtoSelecionado = produto['nome'];
              if (_isPizza) {
                _sabor1 = produto['nome'];
                
                // Se for Pizza Delivery, forçar tamanho médio
                final categoriaNome = produto['categoriaNome'] ?? '';
                final isPizzaDelivery = categoriaNome.toLowerCase().contains('delivery');
                if (isPizzaDelivery) {
                  _tamanhoSelecionado = 'M';
                }
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? Colors.red.withValues(alpha: 0.08) : Colors.white,
              border: Border.all(
                color: isSelected ? Colors.red : Colors.grey.shade200,
                width: isSelected ? 2.5 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (isSelected) ...[
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] else ...[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    produto['imagem'],
                    style: const TextStyle(fontSize: 32), // Reduzido de 48 para 32
                  ),
                  const SizedBox(height: 6), // Reduzido de 8 para 6
                  Text(
                    produto['nome'],
                    style: const TextStyle(
                      fontSize: 12, // Reduzido de 16 para 12
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Tag Pizza Promocional para Pizza Delivery
                  if (produto['categoriaNome']?.toLowerCase()?.contains('delivery') == true) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'PROMOCIONAL',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${produto['preco'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12, // Reduzido de 14 para 12
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColunaConfiguracao() {
    return Expanded(
      flex: 30, // Mantido em 30%
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: _produtoSelecionado == null
            ? const Center(
                child: Text(
                  'Selecione um produto',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _produtoSelecionado!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isPizza) ...[
                    _buildSeletorTamanho(),
                    const SizedBox(height: 24),
                    _buildToggleDoisSabores(),
                    if (_doisSabores) ...[
                      const SizedBox(height: 16),
                      _buildSeletorSabores(),
                    ],
                    const SizedBox(height: 24),
                  ],
                  _buildSeletorQuantidade(),
                  const Spacer(),
                  _buildBotaoAdicionar(),
                ],
              ),
      ),
    );
  }

  Widget _buildSeletorTamanho() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tamanho',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: _getTamanhosDisponiveis().map((tamanho) {
            final isSelected = _tamanhoSelecionado == tamanho;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _tamanhoSelecionado = tamanho);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.red : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tamanho,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildToggleDoisSabores() {
    return Row(
      children: [
        Switch(
          value: _doisSabores,
          onChanged: (value) {
            HapticFeedback.selectionClick();
            setState(() {
              _doisSabores = value;
              if (!value) {
                _sabor2 = null;
              }
            });
          },
          activeColor: Colors.red,
        ),
        const SizedBox(width: 8),
        const Text(
          'Pizza 2 Sabores',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSeletorSabores() {
    // Pegar apenas as pizzas disponíveis
    final pizzasDisponiveis = _produtosBanco.isNotEmpty 
        ? _produtosBanco.where((p) {
            final categoria = p['categoriaNome'].toString().toLowerCase();
            final tipoProduto = p['tipoProduto'].toString().toLowerCase();
            final nomeProduto = p['nome'].toString().toLowerCase();
            
            final palavrasChavePizza = ['pizza', 'pizzas especiais', 'pizzas salgadas', 'pizzas doces'];
            
            return palavrasChavePizza.any((palavra) => 
              categoria.contains(palavra.toLowerCase()) ||
              tipoProduto.contains(palavra.toLowerCase()) ||
              nomeProduto.contains('pizza')
            );
          }).toList()
        : _pizzas;

    return Column(
      children: [
        _buildDropdownSabor('Metade 1', _sabor1, pizzasDisponiveis, (valor) {
          setState(() => _sabor1 = valor);
        }),
        const SizedBox(height: 12),
        _buildDropdownSabor('Metade 2', _sabor2, pizzasDisponiveis, (valor) {
          setState(() => _sabor2 = valor);
        }),
      ],
    );
  }

  Widget _buildDropdownSabor(String label, String? valor, List<Map<String, dynamic>> pizzasDisponiveis, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        _buildSearchableDropdown(
          value: valor,
          items: pizzasDisponiveis,
          onChanged: onChanged,
          hint: 'Buscar e selecionar pizza...',
        ),
      ],
    );
  }

  Widget _buildSearchableDropdown({
    required String? value,
    required List<Map<String, dynamic>> items,
    required Function(String?) onChanged,
    required String hint,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        onTap: () => _showSearchablePizzaDialog(items, onChanged, value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value ?? hint,
                  style: TextStyle(
                    fontSize: 12,
                    color: value != null ? Colors.black : Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.search, size: 16, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchablePizzaDialog(List<Map<String, dynamic>> pizzas, Function(String?) onChanged, String? currentValue) {
    String filtro = '';
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final pizzasFiltradas = filtro.isEmpty
                ? pizzas
                : pizzas.where((p) => 
                    p['nome'].toString().toLowerCase().contains(filtro.toLowerCase())
                  ).toList();

            return AlertDialog(
              title: const Text('Selecionar Pizza', style: TextStyle(fontSize: 16)),
              contentPadding: const EdgeInsets.all(16),
              content: SizedBox(
                width: 300,
                height: 400,
                child: Column(
                  children: [
                    // Campo de busca
                    TextField(
                      decoration: const InputDecoration(
                        hintText: '🔍 Buscar pizza...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          filtro = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Lista de pizzas
                    Expanded(
                      child: pizzasFiltradas.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhuma pizza encontrada',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: pizzasFiltradas.length,
                              itemBuilder: (context, index) {
                                final pizza = pizzasFiltradas[index];
                                final isSelected = currentValue == pizza['nome'];
                                
                                return ListTile(
                                  dense: true,
                                  leading: Text(
                                    pizza['imagem'] ?? '🍕',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  title: Text(
                                    pizza['nome'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.red : Colors.black,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'R\$ ${pizza['preco'].toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: isSelected 
                                      ? const Icon(Icons.check_circle, color: Colors.red, size: 20)
                                      : null,
                                  onTap: () {
                                    onChanged(pizza['nome']);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                if (currentValue != null)
                  TextButton(
                    onPressed: () {
                      onChanged(null);
                      Navigator.pop(context);
                    },
                    child: const Text('Limpar'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSeletorQuantidade() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quantidade',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: _quantidade > 1
                  ? () {
                      HapticFeedback.selectionClick();
                      setState(() => _quantidade--);
                    }
                  : null,
              icon: const Icon(Icons.remove),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _quantidade.toString(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _quantidade++);
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Preço: R\$ ${_calcularPreco().toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoAdicionar() {
    final canAdd = _produtoSelecionado != null && (!_doisSabores || _sabor2 != null);
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canAdd ? _adicionarAoCarrinho : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '+ Adicionar ao Carrinho',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildColunaCarrinho() {
    return Expanded(
      flex: 25, // Diminuído de 30% para 25%
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Carrinho',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: _carrinho.isEmpty
                  ? const Center(
                      child: Text(
                        '(vazio)',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _carrinho.length,
                      itemBuilder: (context, index) {
                        final item = _carrinho[index];
                        return _buildItemCarrinho(item, index);
                      },
                    ),
            ),
            _buildRodapeCarrinho(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCarrinho(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['descricao'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${item['preco'].toStringAsFixed(2)} cada',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removerDoCarrinho(index),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Campo de observações
          TextField(
            controller: _observacoesItemControllers.putIfAbsent(
              index,
              () => TextEditingController(text: item['observacao'] ?? ''),
            ),
            decoration: InputDecoration(
              hintText: 'Ex: Sem cebola, bem assada...',
              labelText: 'Observações',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
            ),
            maxLines: 2,
            style: const TextStyle(fontSize: 13),
            onChanged: (value) {
              item['observacao'] = value;
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: () => _alterarQuantidadeCarrinho(index, item['quantidade'] - 1),
                icon: const Icon(Icons.remove, size: 16),
              ),
              Text(item['quantidade'].toString()),
              IconButton(
                onPressed: () => _alterarQuantidadeCarrinho(index, item['quantidade'] + 1),
                icon: const Icon(Icons.add, size: 16),
              ),
              const Spacer(),
              Text(
                'R\$ ${item['total'].toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRodapeCarrinho() {
    final taxaAtual = _taxaEntrega;
    final total = _subtotal + taxaAtual;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:'),
              Text('R\$ ${_subtotal.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 4),
          if (taxaAtual > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_getTipoTaxaLabel()),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: _taxaEntregaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      prefixText: 'R\$ ',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (value) {
                      final cleanValue = value.replaceAll(',', '.');
                      final newValue = double.tryParse(cleanValue);
                      if (newValue != null && newValue >= 0 && newValue <= 20) {
                        setState(() {
                          _taxaEntregaEditavel = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'R\$ ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _carrinho.isNotEmpty ? _imprimirComanda : null,
                  child: const Text('Imprimir'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _carrinho.isNotEmpty && _validarPedido()
                      ? () {
                          HapticFeedback.lightImpact();
                          _salvarPedido();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Salvar Pedido'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _validarPedido() {
    switch (_tipoPedido) {
      case 'delivery':
        return _enderecoController.text.trim().isNotEmpty;
      case 'balcao':
        return _nomeRetiradaController.text.trim().isNotEmpty;
      case 'mesa':
        return true; // Mesa sempre válida (já tem mesa selecionada)
      default:
        return true;
    }
  }

  Future<void> _salvarPedido() async {
    if (_carrinho.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um item ao pedido'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Preparar dados do pedido para o banco
      final agora = DateTime.now();
      final numeroPedido = '${agora.millisecondsSinceEpoch}'.substring(7).padLeft(6, '0');
      
      String nomeCliente = _clienteController.text.trim();
      if (nomeCliente.isEmpty) {
        nomeCliente = _tipoPedido == 'balcao' ? _nomeRetiradaController.text.trim() : 'Cliente não informado';
      }

      // Definir tipo do pedido baseado na seleção
      String tipoPedidoDb;
      switch (_tipoPedido) {
        case 'delivery':
          tipoPedidoDb = 'entrega';
          break;
        case 'balcao':
          tipoPedidoDb = 'balcao';
          break;
        case 'mesa':
          tipoPedidoDb = 'balcao'; // Mesa será tratado como balcão no banco
          break;
        default:
          tipoPedidoDb = 'balcao';
      }

      // Preparar observações
      String observacoes = '';
      if (_observacoesController.text.trim().isNotEmpty) {
        observacoes = _observacoesController.text.trim();
      }
      if (_tipoPedido == 'delivery' && _enderecoController.text.trim().isNotEmpty) {
        observacoes += '\nEndereço: ${_enderecoController.text.trim()}';
      }
      if (_tipoPedido == 'mesa') {
        observacoes += '\nMesa: $_mesaSelecionada';
        if (_nomeGarcomController.text.trim().isNotEmpty) {
          observacoes += '\nGarçom: ${_nomeGarcomController.text.trim()}';
        }
      }

      final supabase = Supabase.instance.client;

      // Preparar dados básicos do pedido compatíveis com estrutura existente
      final pedidoData = <String, dynamic>{
        'numero': numeroPedido,
        'subtotal': _subtotal,
        'total': _subtotal + (_tipoPedido == 'delivery' ? _taxaEntregaEditavel : 0.0),
        'status': 'aberto', // Status simplificado
        'data_hora_criacao': agora.toIso8601String(),
      };

      // Adicionar colunas opcionais apenas se existirem na tabela
      try {
        // Verificar estrutura da tabela primeiro
        final estrutura = await supabase
            .from('pedidos')
            .select('*')
            .limit(1)
            .maybeSingle();

        if (estrutura != null) {
          // Adicionar colunas baseado na estrutura existente
          final colunas = estrutura.keys.toSet();
          
          if (colunas.contains('cliente_id')) pedidoData['cliente_id'] = null;
          if (colunas.contains('endereco_id')) pedidoData['endereco_id'] = null;
          if (colunas.contains('mesa_id')) pedidoData['mesa_id'] = _tipoPedido == 'mesa' ? _mesaSelecionada : null;
          if (colunas.contains('taxa_entrega')) pedidoData['taxa_entrega'] = _tipoPedido == 'delivery' ? _taxaEntregaEditavel : 0.0;
          if (colunas.contains('desconto')) pedidoData['desconto'] = 0.0;
          if (colunas.contains('forma_pagamento')) pedidoData['forma_pagamento'] = 'Dinheiro';
          if (colunas.contains('tipo')) pedidoData['tipo'] = tipoPedidoDb;
          if (colunas.contains('observacoes')) pedidoData['observacoes'] = observacoes.trim().isEmpty ? null : observacoes.trim();
          if (colunas.contains('data_hora_atualizacao')) pedidoData['data_hora_atualizacao'] = agora.toIso8601String();
          if (colunas.contains('nome_cliente')) pedidoData['nome_cliente'] = nomeCliente;
          if (colunas.contains('telefone_cliente')) pedidoData['telefone_cliente'] = null;
        }
      } catch (e) {
        print('Aviso: Não foi possível verificar estrutura da tabela: $e');
      }

      // Inserir pedido
      final pedidoResponse = await supabase
          .from('pedidos')
          .insert(pedidoData)
          .select()
          .single();

      final pedidoId = pedidoResponse['id'];

      // Tentar inserir itens se a tabela existe
      try {
        final itensData = _carrinho.map((item) {
          return {
            'pedido_id': pedidoId,
            'nome_item': item['nome'],
            'quantidade': item['quantidade'],
            'preco_unitario': item['preco'] ?? (item['total'] / item['quantidade']),
            'subtotal': item['total'],
            'observacoes': item['observacao'] ?? '',
            'tamanho': _tamanhoSelecionado,
            'sabores': item['descricao'] ?? '',
          };
        }).toList();

        await supabase.from('pedido_itens').insert(itensData);
        print('✅ Itens do pedido salvos com sucesso');
      } catch (e) {
        print('⚠️ Aviso: Itens não puderam ser salvos - tabela pedido_itens pode não existir: $e');
        // Continuar mesmo se não conseguir salvar os itens
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // Fechar loading

      // Mostrar sucesso e voltar para tela anterior
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getMensagemSucesso()),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Ir para tela de caixa para mostrar o pedido no fechamento
      Navigator.of(context).pushReplacementNamed('/caixa');
      
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Fechar loading
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar pedido: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  String _getMensagemSucesso() {
    switch (_tipoPedido) {
      case 'delivery':
        return 'Pedido de delivery criado! Tempo estimado: $_tempoEstimado';
      case 'balcao':
        return 'Pedido para retirada no balcão criado! Tempo: $_tempoEstimado';
      case 'mesa':
        return 'Pedido da Mesa $_mesaSelecionada criado! Tempo: $_tempoEstimado';
      default:
        return 'Pedido finalizado com sucesso!';
    }
  }
}