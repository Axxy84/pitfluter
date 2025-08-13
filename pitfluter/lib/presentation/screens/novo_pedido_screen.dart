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
  final TextEditingController _nomeClienteController = TextEditingController();
  final TextEditingController _telefoneClienteController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _nomeRetiradaController = TextEditingController();
  final TextEditingController _nomeGarcomController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();
  final TextEditingController _buscaProdutoController = TextEditingController();
  final TextEditingController _taxaEntregaController =
      TextEditingController(text: '2.00');
  final Map<int, TextEditingController> _observacoesItemControllers = {};

  String _tipoPedido = 'delivery';
  int _mesaSelecionada = 1;

  // Variáveis para forma de pagamento
  String _formaPagamento = 'dinheiro';
  final TextEditingController _valorPagoController = TextEditingController();
  double _troco = 0.0;
  
  // Estado de seleção intuitiva para multi-sabores
  final Map<String, Map<String, dynamic>> _selecoesAtuais = {}; // key: tamanho, value: {pizzas: [nomes], preco: double}
  String? _tamanhoSelecionandoAtual;

  final List<Map<String, dynamic>> _carrinho = [];
  double _subtotal = 0.0;
  double _taxaEntregaEditavel = 2.0;
  String _filtroTexto = '';
  bool _carregandoProdutos = false;
  List<Map<String, dynamic>> _produtosBanco = [];
  List<Map<String, dynamic>> _bordasBanco = [];

  // Removido multiplicadores - agora usa preços específicos do banco

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
    _tabController =
        TabController(length: 4, vsync: this); // Pizza Delivery, Pizzas, Bebidas, Bordas
    _carregarProdutos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeClienteController.dispose();
    _telefoneClienteController.dispose();
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
  
  /// Limpa seleções atuais
  void _limparSelecoes() {
    setState(() {
      _selecoesAtuais.clear();
      _tamanhoSelecionandoAtual = null;
    });
  }
  
  /// Obtém o estado de seleção de um botão de preço
  String _getEstadoSelecao(String nomePizza, String tamanho) {
    final selecao = _selecoesAtuais[tamanho];
    if (selecao == null) return 'none';
    
    final pizzas = selecao['pizzas'] as List<String>;
    if (pizzas.contains(nomePizza)) {
      return pizzas.length == 1 ? 'single' : 'multi';
    }
    return 'none';
  }
  
  /// Processa clique em um botão de preço
  void _processarClique(String nomePizza, String ingredientes, String tamanho, double preco, bool isDelivery) {
    final maxSabores = tamanho == 'F' ? 3 : 2;
    
    HapticFeedback.lightImpact(); // Feedback tátil
    
    setState(() {
      // Se não há seleção para este tamanho, criar nova
      if (!_selecoesAtuais.containsKey(tamanho)) {
        _selecoesAtuais[tamanho] = {
          'pizzas': [nomePizza],
          'preco_base': preco,
          'is_delivery': isDelivery,
          'ingredientes': {nomePizza: ingredientes},
        };
        _tamanhoSelecionandoAtual = tamanho;
      } else {
        final selecao = _selecoesAtuais[tamanho]!;
        final pizzas = selecao['pizzas'] as List<String>;
        final ingredientesMap = selecao['ingredientes'] as Map<String, String>;
        
        if (pizzas.contains(nomePizza)) {
          // Se já está selecionada, remover
          pizzas.remove(nomePizza);
          ingredientesMap.remove(nomePizza);
          
          // Se não sobrou nenhuma pizza, remover a seleção
          if (pizzas.isEmpty) {
            _selecoesAtuais.remove(tamanho);
            _tamanhoSelecionandoAtual = null;
          }
        } else {
          // Adicionar nova pizza se não exceder o limite
          if (pizzas.length < maxSabores) {
            pizzas.add(nomePizza);
            ingredientesMap[nomePizza] = ingredientes;
            
            // Atualizar preço baseado no maior preço selecionado
            double maiorPreco = preco;
            
            // Encontrar o maior preço entre as pizzas selecionadas
            for (final pizzaNome in pizzas) {
              // Para delivery Grande, sempre R$ 40
              if (isDelivery && tamanho == 'G') {
                maiorPreco = 40.0;
                break;
              }
              
              // Para outras pizzas, buscar o preço no produto
              final produtos = _produtosAtuais;
              final produto = produtos.firstWhere(
                (p) => p['nome'] == pizzaNome,
                orElse: () => {'precosMap': <String, double>{}},
              );
              final precosMap = produto['precosMap'] as Map<String, double>? ?? {};
              final precoSabor = precosMap[tamanho] ?? preco;
              if (precoSabor > maiorPreco) {
                maiorPreco = precoSabor;
              }
            }
            
            selecao['preco_base'] = maiorPreco;
          } else {
            // Mostrar aviso de limite
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Máximo $maxSabores sabores para tamanho ${_getNomeTamanho(tamanho)}'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
            return; // Sair sem atualizar estado
          }
        }
      }
    });
    
    // Se há seleção ativa, mostrar botão de confirmação
    if (_selecoesAtuais.containsKey(tamanho)) {
      _mostrarBotaoConfirmacao(tamanho);
    }
  }
  
  /// Obtém cor de fundo baseada no estado de seleção
  Color _getCorSelecao(String estado, bool isDelivery) {
    switch (estado) {
      case 'single':
        return isDelivery ? Colors.green.withValues(alpha: 0.3) : Colors.blue.withValues(alpha: 0.3);
      case 'multi':
        return Colors.orange.withValues(alpha: 0.3);
      default:
        return isDelivery ? Colors.green.withValues(alpha: 0.1) : Theme.of(context).primaryColor.withValues(alpha: 0.1);
    }
  }
  
  /// Obtém cor da borda baseada no estado de seleção
  Color _getCorBordaSelecao(String estado, bool isDelivery) {
    switch (estado) {
      case 'single':
        return isDelivery ? Colors.green : Colors.blue;
      case 'multi':
        return Colors.orange;
      default:
        return isDelivery ? Colors.green : Theme.of(context).primaryColor;
    }
  }
  
  /// Obtém cor do texto baseada no estado de seleção
  Color _getCorTextoSelecao(String estado, bool isDelivery) {
    switch (estado) {
      case 'single':
        return isDelivery ? Colors.green : Colors.blue;
      case 'multi':
        return Colors.orange;
      default:
        return isDelivery ? Colors.green : Theme.of(context).primaryColor;
    }
  }
  
  /// Mostra botão flutuante de confirmação para o tamanho selecionado
  void _mostrarBotaoConfirmacao(String tamanho) {
    setState(() {
      _tamanhoSelecionandoAtual = tamanho;
    });
    
    // Timer para remover destaque do botão
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _tamanhoSelecionandoAtual == tamanho) {
        setState(() {
          _tamanhoSelecionandoAtual = null;
        });
      }
    });
  }
  
  /// Modal super simplificado
  void _mostrarModalConfirmacao(String tamanho) {
    final selecao = _selecoesAtuais[tamanho]!;
    final pizzas = selecao['pizzas'] as List<String>;
    final precoBase = selecao['preco_base'] as double;
    
    int quantidade = 1;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final precoTotal = precoBase * quantidade;
            final nomePizza = pizzas.length == 1 ? pizzas.first : pizzas.join(' + ');
            
            return AlertDialog(
              title: Text(
                pizzas.length == 1 ? 'Pizza Inteira' : 'Pizza Mista',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pizza e tamanho
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$nomePizza (${_getNomeTamanho(tamanho)})',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Quantidade
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Qtd:', style: TextStyle(fontSize: 18)),
                      IconButton(
                        onPressed: quantidade > 1 ? () => setModalState(() => quantidade--) : null,
                        icon: const Icon(Icons.remove_circle, size: 24),
                      ),
                      Text(
                        quantidade.toString(),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => setModalState(() => quantidade++),
                        icon: const Icon(Icons.add_circle, size: 24),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Total
                  Text(
                    'Total: R\$ ${precoTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _limparSelecoes();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _adicionarSelecaoAoCarrinho(tamanho, quantidade, precoTotal);
                    Navigator.pop(context);
                    _limparSelecoes();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  /// Adiciona a seleção atual ao carrinho
  void _adicionarSelecaoAoCarrinho(String tamanho, int quantidade, double precoTotal) {
    final selecao = _selecoesAtuais[tamanho]!;
    final pizzas = selecao['pizzas'] as List<String>;
    final precoUnitario = precoTotal / quantidade;
    
    HapticFeedback.lightImpact();
    
    String descricao;
    if (pizzas.length == 1) {
      descricao = '${pizzas.first} $tamanho';
    } else {
      descricao = '${pizzas.join(' + ')} $tamanho';
    }
    
    final item = {
      'nome': pizzas.first,
      'descricao': descricao,
      'preco': precoUnitario,
      'quantidade': quantidade,
      'total': precoTotal,
      'observacao': '',
    };
    
    setState(() {
      _carrinho.add(item);
      _calcularSubtotal();
    });
    
    // Confirmação
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$descricao adicionado ao carrinho!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
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
      final produtosResponse = await supabase.from('produtos').select('''
            *,
            produtos_precos (
              preco,
              preco_promocional,
              tamanho_id,
              tamanhos (
                nome
              )
            ),
            categorias (
              id,
              nome
            )
          ''').eq('ativo', true).order('nome');

      // Query para bordas recheadas
      final bordasResponse = await supabase.from('bordas_recheadas').select('''
            id,
            nome,
            descricao,
            preco,
            tipo,
            ativo
          ''').eq('ativo', true).order('nome');

      setState(() {
        // Processar bordas
        _bordasBanco = bordasResponse.map((borda) {
          return {
            'id': borda['id'],
            'nome': borda['nome'] as String,
            'descricao': borda['descricao'] ?? '',
            'preco': (borda['preco'] as num).toDouble(),
            'tipo': borda['tipo'] ?? 'salgada',
            'categoriaId': 999, // ID fictício para bordas
            'categoriaNome': 'Bordas Recheadas',
            'imagemUrl': null,
            'imagem': borda['tipo'] == 'doce' ? '🍫' : '🧀',
            'tipoProduto': 'borda',
          };
        }).toList();
        _produtosBanco = produtosResponse.map((produto) {
          // Usar categorias ao invés de produtos_categoria
          final categoria = produto['categorias'];
          final categoriaNome = categoria?['nome'] ?? 'Outros';

          // Processar preços por tamanho
          final precos = produto['produtos_precos'] as List? ?? [];
          final precosMap = <String, double>{};
          
          for (final preco in precos) {
            final tamanhoInfo = preco['tamanhos'] as Map<String, dynamic>?;
            final tamanhoNome = tamanhoInfo?['nome'] as String?;
            
            // Mapear nome do tamanho para abreviação
            String tamanhoAbrev = '';
            if (tamanhoNome != null) {
              switch (tamanhoNome.toLowerCase()) {
                case 'pequena':
                  tamanhoAbrev = 'P';
                  break;
                case 'média':
                  tamanhoAbrev = 'M';
                  break;
                case 'grande':
                  tamanhoAbrev = 'G';
                  break;
                case 'família':
                  tamanhoAbrev = 'F';
                  break;
              }
            }
            
            if (tamanhoAbrev.isNotEmpty) {
              final precoValor = (preco['preco_promocional'] ?? preco['preco'] ?? 0.0) as num;
              precosMap[tamanhoAbrev] = precoValor.toDouble();
            }
          }

          return {
            'id': produto['id'],
            'nome': produto['nome'] as String,
            'descricao': produto['descricao'] ?? produto['ingredientes'] ?? '',
            'precosMap': precosMap,
            'preco': precosMap['M'] ?? 40.0, // Usar preço médio como padrão
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
            content:
                Text('Erro ao carregar produtos: $e\nUsando dados de exemplo.'),
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
    } else if (cat.contains('bebida') ||
        cat.contains('drink') ||
        cat.contains('cerveja') ||
        cat.contains('refrigerante')) {
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
          // Pizza Delivery (R$ 40,00) - apenas pizzas da categoria "Pizza Delivery"
          produtos = _produtosBanco.where((p) {
            final categoria = p['categoriaNome'].toString().toLowerCase();
            return categoria.contains('pizza delivery');
          }).toList();
          break;
        case 1:
          // Pizzas normais - APENAS pizzas, excluindo delivery e bebidas
          produtos = _produtosBanco.where((p) {
            final categoria = p['categoriaNome'].toString().toLowerCase();
            
            // Filtro MUITO específico: apenas categorias que são claramente pizzas
            final categoriasPizzasPermitidas = [
              'pizzas salgadas',
              'pizzas doces', 
              'pizzas especiais',
              'pizza tradicional',
              'pizza salgada',
              'pizza doce',
              'pizzas'
            ];
            
            // Primeiro: verificar se está numa categoria de pizza permitida
            final isCategoriaPizza = categoriasPizzasPermitidas.any((catPizza) =>
                categoria == catPizza || categoria.contains(catPizza));
            
            // Segundo: excluir explicitamente delivery
            final isDelivery = categoria.contains('delivery');
            
            // Terceiro: excluir explicitamente bebidas/outros
            final categoriasProibidas = [
              'bebida',
              'bebidas',
              'refrigerante', 
              'suco',
              'borda',
              'bordas',
              'sobremesa',
              'sobremesas'
            ];
            
            final isCategoriaProibida = categoriasProibidas.any((catProibida) =>
                categoria.contains(catProibida));
            
            // Retornar apenas se: É pizza E não é delivery E não é categoria proibida
            return isCategoriaPizza && !isDelivery && !isCategoriaProibida;
          }).toList();
          break;
        case 2:
          // Bebidas - usar mesmo mapeamento da tela produtos
          produtos = _produtosBanco.where((p) {
            final categoria = p['categoriaNome'].toString().toLowerCase();
            final tipoProduto = p['tipoProduto'].toString().toLowerCase();
            final nomeProduto = p['nome'].toString().toLowerCase();

            // Palavras-chave para bebidas (mesmo critério da tela produtos)
            final palavrasChaveBebida = [
              'bebida',
              'bebidas',
              'drink',
              'drinks',
              'cerveja',
              'cervejas',
              'refrigerante',
              'suco'
            ];

            return palavrasChaveBebida.any((palavra) =>
                categoria.contains(palavra.toLowerCase()) ||
                tipoProduto.contains(palavra.toLowerCase()) ||
                nomeProduto.contains(palavra.toLowerCase()));
          }).toList();
          break;
        case 3:
          // Bordas - usar dados específicos da tabela bordas_recheadas
          produtos = _bordasBanco;
          break;
        default:
          produtos = _produtosBanco;
      }
    } else {
      // Usar dados mockados como fallback
      switch (_tabController.index) {
        case 0:
          // Pizza Delivery mockada
          produtos = [
            {'nome': 'Marguerita (Delivery)', 'preco': 40.0, 'imagem': '🍕'},
            {'nome': 'Calabresa (Delivery)', 'preco': 40.0, 'imagem': '🍕'},
            {'nome': 'Frango Catupiry (Delivery)', 'preco': 40.0, 'imagem': '🍕'},
          ];
          break;
        case 1:
          produtos = _pizzas;
          break;
        case 2:
          produtos = _bebidas;
          break;
        case 3:
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
      final produtosFiltrados = produtos.where((produto) {
        return produto['nome']
            .toLowerCase()
            .contains(_filtroTexto.toLowerCase());
      }).toList();
      // Ordenar alfabeticamente após filtro
      produtosFiltrados.sort((a, b) => a['nome'].toString().compareTo(b['nome'].toString()));
      return produtosFiltrados;
    }

    // Ordenar todos os produtos alfabeticamente
    produtos.sort((a, b) => a['nome'].toString().compareTo(b['nome'].toString()));
    return produtos;
  }


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



  void _calcularSubtotal() {
    _subtotal = _carrinho.fold(0.0, (sum, item) => sum + item['total']);
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
    final numeroPedido =
        '${agora.millisecondsSinceEpoch}'.substring(7); // Últimos 6 dígitos

    return {
      'numeroPedido': numeroPedido.padLeft(6, '0'),
      'dataPedido': agora,
      'informacoesEntrega': _tipoPedido == 'delivery' 
          ? _enderecoController.text.trim() 
          : _tipoPedido == 'balcao' 
            ? 'Retirada no balcão - ${_nomeRetiradaController.text.trim()}'
            : 'Mesa $_mesaSelecionada',
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

  /// Imprime a comanda da cozinha (sem valores)
  Future<void> _imprimirComandaCozinha() async {
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
              Text('Preparando comanda da cozinha...'),
            ],
          ),
        ),
      );

      // Preparar dados específicos para cozinha
      final dados = _prepararDadosPedido();

      if (!mounted) return;
      Navigator.of(context).pop(); // Fechar loading

      // Imprimir comanda da cozinha
      final sucesso = await ImpressaoService.imprimirComandaCozinha(
        numeroPedido: dados['numeroPedido'],
        dataPedido: dados['dataPedido'],
        itens: _carrinho,
        tipoPedido: _tipoPedido,
        mesa: _tipoPedido == 'mesa' ? _mesaSelecionada.toString() : null,
        cliente: _tipoPedido == 'delivery' ? _nomeClienteController.text.trim() : 
                _tipoPedido == 'balcao' ? _nomeRetiradaController.text.trim() : null,
        endereco: _tipoPedido == 'delivery' ? _enderecoController.text.trim() : null,
        observacoesPedido: dados['observacoesPedido'],
      );

      if (!mounted) return;

      if (sucesso) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comanda da cozinha impressa com sucesso! 👨‍🍳'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao imprimir comanda da cozinha'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Fechar loading se ainda estiver aberto
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro inesperado ao imprimir'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        informacoesEntrega: dados['informacoesEntrega'],
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          // Banner de instruções se houver seleções ativas
          if (_selecoesAtuais.isNotEmpty) _buildBannerInstrucoes(),
          Expanded(
            child: Row(
              children: [
                _buildColunaSelecao(),
                _buildColunaCarrinho(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Banner com instruções para o sistema intuitivo
  Widget _buildBannerInstrucoes() {
    final totalSelecoes = _selecoesAtuais.length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$totalSelecoes seleção(s) ativa(s). Clique no ✓ verde ou no preço novamente para confirmar.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _limparSelecoes,
            child: const Text(
              'Limpar',
              style: TextStyle(color: Colors.white),
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
              fontSize: 22,
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
                  content:
                      Text('Executando diagnóstico... Verifique o console'),
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
              fontSize: 22,
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
      flex: 70, // Aumentado para ocupar mais espaço sem a coluna central
      child: Container(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Column(
          children: [
            // Seção fixa no topo (seletor de tipo)
            _buildSeletorTipoPedido(),
            
            // Seção scrollável que contém campos específicos + tabs + busca + produtos
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildCamposEspecificos(),
                    _buildTabs(),
                    _buildBuscaProduto(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7, // 70% da tela para produtos (aumentado)
                      child: _buildGridProdutos(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSeletorTipoPedido() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo:',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildBotaoTipoPedido('delivery', '🚚', 'Delivery'),
              const SizedBox(width: 6),
              _buildBotaoTipoPedido('balcao', '🏪', 'Balcão'),
              const SizedBox(width: 6),
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
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.red : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.red : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_tipoPedido == 'delivery') ...[
            _buildCampoTexto(
              controller: _nomeClienteController,
              label: '👤 Nome do Cliente',
              hint: 'Nome completo...',
              obrigatorio: true,
            ),
            const SizedBox(height: 6),
            _buildCampoTexto(
              controller: _telefoneClienteController,
              label: '📱 Telefone',
              hint: '(XX) XXXXX-XXXX',
              obrigatorio: true,
              tipo: TextInputType.phone,
            ),
            const SizedBox(height: 6),
            _buildCampoTexto(
              controller: _enderecoController,
              label: '📍 Endereço de Entrega',
              hint: 'Rua, número, bairro...',
              obrigatorio: true,
            ),
            const SizedBox(height: 6),
            _buildCampoTexto(
              controller: _observacoesController,
              label: '📝 Observações de Entrega',
              hint: 'Complemento, referência...',
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.blue, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Est: $_tempoEstimado',
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
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.green, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Est: $_tempoEstimado',
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
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<int>(
                        value: _mesaSelecionada,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items:
                            List.generate(10, (index) => index + 1).map((mesa) {
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
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildCampoTexto({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obrigatorio = false,
    TextInputType? tipo,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label com ícone
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              children: [
                _getIconForField(label),
                const SizedBox(width: 4),
                Text(
                  _getCleanLabel(label),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: obrigatorio 
                        ? Colors.red.shade700 
                        : Colors.grey.shade700,
                  ),
                ),
                if (obrigatorio) ...[
                  const SizedBox(width: 2),
                  Text(
                    '*',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Campo de texto moderno
          Container(
            width: 260,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: tipo,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 22,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red.shade400, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                isDense: true,
                // Ícone de sufixo para campos específicos
                suffixIcon: _getSuffixIcon(label, controller),
              ),
              // Formatadores específicos por tipo
              inputFormatters: _getInputFormatters(tipo, label),
              // Validação em tempo real
              onChanged: (value) => _validateField(label, value, obrigatorio),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Obtém ícone baseado no tipo de campo
  Widget _getIconForField(String label) {
    if (label.contains('Nome')) return Icon(Icons.person, size: 14, color: Colors.blue.shade600);
    if (label.contains('Telefone')) return Icon(Icons.phone, size: 14, color: Colors.green.shade600);
    if (label.contains('Endereço')) return Icon(Icons.location_on, size: 14, color: Colors.red.shade600);
    if (label.contains('Observações')) return Icon(Icons.note, size: 14, color: Colors.orange.shade600);
    if (label.contains('Garçom')) return Icon(Icons.restaurant_menu, size: 14, color: Colors.purple.shade600);
    if (label.contains('Mesa')) return Icon(Icons.table_restaurant, size: 14, color: Colors.brown.shade600);
    return Icon(Icons.edit, size: 14, color: Colors.grey.shade600);
  }
  
  /// Remove emoji do label
  String _getCleanLabel(String label) {
    return label.replaceAll(RegExp(r'[🍕👤📱📍📝🪑🍽️]'), '').trim();
  }
  
  /// Obtém ícone de sufixo para campos específicos
  Widget? _getSuffixIcon(String label, TextEditingController controller) {
    if (label.contains('Telefone')) {
      return IconButton(
        icon: Icon(Icons.contact_phone, size: 16, color: Colors.grey.shade600),
        onPressed: () {
          // Funcionalidade futura: abrir contatos
          HapticFeedback.lightImpact();
        },
      );
    }
    
    if (label.contains('Endereço')) {
      return IconButton(
        icon: Icon(Icons.my_location, size: 16, color: Colors.grey.shade600),
        onPressed: () {
          // Funcionalidade futura: GPS
          HapticFeedback.lightImpact();
        },
      );
    }
    
    if (controller.text.isNotEmpty) {
      return IconButton(
        icon: Icon(Icons.clear, size: 16, color: Colors.grey.shade600),
        onPressed: () {
          controller.clear();
          HapticFeedback.lightImpact();
        },
      );
    }
    
    return null;
  }
  
  /// Obtém formatadores de input baseado no tipo
  List<TextInputFormatter> _getInputFormatters(TextInputType? tipo, String label) {
    List<TextInputFormatter> formatters = [];
    
    if (tipo == TextInputType.phone || label.contains('Telefone')) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
      formatters.add(_PhoneFormatter());
    }
    
    if (label.contains('Nome')) {
      formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s]')));
      formatters.add(_NameFormatter());
    }
    
    return formatters;
  }
  
  /// Valida campo em tempo real
  void _validateField(String label, String value, bool obrigatorio) {
    if (!obrigatorio && value.isEmpty) return;
    
    // Validação de telefone
    if (label.contains('Telefone') && value.isNotEmpty) {
      final digits = value.replaceAll(RegExp(r'[^\d]'), '');
      if (digits.length < 10 || digits.length > 11) {
        // Campo inválido - pode adicionar feedback visual
      }
    }
    
    // Outras validações podem ser adicionadas aqui
  }

  Widget _buildTabs() {
    return TabBar(
      controller: _tabController,
      onTap: (_) => setState(() {
        _filtroTexto = '';
        _buscaProdutoController.clear();
      }),
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.red,
      indicatorWeight: 2,
      tabs: const [
        Tab(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🚚 DELIVERY'),
              Text('R\$ 40,00', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
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
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  _produtosBanco.isNotEmpty
                      ? Icons.cloud_done
                      : Icons.cloud_off,
                  size: 16,
                  color:
                      _produtosBanco.isNotEmpty ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_produtosAtuais.length} items ${_produtosBanco.isNotEmpty ? '(DB)' : '(Mock)'}',
                  style: TextStyle(
                    fontSize: 22,
                    color: _produtosBanco.isNotEmpty
                        ? Colors.green
                        : Colors.orange,
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
                fontSize: 22,
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
                fontSize: 22,
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
                fontSize: 22,
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

    // Agrupar produtos por nome para criar estrutura de tabela
    final Map<String, Map<String, dynamic>> produtosAgrupados = {};
    
    for (final produto in produtos) {
      final nome = produto['nome'] as String;
      if (!produtosAgrupados.containsKey(nome)) {
        produtosAgrupados[nome] = {
          'nome': nome,
          'ingredientes': produto['descricao'] ?? produto['ingredientes'] ?? '',
          'categoriaNome': produto['categoriaNome'] ?? '',
          'precos': <String, double>{},
          'produto_original': produto,
        };
      }
      
      // Se produto tem preços por tamanho
      final precosMap = produto['precosMap'] as Map<String, double>? ?? {};
      if (precosMap.isNotEmpty) {
        produtosAgrupados[nome]!['precos'] = precosMap;
      } else {
        // Usar preço base
        final preco = (produto['preco'] as num?)?.toDouble() ?? 0.0;
        produtosAgrupados[nome]!['precos'] = {'M': preco};
      }
    }
    
    final produtosOrdenados = produtosAgrupados.values.toList()
      ..sort((a, b) => a['nome'].toString().compareTo(b['nome'].toString()));

    return Column(
      children: [
        // Banner informativo para pizzas delivery
        if (_tabController.index == 0 && produtos.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('🚚', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROMOÇÃO DELIVERY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Todas as pizzas grandes por apenas R\$ 40,00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'R\$ 40,00',
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Cabeçalho da tabela tipo cardápio
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  'Pizza',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'Ingredientes',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              ...['P', 'M', 'G', 'F'].map((tamanho) => SizedBox(
                width: 70,
                child: Text(
                  tamanho == 'P' ? 'Pequena' : 
                  tamanho == 'M' ? 'Média' :
                  tamanho == 'G' ? 'Grande' : 'Família',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
              )),
            ],
          ),
        ),
        
        // Tabela de produtos
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              ),
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: produtosOrdenados.length,
              itemBuilder: (context, index) {
                final produto = produtosOrdenados[index];
                final precos = produto['precos'] as Map<String, double>;
                final isDelivery = produto['categoriaNome'].toString().toLowerCase().contains('delivery');
                
                return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Nome da pizza
                        SizedBox(
                          width: 120,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                produto['nome'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              if (isDelivery) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    '🚚 DELIVERY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        // Ingredientes
                        Expanded(
                          child: Text(
                            produto['ingredientes'],
                            style: TextStyle(
                              fontSize: 22,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Preços por tamanho (clicáveis com sistema intuitivo)
                        ...['P', 'M', 'G', 'F'].map((tamanho) {
                          final preco = isDelivery && tamanho == 'G' ? 40.0 : precos[tamanho];
                          final estadoSelecao = _getEstadoSelecao(produto['nome'], tamanho);
                          final temSelecao = _selecoesAtuais.containsKey(tamanho);
                          
                          return SizedBox(
                            width: 70,
                            child: preco != null
                                ? Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      InkWell(
                                        onTap: () => _processarClique(
                                          produto['nome'],
                                          produto['ingredientes'],
                                          tamanho,
                                          preco,
                                          isDelivery,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                          decoration: BoxDecoration(
                                            color: _getCorSelecao(estadoSelecao, isDelivery && tamanho == 'G'),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: _getCorBordaSelecao(estadoSelecao, isDelivery && tamanho == 'G'),
                                              width: estadoSelecao != 'none' ? 2 : 1,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'R\$ ${preco.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _getCorTextoSelecao(estadoSelecao, isDelivery && tamanho == 'G'),
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              if (estadoSelecao != 'none') ...[
                                                const SizedBox(height: 2),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: estadoSelecao == 'single' ? Colors.green : Colors.orange,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    estadoSelecao == 'single' ? '1x' : 'Mix',
                                                    style: const TextStyle(
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Botão de confirmação flutuante
                                      if (temSelecao && _tamanhoSelecionandoAtual == tamanho)
                                        Positioned(
                                          top: -5,
                                          right: -5,
                                          child: InkWell(
                                            onTap: () => _mostrarModalConfirmacao(tamanho),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.3),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      '-',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                          );
                        }),
                      ],
                    ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Modal para seleção de opções do produto
  void _mostrarModalSelecao(
    String nomePizza,
    String ingredientes,
    String tamanho,
    double preco,
    bool isDelivery,
  ) {
    // Determinar quantos sabores são permitidos baseado no tamanho
    final maxSabores = tamanho == 'F' ? 3 : 2;
    
    List<String> saboresSelecionados = [nomePizza];
    int quantidade = 1;
    bool multiSabores = false;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Calcular preço baseado no maior sabor selecionado
            double calcularPreco() {
              if (isDelivery && tamanho == 'G') {
                return 40.0 * quantidade;
              }
              
              if (!multiSabores || saboresSelecionados.length <= 1) {
                return preco * quantidade;
              }
              
              // Para múltiplos sabores, usar o maior preço
              double maiorPreco = preco;
              final produtos = _produtosAtuais;
              
              for (final saborNome in saboresSelecionados) {
                final produto = produtos.firstWhere(
                  (p) => p['nome'] == saborNome,
                  orElse: () => {'precosMap': <String, double>{}},
                );
                final precosMap = produto['precosMap'] as Map<String, double>? ?? {};
                final precoSabor = precosMap[tamanho] ?? preco;
                if (precoSabor > maiorPreco) {
                  maiorPreco = precoSabor;
                }
              }
              
              return maiorPreco * quantidade;
            }
            
            return Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nomePizza,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tamanho: ${_getNomeTamanho(tamanho)}',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Ingredientes
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ingredientes,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Toggle múltiplos sabores
                    Row(
                      children: [
                        Switch(
                          value: multiSabores,
                          onChanged: (value) {
                            setModalState(() {
                              multiSabores = value;
                              if (!value) {
                                saboresSelecionados = [nomePizza];
                              }
                            });
                          },
                          activeColor: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Múltiplos sabores (até $maxSabores)',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    
                    // Seletor de sabores
                    if (multiSabores) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Sabores selecionados (${saboresSelecionados.length}/$maxSabores):',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      ...saboresSelecionados.asMap().entries.map((entry) {
                        final index = entry.key;
                        final sabor = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _mostrarSeletorSabor(context, setModalState, index, saboresSelecionados, tamanho),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(sabor),
                                  ),
                                ),
                              ),
                              if (index > 0)
                                IconButton(
                                  onPressed: () {
                                    setModalState(() {
                                      saboresSelecionados.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                ),
                            ],
                          ),
                        );
                      }),
                      if (saboresSelecionados.length < maxSabores)
                        ElevatedButton.icon(
                          onPressed: () {
                            setModalState(() {
                              saboresSelecionados.add('');
                            });
                            _mostrarSeletorSabor(context, setModalState, saboresSelecionados.length - 1, saboresSelecionados, tamanho);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar sabor'),
                        ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Seletor de quantidade
                    Row(
                      children: [
                        const Text('Quantidade:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        IconButton(
                          onPressed: quantidade > 1 ? () {
                            setModalState(() => quantidade--);
                          } : null,
                          icon: const Icon(Icons.remove),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(quantidade.toString(), style: const TextStyle(fontSize: 18)),
                        ),
                        IconButton(
                          onPressed: () {
                            setModalState(() => quantidade++);
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Preço e botão adicionar
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total:', style: TextStyle(fontSize: 18)),
                            Text(
                              'R\$ ${calcularPreco().toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            _adicionarAoCarrinhoDirecto(
                              nomePizza,
                              saboresSelecionados,
                              tamanho,
                              quantidade,
                              calcularPreco(),
                            );
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Adicionar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  String _getNomeTamanho(String tamanho) {
    switch (tamanho) {
      case 'P': return 'Pequena';
      case 'M': return 'Média';
      case 'G': return 'Grande';
      case 'F': return 'Família';
      default: return tamanho;
    }
  }
  
  /// Mostrar seletor de sabor específico
  void _mostrarSeletorSabor(
    BuildContext context,
    StateSetter setModalState,
    int index,
    List<String> saboresSelecionados,
    String tamanho,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final produtos = _produtosAtuais.where((p) => 
          p['categoriaNome'].toString().toLowerCase().contains('pizza')).toList();
        
        return AlertDialog(
          title: Text('Selecionar Sabor ${index + 1}'),
          content: SizedBox(
            width: 400,
            height: 300,
            child: ListView.builder(
              itemCount: produtos.length,
              itemBuilder: (context, i) {
                final produto = produtos[i];
                final precosMap = produto['precosMap'] as Map<String, double>? ?? {};
                final preco = precosMap[tamanho] ?? 0.0;
                
                return ListTile(
                  title: Text(produto['nome']),
                  subtitle: Text('R\$ ${preco.toStringAsFixed(2)}'),
                  onTap: () {
                    setModalState(() {
                      saboresSelecionados[index] = produto['nome'];
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
  
  /// Adicionar produto diretamente ao carrinho
  void _adicionarAoCarrinhoDirecto(
    String nomePizza,
    List<String> sabores,
    String tamanho,
    int quantidade,
    double precoTotal,
  ) {
    HapticFeedback.lightImpact();
    
    String descricao = '';
    if (sabores.length > 1) {
      descricao = '${sabores.where((s) => s.isNotEmpty).join(' + ')} $tamanho';
    } else {
      descricao = '$nomePizza $tamanho';
    }
    
    final item = {
      'nome': nomePizza,
      'descricao': descricao,
      'preco': precoTotal / quantidade,
      'quantidade': quantidade,
      'total': precoTotal,
      'observacao': '',
    };
    
    setState(() {
      _carrinho.add(item);
      _calcularSubtotal();
    });
    
    // Mostrar confirmação
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$descricao adicionado ao carrinho!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }



  Widget _buildColunaCarrinho() {
    return Expanded(
      flex: 30, // Aumentado para 30% sem a coluna central
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
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
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: _carrinho.isEmpty
                  ? Center(
                      child: Text(
                        '(vazio)',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 22,
                        ),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
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
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${item['preco'].toStringAsFixed(2)} cada',
                      style: const TextStyle(
                        fontSize: 22,
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
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
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
                onPressed: () =>
                    _alterarQuantidadeCarrinho(index, item['quantidade'] - 1),
                icon: const Icon(Icons.remove, size: 16),
              ),
              Text(item['quantidade'].toString()),
              IconButton(
                onPressed: () =>
                    _alterarQuantidadeCarrinho(index, item['quantidade'] + 1),
                icon: const Icon(Icons.add, size: 16),
              ),
              const Spacer(),
              Text(
                'R\$ ${item['total'].toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      prefixText: 'R\$ ',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                'R\$ ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Forma de Pagamento
          const Text(
            'Forma de Pagamento:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          // Opções de pagamento em linha
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildOpcaoPagamento('dinheiro', Icons.money, 'Dinheiro'),
                const SizedBox(width: 8),
                _buildOpcaoPagamento('pix', Icons.qr_code, 'PIX'),
                const SizedBox(width: 8),
                _buildOpcaoPagamento('cartao', Icons.credit_card, 'Cartão'),
              ],
            ),
          ),

          // Campo de valor pago e troco (apenas para dinheiro)
          if (_formaPagamento == 'dinheiro') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _valorPagoController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Valor Recebido',
                      prefixText: 'R\$ ',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    ),
                    onChanged: (value) {
                      _calcularTroco(total);
                    },
                  ),
                ),
                if (_troco > 0) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Troco',
                          style: TextStyle(fontSize: 22, color: Colors.green),
                        ),
                        Text(
                          'R\$ ${_troco.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],

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
                child: OutlinedButton.icon(
                  onPressed: _carrinho.isNotEmpty ? _imprimirComandaCozinha : null,
                  icon: const Icon(Icons.restaurant_menu, size: 18),
                  label: const Text('Cozinha'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange.shade700,
                    side: BorderSide(color: Colors.orange.shade300),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _carrinho.isNotEmpty && _validarPedido()
                      ? () {
                          HapticFeedback.lightImpact();
                          _salvarPedido();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.payment, size: 18),
                  label: const Text('Pagar e Salvar'),
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
        return _nomeClienteController.text.trim().isNotEmpty &&
               _telefoneClienteController.text.trim().isNotEmpty &&
               _enderecoController.text.trim().isNotEmpty;
      case 'balcao':
        return _nomeRetiradaController.text.trim().isNotEmpty;
      case 'mesa':
        return true; // Mesa sempre válida (já tem mesa selecionada)
      default:
        return true;
    }
  }

  void _calcularTroco(double total) {
    final valorText = _valorPagoController.text
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    if (valorText.isEmpty) {
      setState(() => _troco = 0.0);
      return;
    }

    try {
      final valorPago = double.parse(valorText);
      setState(() {
        _troco = valorPago > total ? valorPago - total : 0.0;
      });
    } catch (e) {
      setState(() => _troco = 0.0);
    }
  }

  Widget _buildOpcaoPagamento(String valor, IconData icone, String label) {
    final isSelected = _formaPagamento == valor;

    return ChoiceChip(
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _formaPagamento = valor;
            if (valor != 'dinheiro') {
              _valorPagoController.clear();
              _troco = 0.0;
            }
          });
        }
      },
      avatar: Icon(
        icone,
        size: 18,
        color: isSelected 
            ? Theme.of(context).colorScheme.onPrimary 
            : Theme.of(context).colorScheme.onSurface,
      ),
      label: Text(label),
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      labelStyle: TextStyle(
        color: isSelected 
            ? Theme.of(context).colorScheme.onPrimary 
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
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

    // Validar pagamento em dinheiro
    if (_formaPagamento == 'dinheiro' && _valorPagoController.text.isNotEmpty) {
      final total = _subtotal + _taxaEntrega;
      final valorText = _valorPagoController.text
          .replaceAll('R\$', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();

      try {
        final valorPago = double.parse(valorText);
        if (valorPago < total) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Valor recebido insuficiente'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Valor inválido'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (!mounted) return;

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
      final numeroPedido =
          '${agora.millisecondsSinceEpoch}'.substring(7).padLeft(6, '0');


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
      if (_tipoPedido == 'delivery' &&
          _enderecoController.text.trim().isNotEmpty) {
        observacoes += '\nEndereço: ${_enderecoController.text.trim()}';
      }
      if (_tipoPedido == 'mesa') {
        observacoes += '\nMesa: $_mesaSelecionada';
        if (_nomeGarcomController.text.trim().isNotEmpty) {
          observacoes += '\nGarçom: ${_nomeGarcomController.text.trim()}';
        }
      }

      final supabase = Supabase.instance.client;

      // Preparar forma de pagamento
      String formaPagamentoTexto = _formaPagamento == 'dinheiro'
          ? 'Dinheiro'
          : _formaPagamento == 'pix'
              ? 'PIX'
              : 'Cartão';

      // Calcular valor pago e troco se for dinheiro
      double? valorPago;
      double? trocoCalculado;
      if (_formaPagamento == 'dinheiro' &&
          _valorPagoController.text.isNotEmpty) {
        final valorText = _valorPagoController.text
            .replaceAll('R\$', '')
            .replaceAll('.', '')
            .replaceAll(',', '.')
            .trim();
        valorPago = double.tryParse(valorText);
        trocoCalculado = _troco;
      }

      // Preparar dados do pedido conforme estrutura do banco
      final double taxaEntrega = _tipoPedido == 'delivery' ? _taxaEntregaEditavel : 0.0;
      final double total = _subtotal + taxaEntrega;
      
      // Preparar observações incluindo informações de entrega/cliente
      String observacoesFinal = observacoes.trim();
      
      if (_tipoPedido == 'delivery') {
        final nomeCliente = _nomeClienteController.text.trim();
        final telefoneCliente = _telefoneClienteController.text.trim();
        final endereco = _enderecoController.text.trim();
        
        // Formato: Cliente: Nome | Tel: (XX) XXXXX-XXXX | Endereço: Rua, 123
        String dadosEntrega = '';
        if (nomeCliente.isNotEmpty) dadosEntrega += 'Cliente: $nomeCliente';
        if (telefoneCliente.isNotEmpty) dadosEntrega += ' | Tel: $telefoneCliente';
        if (endereco.isNotEmpty) dadosEntrega += ' | Endereço: $endereco';
        
        observacoesFinal = observacoesFinal.isEmpty 
          ? dadosEntrega
          : '$observacoesFinal\n$dadosEntrega';
          
      } else if (_tipoPedido == 'balcao') {
        final nomeRetirada = _nomeRetiradaController.text.trim();
        if (nomeRetirada.isNotEmpty) {
          observacoesFinal = observacoesFinal.isEmpty 
            ? 'Retirar - $nomeRetirada'
            : '$observacoesFinal\nRetirar - $nomeRetirada';
        }
      }

      final pedidoData = <String, dynamic>{
        'numero': numeroPedido,
        'tipo_pedido': tipoPedidoDb,
        'tipo': tipoPedidoDb, // Campo adicional para compatibilidade
        'subtotal': _subtotal,
        'taxa_entrega': taxaEntrega,
        'desconto': 0.0,
        'total': total,
        'forma_pagamento': formaPagamentoTexto,
        'observacoes': observacoesFinal.isEmpty ? null : observacoesFinal,
        'tempo_estimado_minutos': _tipoPedido == 'delivery' ? 45 : 30,
        'status': 'recebido',
      };

      // Adicionar mesa_id se for pedido de mesa
      if (_tipoPedido == 'mesa') {
        pedidoData['mesa_id'] = _mesaSelecionada;
      }

      // Adicionar campos opcionais se tiverem valor
      if (valorPago != null) {
        pedidoData['valor_pago'] = valorPago;
      }
      if (trocoCalculado != null && trocoCalculado > 0) {
        pedidoData['troco'] = trocoCalculado;
      }

      // Dados do pedido preparados para salvar

      // Inserir pedido
      final pedidoResponse =
          await supabase.from('pedidos').insert(pedidoData).select().single();

      // Pedido salvo com sucesso

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
            // produto_id e borda_recheada_id podem ser null por enquanto
          };
        }).toList();

        await supabase.from('itens_pedido').insert(itensData);
        // Itens do pedido salvos com sucesso
      } catch (e) {
        // Aviso: Itens não puderam ser salvos - tabela pedido_itens pode não existir
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
      // Erro ao criar pedido

      if (!mounted) return;
      Navigator.of(context).pop(); // Fechar loading

      // Mensagem de erro mais específica
      String mensagemErro = 'Erro ao criar pedido';
      if (e.toString().contains('duplicate')) {
        mensagemErro = 'Número de pedido já existe';
      } else if (e.toString().contains('null')) {
        mensagemErro = 'Campos obrigatórios não preenchidos';
      } else if (e.toString().contains('network')) {
        mensagemErro = 'Erro de conexão com o servidor';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mensagemErro),
              Text(
                'Detalhes: ${e.toString()}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
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

/// Formatador para campos de telefone
class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length <= 10) {
      // Formato: (XX) XXXX-XXXX
      String formatted = '';
      if (digits.length >= 2) {
        formatted += '(${digits.substring(0, 2)}) ';
        if (digits.length >= 6) {
          formatted += '${digits.substring(2, 6)}-';
          if (digits.length > 6) {
            formatted += digits.substring(6, digits.length > 10 ? 10 : digits.length);
          }
        } else if (digits.length > 2) {
          formatted += digits.substring(2);
        }
      } else if (digits.isNotEmpty) {
        formatted = digits;
      }
      
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else {
      // Formato: (XX) XXXXX-XXXX
      String formatted = '';
      if (digits.length >= 2) {
        formatted += '(${digits.substring(0, 2)}) ';
        if (digits.length >= 7) {
          formatted += '${digits.substring(2, 7)}-';
          if (digits.length > 7) {
            formatted += digits.substring(7, digits.length > 11 ? 11 : digits.length);
          }
        } else if (digits.length > 2) {
          formatted += digits.substring(2);
        }
      }
      
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }
}

/// Formatador para campos de nome (capitaliza primeira letra de cada palavra)
class _NameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final words = newValue.text.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
    
    return TextEditingValue(
      text: capitalizedWords,
      selection: newValue.selection,
    );
  }
}
