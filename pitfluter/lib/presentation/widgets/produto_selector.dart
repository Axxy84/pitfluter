import 'package:flutter/material.dart';
import '../../domain/entities/produto.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/tamanho.dart';

class ProdutoSelector extends StatefulWidget {
  final List<Categoria> categorias;
  final List<Produto> produtos;
  final List<Tamanho> tamanhos;
  final Function(Produto produto, Tamanho tamanho) onProdutoSelected;
  final bool allowHalfAndHalf;

  const ProdutoSelector({
    super.key,
    required this.categorias,
    required this.produtos,
    required this.tamanhos,
    required this.onProdutoSelected,
    this.allowHalfAndHalf = false,
  });

  @override
  State<ProdutoSelector> createState() => _ProdutoSelectorState();
}

class _ProdutoSelectorState extends State<ProdutoSelector>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.categorias.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedCategoryIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Produto> get _filteredProdutos {
    if (widget.categorias.isEmpty) return [];
    
    final selectedCategory = widget.categorias[_selectedCategoryIndex];
    return widget.produtos
        .where((produto) => 
            produto.categoriaId == selectedCategory.id && produto.ativo)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Seletor de produtos',
      child: Column(
        children: [
          if (widget.categorias.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: const Color(0xFFDC2626),
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: const Color(0xFFDC2626),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
                tabs: widget.categorias
                    .map((categoria) => Tab(text: categoria.nome))
                    .toList(),
              ),
            ),
          Expanded(
            child: _filteredProdutos.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum produto disponível',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredProdutos.length,
                    itemBuilder: (context, index) {
                      final produto = _filteredProdutos[index];
                      return _ProdutoCard(
                        produto: produto,
                        onTap: () => _showSizeSelection(produto),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showSizeSelection(Produto produto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(produto.nome),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecionar Tamanho'),
            const SizedBox(height: 16),
            ...widget.tamanhos.map(
              (tamanho) => ListTile(
                title: Text(tamanho.nome),
                subtitle: Text('${(tamanho.fatorMultiplicador * 100).toInt()}%'),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onProdutoSelected(produto, tamanho);
                },
              ),
            ),
            if (widget.allowHalfAndHalf && _isPizza(produto))
              ListTile(
                title: const Text('Meio a Meio'),
                subtitle: const Text('Combine dois sabores'),
                leading: const Icon(Icons.pie_chart),
                onTap: () {
                  Navigator.of(context).pop();
                  _showHalfAndHalfSelection(produto);
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showHalfAndHalfSelection(Produto produto) {
    // Implementation for half-and-half selection
    // This would show another dialog to select two different products
  }

  bool _isPizza(Produto produto) {
    final categoria = widget.categorias
        .where((cat) => cat.id == produto.categoriaId)
        .firstOrNull;
    return categoria?.nome.toLowerCase().contains('pizza') ?? false;
  }
}

class _ProdutoCard extends StatelessWidget {
  final Produto produto;
  final VoidCallback onTap;

  const _ProdutoCard({
    required this.produto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: produto.imagemUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            produto.imagemUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.fastfood,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.fastfood,
                          size: 48,
                          color: Colors.grey,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (produto.descricao != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        produto.descricao!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${produto.tempoPreparoMinutos} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}