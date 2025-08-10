import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdutosContent extends StatefulWidget {
  const ProdutosContent({super.key});

  @override
  State<ProdutosContent> createState() => _ProdutosContentState();
}

class _ProdutosContentState extends State<ProdutosContent>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> categorias = [];
  List<Map<String, dynamic>> produtos = [];
  List<Map<String, dynamic>> filteredProdutos = [];
  Map<int, String> tamanhos = {}; // Mapa de id do tamanho para nome
  bool isLoading = true;
  String? error;

  TabController? _tabController;
  int selectedCategoriaId = 0;

  final TextEditingController _searchController = TextEditingController();
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Criar mapa de tamanhos fixos (já que a tabela tamanhos não existe)
      // Baseado nos tamanho_id encontrados em produtos_precos (1,2,3,4)
      tamanhos = {1: 'Pequena', 2: 'Média', 3: 'Grande', 4: 'Família'};

      // Buscar o ID da categoria "Pizzas Promocionais" para excluí-la
      // Buscar o ID da categoria "Pizzas Promocionais" para excluí-la (se necessário)
      // final categPromoResponse = await supabase
      //     .from('categorias')
      //     .select('id')
      //     .eq('nome', 'Pizzas Promocionais')
      //     .maybeSingle();
      // final categPromoId = categPromoResponse?['id'];

      // Carregar produtos da tabela produtos (única fonte agora)
      final produtosResponse = await supabase.from('produtos').select('''
            *,
            produtos_precos (
              preco,
              preco_promocional,
              tamanho_id
            ),
            categorias (
              id,
              nome
            )
          ''').order('nome');

      produtos = List<Map<String, dynamic>>.from(produtosResponse);

      // Produtos carregados com sucesso

      // Carregar categorias da tabela categorias (única fonte agora)
      final categoriasResponse = await supabase
          .from('categorias')
          .select('*')
          .eq('ativo', true)
          .order('nome');

      final todasCategorias =
          List<Map<String, dynamic>>.from(categoriasResponse);

      // Usar as categorias reais do banco, mas filtrar Sobremesas se não tiver produtos
      categorias = todasCategorias
          .map((cat) => {
                'id': cat['id'],
                'nome': cat['nome'],
              })
          .toList();

      // Opcional: remover categoria Sobremesas se não houver produtos nela
      final catSobremesa = todasCategorias.firstWhere(
        (c) => c['nome'].toString().toLowerCase().contains('sobremesa'),
        orElse: () => {},
      );

      if (catSobremesa.isNotEmpty) {
        final produtosSobremesa = produtos
            .where((p) => p['categoria_id'] == catSobremesa['id'])
            .toList();
        if (produtosSobremesa.isEmpty) {
          categorias.removeWhere((c) => c['id'] == catSobremesa['id']);
        }
      }

      // DEBUG: Categorias carregadas

      // Inicializar ou atualizar TabController
      if (_tabController == null) {
        // Criar novo controller se não existir
        _tabController = TabController(
          length: categorias.length + 1,
          vsync: this,
        );

        _tabController?.addListener(() {
          if (mounted) {
            setState(() {
              selectedCategoriaId = _tabController!.index == 0
                  ? 0
                  : categorias[_tabController!.index - 1]['id'];
            });
            _filterProdutos();
          }
        });
      } else if (_tabController!.length != categorias.length + 1) {
        // Se o número de categorias mudou, recriar o controller
        final oldIndex = _tabController!.index;
        _tabController?.dispose();
        _tabController = TabController(
          length: categorias.length + 1,
          vsync: this,
          initialIndex: oldIndex.clamp(0, categorias.length),
        );

        _tabController?.addListener(() {
          if (mounted) {
            setState(() {
              selectedCategoriaId = _tabController!.index == 0
                  ? 0
                  : categorias[_tabController!.index - 1]['id'];
            });
            _filterProdutos();
          }
        });
      }

      // Produtos já foram carregados no início
      _filterProdutos();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      // Erro ao carregar dados
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterProdutos() {
    setState(() {
      filteredProdutos = produtos.where((produto) {
        // Filtro por categoria
        if (selectedCategoriaId != 0 &&
            produto['categoria_id'] != selectedCategoriaId) {
          return false;
        }

        // Filtro por status ativo
        if (!_showInactive && produto['ativo'] == false) {
          return false;
        }

        // Filtro por busca
        if (_searchController.text.isNotEmpty) {
          final searchTerm = _searchController.text.toLowerCase();
          final nome = produto['nome']?.toString().toLowerCase() ?? '';
          final descricao =
              produto['descricao']?.toString().toLowerCase() ?? '';

          if (!nome.contains(searchTerm) && !descricao.contains(searchTerm)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produtos',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Gerencie o catálogo de produtos',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '${filteredProdutos.length} ${filteredProdutos.length == 1 ? 'produto' : 'produtos'}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Funcionalidade de adicionar produto será implementada
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Novo Produto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Tabs de categorias
              if (_tabController != null && categorias.isNotEmpty) ...[
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController!,
                  isScrollable: true,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  indicatorColor: colorScheme.primary,
                  tabs: [
                    const Tab(text: 'Todas'),
                    ...categorias.map((cat) => Tab(text: cat['nome'])),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Filtros e busca
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar produtos...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                  onChanged: (_) => _filterProdutos(),
                ),
              ),
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Mostrar inativos'),
                selected: _showInactive,
                onSelected: (selected) {
                  setState(() => _showInactive = selected);
                  _filterProdutos();
                },
              ),
            ],
          ),
        ),

        // Lista de produtos
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: colorScheme.error),
                          const SizedBox(height: 16),
                          Text('Erro ao carregar produtos: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    )
                  : filteredProdutos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum produto encontrado',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 250,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: filteredProdutos.length,
                            // Lazy loading: renderiza apenas os visíveis
                            cacheExtent:
                                100, // Reduz cache para economizar memória
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final produto = filteredProdutos[index];
                              return _ProdutoCard(
                                key: ValueKey(produto[
                                    'id']), // Melhora performance com keys
                                produto: produto,
                                tamanhos: tamanhos,
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}

class _ProdutoCard extends StatelessWidget {
  final Map<String, dynamic> produto;
  final Map<int, String> tamanhos;

  const _ProdutoCard({
    super.key,
    required this.produto,
    required this.tamanhos,
  });

  IconData _getIconForCategory(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'pizza':
        return Icons.local_pizza;
      case 'bebida':
      case 'refrigerante':
        return Icons.local_drink;
      case 'suco':
        return Icons.local_cafe;
      case 'borda':
        return Icons.donut_small;
      default:
        return Icons.fastfood;
    }
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoria = produto['categorias'];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _showEditPricesDialog(context, produto, tamanhos);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: colorScheme.surfaceContainerHighest,
                child: produto['imagem'] != null && produto['imagem'].isNotEmpty
                    ? Image.network(
                        produto['imagem'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            _getIconForCategory(produto['tipo_produto']),
                            size: 48,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          );
                        },
                      )
                    : Icon(
                        _getIconForCategory(produto['tipo_produto']),
                        size: 48,
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
              ),
            ),

            // Detalhes
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome
                    Text(
                      produto['nome'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Categoria
                    if (categoria != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          categoria['nome'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Preço - usando produtos_precos (única fonte agora)
                    Builder(builder: (context) {
                      final precos = produto['produtos_precos'] as List?;

                      if (precos != null && precos.isNotEmpty) {
                        // Se tem múltiplos tamanhos, mostrar todos os tamanhos com preços
                        if (precos.length > 1) {
                          // Ordenar por tamanho
                          final precosOrdenados = List.from(precos);
                          precosOrdenados.sort((a, b) {
                            // Usar tamanho_id para ordenar (1=P, 2=M, 3=G, 4=F)
                            int tamanhoA = a['tamanho_id'] ?? 99;
                            int tamanhoB = b['tamanho_id'] ?? 99;
                            return tamanhoA.compareTo(tamanhoB);
                          });

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: precosOrdenados.map((p) {
                                  // Converter tamanho_id para abreviação P, M, G, F
                                  int? tamanhoId = p['tamanho_id'];
                                  String tamanhoAbreviado = '';
                                  if (tamanhoId == 1) {
                                    tamanhoAbreviado = 'P';
                                  } else if (tamanhoId == 2) {
                                    tamanhoAbreviado = 'M';
                                  } else if (tamanhoId == 3) {
                                    tamanhoAbreviado = 'G';
                                  } else if (tamanhoId == 4) {
                                    tamanhoAbreviado = 'F';
                                  } else {
                                    tamanhoAbreviado = '?';
                                  }

                                  // Usar preco_promocional se disponível, senão preco
                                  final preco =
                                      p['preco_promocional'] ?? p['preco'];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '$tamanhoAbreviado: R\$ ${preco.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        } else {
                          // Um único preço
                          final preco = precos[0]['preco_promocional'] ??
                              precos[0]['preco'];
                          final tamanhoId = precos[0]['tamanho_id'] as int?;
                          final tamanho =
                              tamanhoId != null ? tamanhos[tamanhoId] : null;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'R\$ ${preco.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              if (tamanho != null)
                                Text(
                                  'Tamanho: $tamanho',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          );
                        }
                      } else {
                        // Tentar preco_unitario
                        final preco = produto['preco_unitario'];
                        if (preco != null) {
                          return Text(
                            'R\$ ${preco.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          );
                        } else {
                          return Text(
                            'Consulte',
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          );
                        }
                      }
                    }),

                    const SizedBox(height: 4),

                    // Status e botão editar
                    Row(
                      children: [
                        Icon(
                          produto['ativo'] == true
                              ? Icons.check_circle
                              : Icons.cancel,
                          size: 16,
                          color: produto['ativo'] == true
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          produto['ativo'] == true ? 'Ativo' : 'Inativo',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showEditPricesDialog(context, produto, tamanhos);
                          },
                          icon: const Icon(
                            Icons.edit,
                            size: 16,
                          ),
                          label: const Text('Editar Preços'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
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

  static void _showEditPricesDialog(BuildContext context, Map<String, dynamic> produto, Map<int, String> tamanhos) {
    final supabase = Supabase.instance.client;
    
    // Controllers para os campos de preço
    final Map<int, TextEditingController> priceControllers = {};
    final Map<int, bool> hasChanges = {};
    
    // Inicializar controllers com os preços atuais
    final precos = produto['produtos_precos'] as List? ?? [];
    final precosMap = <int, double>{};
    
    for (final preco in precos) {
      final tamanhoId = preco['tamanho_id'] as int;
      final precoValor = (preco['preco'] as num).toDouble();
      precosMap[tamanhoId] = precoValor;
    }

    // Criar controllers para todos os tamanhos (1,2,3,4)
    for (int i = 1; i <= 4; i++) {
      final precoAtual = precosMap[i];
      priceControllers[i] = TextEditingController(
        text: precoAtual != null ? precoAtual.toStringAsFixed(2).replaceAll('.', ',') : '',
      );
      hasChanges[i] = false;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool hasAnyChanges = hasChanges.values.any((changed) => changed);
            
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Editar Preços',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome do produto
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_pizza, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              produto['nome'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Campos de preço para cada tamanho
                    ...tamanhos.entries.map((tamanhoEntry) {
                      final tamanhoId = tamanhoEntry.key;
                      final tamanhoNome = tamanhoEntry.value;
                      final controller = priceControllers[tamanhoId]!;
                      final isChanged = hasChanges[tamanhoId]!;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: tamanhoNome,
                            prefixText: 'R\$ ',
                            border: const OutlineInputBorder(),
                            filled: isChanged,
                            fillColor: isChanged 
                                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2)
                                : null,
                            suffixIcon: isChanged 
                                ? Icon(Icons.edit, size: 16, color: Theme.of(context).colorScheme.primary)
                                : null,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              hasChanges[tamanhoId] = true;
                            });
                          },
                        ),
                      );
                    }),
                    
                    if (hasAnyChanges) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info, size: 16, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              'Há alterações não salvas',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                if (hasAnyChanges)
                  ElevatedButton(
                    onPressed: () async {
                      // Salvar alterações
                      try {
                        for (final tamanhoId in hasChanges.keys) {
                          if (hasChanges[tamanhoId]!) {
                            final controller = priceControllers[tamanhoId]!;
                            final precoText = controller.text.replaceAll(',', '.');
                            
                            if (precoText.isNotEmpty) {
                              final preco = double.tryParse(precoText);
                              
                              if (preco != null && preco > 0) {
                                // Verificar se já existe um preço para este produto e tamanho
                                final existingPrices = await supabase
                                    .from('produtos_precos')
                                    .select('id')
                                    .eq('produto_id', produto['id'])
                                    .eq('tamanho_id', tamanhoId);

                                if (existingPrices.isNotEmpty) {
                                  // Atualizar preço existente
                                  await supabase
                                      .from('produtos_precos')
                                      .update({'preco': preco})
                                      .eq('produto_id', produto['id'])
                                      .eq('tamanho_id', tamanhoId);
                                } else {
                                  // Inserir novo preço
                                  await supabase.from('produtos_precos').insert({
                                    'produto_id': produto['id'],
                                    'tamanho_id': tamanhoId,
                                    'preco': preco,
                                  });
                                }
                              }
                            } else {
                              // Se campo vazio, deletar preço existente
                              await supabase
                                  .from('produtos_precos')
                                  .delete()
                                  .eq('produto_id', produto['id'])
                                  .eq('tamanho_id', tamanhoId);
                            }
                          }
                        }
                        
                        Navigator.of(dialogContext).pop();
                        
                        // Mostrar mensagem de sucesso e recarregar dados
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Preços de "${produto['nome']}" atualizados com sucesso!'),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          
                          // Forçar rebuild do widget pai
                          final produtosContent = context.findAncestorStateOfType<_ProdutosContentState>();
                          produtosContent?._loadData();
                        }
                        
                      } catch (e) {
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao salvar preços: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text('Salvar Alterações'),
                  ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Dispose dos controllers
      for (final controller in priceControllers.values) {
        controller.dispose();
      }
    });
  }
}
