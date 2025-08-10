import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/price_editor_service.dart';

class PriceEditorScreen extends StatefulWidget {
  const PriceEditorScreen({super.key});

  @override
  State<PriceEditorScreen> createState() => _PriceEditorScreenState();
}

class _PriceEditorScreenState extends State<PriceEditorScreen> {
  final PriceEditorService _priceService = PriceEditorService();
  final Map<String, GlobalKey<FormState>> _formKeys = {
    'Pizzas Salgadas': GlobalKey<FormState>(),
    'Pizzas Doces': GlobalKey<FormState>(),
  };

  Map<String, List<ProductWithPrices>> _products = {};
  final Map<int, Map<int, TextEditingController>> _priceControllers = {};
  final Map<int, Map<int, bool>> _changedPrices = {};
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  // Size names for display
  final Map<int, String> _sizeNames = {
    PriceEditorService.pequenaId: 'Pequena',
    PriceEditorService.mediaId: 'Média',
    PriceEditorService.grandeId: 'Grande',
    PriceEditorService.familiaId: 'Família',
  };

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    // Dispose all text controllers
    for (final productControllers in _priceControllers.values) {
      for (final controller in productControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final products = await _priceService.fetchAllPizzasWithPrices();
      
      _setupControllers(products);
      
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _setupControllers(Map<String, List<ProductWithPrices>> products) {
    _priceControllers.clear();
    _changedPrices.clear();

    for (final categoryProducts in products.values) {
      for (final product in categoryProducts) {
        _priceControllers[product.id] = {};
        _changedPrices[product.id] = {};

        for (final sizeId in _sizeNames.keys) {
          final controller = TextEditingController(
            text: PriceEditorService.formatPrice(product.getPriceForSize(sizeId)),
          );
          
          controller.addListener(() => _onPriceChanged(product.id, sizeId));
          
          _priceControllers[product.id]![sizeId] = controller;
          _changedPrices[product.id]![sizeId] = false;
        }
      }
    }
  }

  void _onPriceChanged(int productId, int sizeId) {
    setState(() {
      _changedPrices[productId]![sizeId] = true;
    });
  }

  bool get _hasChanges {
    return _changedPrices.values.any(
      (productChanges) => productChanges.values.any((changed) => changed),
    );
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges) return;

    // Validate all forms
    bool allValid = true;
    for (final formKey in _formKeys.values) {
      if (formKey.currentState != null && !formKey.currentState!.validate()) {
        allValid = false;
      }
    }

    if (!allValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrija os erros antes de salvar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await _showSaveConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isSaving = true);

    try {
      final updates = <int, Map<int, double?>>{};

      for (final productId in _changedPrices.keys) {
        final productChanges = _changedPrices[productId]!;
        final hasProductChanges = productChanges.values.any((changed) => changed);

        if (hasProductChanges) {
          updates[productId] = {};
          
          for (final sizeId in productChanges.keys) {
            if (productChanges[sizeId]!) {
              final controller = _priceControllers[productId]![sizeId]!;
              final price = PriceEditorService.parsePrice(controller.text);
              updates[productId]![sizeId] = price;
            }
          }
        }
      }

      await _priceService.batchUpdatePrices(updates);

      // Reset change tracking
      for (final productId in _changedPrices.keys) {
        for (final sizeId in _changedPrices[productId]!.keys) {
          _changedPrices[productId]![sizeId] = false;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preços salvos com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar preços: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<bool> _showSaveConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Alterações'),
        content: const Text('Deseja salvar todas as alterações de preços?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _resetChanges() async {
    if (!_hasChanges) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar Alterações'),
        content: const Text('Deseja descartar todas as alterações não salvas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      await _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor de Preços'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          if (_hasChanges) ...[
            IconButton(
              onPressed: _isSaving ? null : _resetChanges,
              icon: const Icon(Icons.refresh),
              tooltip: 'Descartar alterações',
            ),
            IconButton(
              onPressed: _isSaving ? null : _saveChanges,
              icon: _isSaving 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              tooltip: 'Salvar alterações',
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando produtos...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar produtos',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Text('Nenhum produto encontrado'),
      );
    }

    return DefaultTabController(
      length: _products.keys.length,
      child: Column(
        children: [
          TabBar(
            tabs: _products.keys
                .map((category) => Tab(text: category))
                .toList(),
          ),
          Expanded(
            child: TabBarView(
              children: _products.entries
                  .map((entry) => _buildCategoryView(entry.key, entry.value))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryView(String category, List<ProductWithPrices> products) {
    return Form(
      key: _formKeys[category],
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(products[index]);
        },
      ),
    );
  }

  Widget _buildProductCard(ProductWithPrices product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (product.description != null) ...[
              const SizedBox(height: 4),
              Text(
                product.description!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            _buildPriceFields(product),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceFields(ProductWithPrices product) {
    return Row(
      children: _sizeNames.entries.map((sizeEntry) {
        final sizeId = sizeEntry.key;
        final sizeName = sizeEntry.value;
        final controller = _priceControllers[product.id]![sizeId]!;
        final isChanged = _changedPrices[product.id]![sizeId]!;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: sizeName,
                prefixText: 'R\$ ',
                border: const OutlineInputBorder(),
                filled: isChanged,
                fillColor: isChanged 
                    ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                    : null,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!PriceEditorService.isValidPrice(value)) {
                    return 'Preço inválido';
                  }
                }
                return null;
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}