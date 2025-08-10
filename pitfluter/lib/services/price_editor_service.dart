import 'package:supabase_flutter/supabase_flutter.dart';

/// Model class for product with prices by size
class ProductWithPrices {
  final int id;
  final String name;
  final int categoryId;
  final String? description;
  final Map<int, double?> pricesBySize; // tamanho_id -> preco
  final Map<int, String> sizeNames; // tamanho_id -> nome_tamanho

  ProductWithPrices({
    required this.id,
    required this.name,
    required this.categoryId,
    this.description,
    required this.pricesBySize,
    required this.sizeNames,
  });

  /// Create a copy of this product with updated prices
  ProductWithPrices copyWith({
    Map<int, double?>? pricesBySize,
  }) {
    return ProductWithPrices(
      id: id,
      name: name,
      categoryId: categoryId,
      description: description,
      pricesBySize: pricesBySize ?? this.pricesBySize,
      sizeNames: sizeNames,
    );
  }

  /// Get price for a specific size
  double? getPriceForSize(int sizeId) => pricesBySize[sizeId];

  /// Set price for a specific size
  void setPriceForSize(int sizeId, double? price) {
    pricesBySize[sizeId] = price;
  }

  /// Check if the product has any prices
  bool get hasPrices => pricesBySize.values.any((price) => price != null);

  @override
  String toString() {
    return 'ProductWithPrices(id: $id, name: $name, categoryId: $categoryId)';
  }
}

/// Service class for managing product price editing operations
class PriceEditorService {
  static final _supabase = Supabase.instance.client;

  /// Size IDs constants
  static const int pequenaId = 1;
  static const int mediaId = 2;
  static const int grandeId = 3;
  static const int familiaId = 4;

  /// Category IDs constants  
  static const int pizzasSalgadasId = 1;
  static const int pizzasDocesId = 2;

  /// Fetch all pizza products with their prices organized by size
  /// Returns products grouped by category (Pizzas Salgadas and Pizzas Doces)
  Future<Map<String, List<ProductWithPrices>>> fetchAllPizzasWithPrices() async {
    try {
      // First, fetch all sizes to build the size names map
      final sizesResponse = await _supabase
          .from('tamanhos')
          .select('id, nome')
          .order('id');

      final sizeNames = <int, String>{};
      for (final size in sizesResponse) {
        sizeNames[size['id'] as int] = size['nome'] as String;
      }

      // Fetch all pizza products (categories 1 and 2)
      final productsResponse = await _supabase
          .from('produtos')
          .select('''
            id, 
            nome, 
            categoria_id, 
            descricao,
            categorias!inner(id, nome)
          ''')
          .inFilter('categoria_id', [pizzasSalgadasId, pizzasDocesId])
          .order('categoria_id')
          .order('nome');

      // Fetch all prices for these products
      final productIds = productsResponse
          .map<int>((product) => product['id'] as int)
          .toList();

      final pricesResponse = await _supabase
          .from('produtos_precos')
          .select('produto_id, tamanho_id, preco')
          .inFilter('produto_id', productIds);

      // Build prices map: produto_id -> tamanho_id -> preco
      final pricesMap = <int, Map<int, double>>{};
      for (final priceData in pricesResponse) {
        final productId = priceData['produto_id'] as int;
        final sizeId = priceData['tamanho_id'] as int;
        final price = (priceData['preco'] as num).toDouble();

        pricesMap.putIfAbsent(productId, () => <int, double>{});
        pricesMap[productId]![sizeId] = price;
      }

      // Build ProductWithPrices objects
      final products = <ProductWithPrices>[];
      for (final productData in productsResponse) {
        final productId = productData['id'] as int;
        final pricesBySize = <int, double?>{
          pequenaId: pricesMap[productId]?[pequenaId],
          mediaId: pricesMap[productId]?[mediaId],
          grandeId: pricesMap[productId]?[grandeId],
          familiaId: pricesMap[productId]?[familiaId],
        };

        products.add(ProductWithPrices(
          id: productId,
          name: productData['nome'] as String,
          categoryId: productData['categoria_id'] as int,
          description: productData['descricao'] as String?,
          pricesBySize: pricesBySize,
          sizeNames: sizeNames,
        ));
      }

      // Group products by category
      final groupedProducts = <String, List<ProductWithPrices>>{
        'Pizzas Salgadas': [],
        'Pizzas Doces': [],
      };

      for (final product in products) {
        if (product.categoryId == pizzasSalgadasId) {
          groupedProducts['Pizzas Salgadas']!.add(product);
        } else if (product.categoryId == pizzasDocesId) {
          groupedProducts['Pizzas Doces']!.add(product);
        }
      }

      return groupedProducts;
    } catch (e) {
      throw Exception('Erro ao carregar produtos com preços: $e');
    }
  }

  /// Update a single product's price for a specific size
  Future<void> updateProductPrice({
    required int productId,
    required int sizeId,
    required double price,
  }) async {
    try {
      // Check if price record already exists
      final existingPrices = await _supabase
          .from('produtos_precos')
          .select('id')
          .eq('produto_id', productId)
          .eq('tamanho_id', sizeId);

      if (existingPrices.isNotEmpty) {
        // Update existing price
        await _supabase
            .from('produtos_precos')
            .update({'preco': price})
            .eq('produto_id', productId)
            .eq('tamanho_id', sizeId);
      } else {
        // Insert new price record
        await _supabase.from('produtos_precos').insert({
          'produto_id': productId,
          'tamanho_id': sizeId,
          'preco': price,
        });
      }
    } catch (e) {
      throw Exception('Erro ao atualizar preço do produto: $e');
    }
  }

  /// Delete a product's price for a specific size
  Future<void> deleteProductPrice({
    required int productId,
    required int sizeId,
  }) async {
    try {
      await _supabase
          .from('produtos_precos')
          .delete()
          .eq('produto_id', productId)
          .eq('tamanho_id', sizeId);
    } catch (e) {
      throw Exception('Erro ao deletar preço do produto: $e');
    }
  }

  /// Batch update multiple product prices
  /// [updates] Map of productId -> sizeId -> price
  Future<void> batchUpdatePrices(Map<int, Map<int, double?>> updates) async {
    try {
      for (final productId in updates.keys) {
        final productUpdates = updates[productId]!;
        
        for (final sizeId in productUpdates.keys) {
          final price = productUpdates[sizeId];
          
          if (price != null) {
            // Update or insert price
            await updateProductPrice(
              productId: productId,
              sizeId: sizeId,
              price: price,
            );
          } else {
            // Delete price if null
            await deleteProductPrice(
              productId: productId,
              sizeId: sizeId,
            );
          }
        }
      }
    } catch (e) {
      throw Exception('Erro ao atualizar preços em lote: $e');
    }
  }

  /// Validate price value
  static bool isValidPrice(String value) {
    if (value.isEmpty) return true; // Empty is valid (will be null)
    
    final price = double.tryParse(value.replaceAll(',', '.'));
    return price != null && price > 0;
  }

  /// Parse price string to double
  static double? parsePrice(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.'));
  }

  /// Format price for display
  static String formatPrice(double? price) {
    if (price == null) return '';
    return price.toStringAsFixed(2).replaceAll('.', ',');
  }
}