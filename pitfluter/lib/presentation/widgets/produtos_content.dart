import 'package:flutter/material.dart';
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
      // Carregar categorias
      final todasCategoriasResponse = await supabase
          .from('produtos_categoria')
          .select('*')
          .eq('ativo', true)
          .order('nome');

      final todasCategorias = List<Map<String, dynamic>>.from(todasCategoriasResponse);
      
      // Mapear categorias
      final mapeamentoCategorias = {
        'Pizzas': ['pizza', 'pizzas especiais', 'pizzas salgadas', 'pizzas doces'],
        'Refrigerantes': ['bebida', 'bebidas', 'drink', 'drinks', 'cerveja', 'cervejas'],
        'Sucos': ['suco', 'sucos', 'juice', 'juices', 'natural'],
        'Bordas': ['borda', 'bordas', 'bordas recheadas'],
      };
      
      categorias = [];
      
      for (String categoriaDesejada in mapeamentoCategorias.keys) {
        final palavrasChave = mapeamentoCategorias[categoriaDesejada]!;
        
        final categoriaEncontrada = todasCategorias.firstWhere(
          (cat) => palavrasChave.any((palavra) => 
            cat['nome']?.toString().toLowerCase().contains(palavra.toLowerCase()) == true
          ),
          orElse: () => <String, dynamic>{},
        );
        
        if (categoriaEncontrada.isNotEmpty) {
          categorias.add({
            'id': categoriaEncontrada['id'],
            'nome': categoriaDesejada,
            'nome_banco': categoriaEncontrada['nome'],
          });
        }
      }
      
      // Inicializar TabController
      _tabController = TabController(
        length: categorias.length + 1,
        vsync: this,
      );
      
      _tabController?.addListener(() {
        setState(() {
          selectedCategoriaId = _tabController!.index == 0 
              ? 0 
              : categorias[_tabController!.index - 1]['id'];
        });
        _filterProdutos();
      });

      // Carregar produtos
      final produtosResponse = await supabase
          .from('produtos')
          .select('*, produtos_categoria(*)')
          .order('nome');

      produtos = List<Map<String, dynamic>>.from(produtosResponse);
      _filterProdutos();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
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
        if (selectedCategoriaId != 0 && produto['categoria_id'] != selectedCategoriaId) {
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
          final descricao = produto['descricao']?.toString().toLowerCase() ?? '';
          
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
                      Text(
                        'Gerencie o catálogo de produtos',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
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
                          // TODO: Adicionar produto
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
              if (_tabController != null) ...[
                const SizedBox(height: 16),
                TabBar(
                  controller: _tabController,
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
                          Icon(Icons.error_outline, size: 48, color: colorScheme.error),
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
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 250,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: filteredProdutos.length,
                            // Lazy loading: renderiza apenas os visíveis
                            cacheExtent: 100, // Reduz cache para economizar memória
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final produto = filteredProdutos[index];
                              return _ProdutoCard(
                                key: ValueKey(produto['id']), // Melhora performance com keys
                                produto: produto,
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

  const _ProdutoCard({super.key, required this.produto});

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
    final categoria = produto['produtos_categoria'];
    
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
          // TODO: Editar produto
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
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          );
                        },
                      )
                    : Icon(
                        _getIconForCategory(produto['tipo_produto']),
                        size: 48,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                    
                    // Preço
                    Text(
                      'R\$ ${(produto['preco'] ?? 0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Status
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
}