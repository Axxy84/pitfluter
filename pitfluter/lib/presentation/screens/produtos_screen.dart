import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen>
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
      // Carregar todas as categorias do banco
      final todasCategoriasResponse = await supabase
          .from('categorias')
          .select('*')
          .eq('ativo', true)
          .order('nome');

      final todasCategorias = List<Map<String, dynamic>>.from(todasCategoriasResponse);
      
      // Debug: mostrar todas as categorias encontradas no banco (desenvolvimento)
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        debugPrint('Categorias encontradas no banco:');
        for (var cat in todasCategorias) {
          debugPrint('- ID: ${cat['id']}, Nome: ${cat['nome']}');
        }
      }
      
      // Mapear categorias do banco para categorias desejadas (baseado nas categorias reais encontradas)
      final mapeamentoCategorias = {
        'Pizzas': ['pizza', 'pizzas especiais', 'pizzas salgadas', 'pizzas doces'],
        'Refrigerantes': ['bebida', 'bebidas', 'drink', 'drinks', 'cerveja', 'cervejas'],
        'Sucos': ['suco', 'sucos', 'juice', 'juices', 'natural'],
        'Bordas': ['borda', 'bordas', 'bordas recheadas'],
      };
      
      categorias = [];
      
      for (String categoriaDesejada in mapeamentoCategorias.keys) {
        final palavrasChave = mapeamentoCategorias[categoriaDesejada]!;
        
        // Procurar categoria no banco que corresponda às palavras-chave
        final categoriaEncontrada = todasCategorias.firstWhere(
          (cat) => palavrasChave.any((palavra) => 
            cat['nome']?.toString().toLowerCase().contains(palavra.toLowerCase()) == true
          ),
          orElse: () => <String, dynamic>{},
        );
        
        if (categoriaEncontrada.isNotEmpty) {
          // Usar o nome padrão mas manter o ID do banco
          if (const bool.fromEnvironment('dart.vm.product') == false) {
            debugPrint('Mapeamento: $categoriaDesejada -> ${categoriaEncontrada['nome']} (ID: ${categoriaEncontrada['id']})');
          }
          categorias.add({
            'id': categoriaEncontrada['id'],
            'nome': categoriaDesejada,
            'nome_banco': categoriaEncontrada['nome'],
          });
        } else {
          // Categoria não encontrada no banco
          if (const bool.fromEnvironment('dart.vm.product') == false) {
            debugPrint('Categoria não encontrada no banco: $categoriaDesejada');
          }
          categorias.add({
            'id': null,
            'nome': categoriaDesejada,
            'nome_banco': null,
          });
        }
      }

      // Configurar TabController
      _tabController = TabController(
        length: categorias.length + 1, // +1 para "Todas"
        vsync: this,
      );

      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          final index = _tabController!.index;
          if (index == 0) {
            _loadProdutos(); // Todas as categorias
          } else {
            final categoria = categorias[index - 1];
            _loadProdutos(
              categoriaId: categoria['id'], 
              categoriaNome: categoria['nome']
            );
          }
        }
      });

      // Carregar todos os produtos inicialmente
      await _loadProdutos();

    } catch (e) {
      setState(() {
        error = 'Erro ao carregar dados: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadProdutos({int? categoriaId, String? categoriaNome}) async {
    try {
      // Carregar todos os produtos com suas categorias (ativos e inativos)
      final produtosResponse = await supabase
          .from('produtos')
          .select('*, categorias(id, nome)')
          .order('nome');

      List<Map<String, dynamic>> todosProdutos = List<Map<String, dynamic>>.from(produtosResponse);
      
      // Debug: mostrar categorias de produtos únicos
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        final categoriasUnicas = <String>{};
        for (var produto in todosProdutos) {
          final categoria = produto['categorias'];
          if (categoria != null && categoria['nome'] != null) {
            categoriasUnicas.add(categoria['nome'].toString());
          }
        }
        debugPrint('Categorias de produtos encontradas: ${categoriasUnicas.toList()}');
        debugPrint('Total de produtos: ${todosProdutos.length}');
      }
      
      // Filtrar por categoria se especificado
      if (categoriaId != null || categoriaNome != null) {
        final produtosAntesFiltro = todosProdutos.length;
        
        todosProdutos = todosProdutos.where((produto) {
          final produtoCategoria = produto['categorias'];
          if (produtoCategoria == null) return false;
          
          // Verificar por ID da categoria
          if (categoriaId != null && produtoCategoria['id'] == categoriaId) {
            return true;
          }
          
          // Verificar por mapeamento de nomes
          if (categoriaNome != null) {
            final mapeamentoCategorias = {
              'Pizzas': ['pizza', 'pizzas especiais', 'pizzas salgadas', 'pizzas doces'],
              'Refrigerantes': ['bebida', 'bebidas', 'drink', 'drinks', 'cerveja', 'cervejas'],
              'Sucos': ['suco', 'sucos', 'juice', 'juices', 'natural'],
              'Bordas': ['borda', 'bordas', 'bordas recheadas'],
            };
            
            final palavrasChave = mapeamentoCategorias[categoriaNome] ?? [];
            final nomeCategoriaProduto = produtoCategoria['nome']?.toString().toLowerCase() ?? '';
            final tipoProduto = produto['tipo_produto']?.toString().toLowerCase() ?? '';
            final nomeProduto = produto['nome']?.toString().toLowerCase() ?? '';
            
            // Lógica especial para sucos: se é categoria "bebida" mas o nome do produto contém "suco"
            bool match = false;
            
            if (categoriaNome == 'Sucos') {
              // Para sucos: deve ter "bebida" na categoria E "suco" no nome do produto
              if (nomeCategoriaProduto.contains('bebida')) {
                match = nomeProduto.contains('suco') || nomeProduto.contains('juice') || nomeProduto.contains('natural');
              } else {
                // Ou conter diretamente palavras de suco
                match = palavrasChave.any((palavra) => 
                  nomeCategoriaProduto.contains(palavra.toLowerCase()) ||
                  tipoProduto.contains(palavra.toLowerCase()) ||
                  nomeProduto.contains(palavra.toLowerCase())
                );
              }
            } else if (categoriaNome == 'Refrigerantes') {
              // Para refrigerantes: categoria "bebida" mas NÃO deve ter "suco" no nome
              if (nomeCategoriaProduto.contains('bebida')) {
                match = !nomeProduto.contains('suco') && !nomeProduto.contains('juice');
              } else {
                // Ou outras categorias específicas de refrigerantes
                match = palavrasChave.any((palavra) => 
                  nomeCategoriaProduto.contains(palavra.toLowerCase()) ||
                  tipoProduto.contains(palavra.toLowerCase())
                );
              }
            } else {
              // Para outras categorias, usar busca normal
              match = palavrasChave.any((palavra) => 
                nomeCategoriaProduto.contains(palavra.toLowerCase()) ||
                tipoProduto.contains(palavra.toLowerCase()) ||
                nomeProduto.contains(palavra.toLowerCase())
              );
            }
            
            // Debug temporário
            if (const bool.fromEnvironment('dart.vm.product') == false && 
                (categoriaNome == 'Refrigerantes' || categoriaNome == 'Sucos')) {
              debugPrint('$categoriaNome - Produto: ${produto['nome']}, Categoria: $nomeCategoriaProduto, Tipo: $tipoProduto, Match: $match');
            }
            
            return match;
          }
          
          return false;
        }).toList();
        
        // Debug temporário
        if (const bool.fromEnvironment('dart.vm.product') == false) {
          debugPrint('Filtro $categoriaNome: $produtosAntesFiltro -> ${todosProdutos.length} produtos');
        }
      }
      
      setState(() {
        produtos = todosProdutos;
        selectedCategoriaId = categoriaId ?? 0;
        isLoading = false;
      });
      
      _filterProdutos();

    } catch (e) {
      setState(() {
        error = 'Erro ao carregar produtos: $e';
        isLoading = false;
      });
    }
  }
  
  void _filterProdutos() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      filteredProdutos = produtos.where((produto) {
        final matchesSearch = produto['nome'].toString().toLowerCase().contains(query) ||
                            (produto['descricao']?.toString().toLowerCase().contains(query) ?? false);
        final matchesStatus = _showInactive || produto['ativo'] == true;
        
        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: _tabController != null ? TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: [
            const Tab(text: 'Todas'),
            ...categorias.map((cat) => Tab(text: cat['nome'])),
          ],
        ) : null,
      ),
      body: Column(
        children: [
          // Filtros e busca
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar produtos...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
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
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(),
        tooltip: 'Adicionar Produto',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
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

    if (error != null) {
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
              error!,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (filteredProdutos.isEmpty && produtos.isNotEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64),
            SizedBox(height: 16),
            Text(
              'Nenhum produto encontrado para os filtros aplicados',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (produtos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64),
            SizedBox(height: 16),
            Text(
              'Nenhum produto encontrado',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredProdutos.length,
        itemBuilder: (context, index) {
          return _ProdutoCard(produto: filteredProdutos[index]);
        },
      ),
    );
  }
  
  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddProductDialog(
        onProductAdded: () {
          _loadProdutos(); // Recarregar lista após adicionar
        },
      ),
    );
  }
}

class _AddProductDialog extends StatefulWidget {
  final VoidCallback onProductAdded;
  
  const _AddProductDialog({required this.onProductAdded});
  
  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<_AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _estoqueController = TextEditingController();
  final supabase = Supabase.instance.client;
  
  String _categoriaSelecionada = 'Refrigerantes';
  bool _isLoading = false;
  
  final List<String> _categorias = ['Pizzas', 'Refrigerantes', 'Sucos', 'Bordas'];
  
  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _estoqueController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Novo Produto'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Templates rápidos
              const Text(
                'Templates Rápidos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildQuickTemplate('Coca Cola', 'Refrigerantes', 'Refrigerante gelado 350ml', 5.50),
                  _buildQuickTemplate('Guaraná', 'Refrigerantes', 'Refrigerante guaraná 350ml', 5.00),
                  _buildQuickTemplate('Suco Laranja', 'Sucos', 'Suco natural de laranja 300ml', 8.00),
                  _buildQuickTemplate('Suco Uva', 'Sucos', 'Suco natural de uva 300ml', 8.50),
                  _buildQuickTemplate('Borda Catupiry', 'Bordas', 'Borda recheada com catupiry', 12.00),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // Nome do produto
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto *',
                  hintText: 'Ex: Coca Cola, Guaraná...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Categoria
              DropdownButtonFormField<String>(
                value: _categoriaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Categoria *',
                  border: OutlineInputBorder(),
                ),
                items: _categorias.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSelecionada = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Descrição
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Descrição do produto...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  // Preço
                  Expanded(
                    child: TextFormField(
                      controller: _precoController,
                      decoration: const InputDecoration(
                        labelText: 'Preço *',
                        prefixText: 'R\$ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Preço obrigatório';
                        }
                        final preco = double.tryParse(value.replaceAll(',', '.'));
                        if (preco == null || preco <= 0) {
                          return 'Preço inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Estoque
                  Expanded(
                    child: TextFormField(
                      controller: _estoqueController,
                      decoration: const InputDecoration(
                        labelText: 'Estoque',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        if (const bool.fromEnvironment('dart.vm.product') == false)
          TextButton(
            onPressed: _isLoading ? null : _testConnection,
            child: const Text('Testar'),
          ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addProduct,
          child: _isLoading 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Adicionar'),
        ),
      ],
    );
  }
  
  Widget _buildQuickTemplate(String nome, String categoria, String descricao, double preco) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _nomeController.text = nome;
          _categoriaSelecionada = categoria;
          _descricaoController.text = descricao;
          _precoController.text = preco.toStringAsFixed(2).replaceAll('.', ',');
          _estoqueController.text = '10'; // Estoque padrão
        });
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 0),
      ),
      child: Text(
        nome,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
  
  Future<void> _testConnection() async {
    setState(() => _isLoading = true);
    
    try {
      // Testar conexão básica
      debugPrint('=== TESTE DE CONEXÃO ===');
      
      // 1. Testar select simples
      final selectTest = await supabase
          .from('categorias')
          .select('id, nome')
          .limit(1);
      debugPrint('Teste SELECT: $selectTest');
      
      // 2. Testar estrutura da tabela produtos
      try {
        final tableTest = await supabase
            .from('produtos')
            .select('*')
            .limit(1);
        debugPrint('Estrutura produtos: $tableTest');
      } catch (e) {
        debugPrint('Erro ao acessar produtos: $e');
        
        // Tentar outras variações do nome da tabela
        try {
          final altTest = await supabase
              .from('produtos')
              .select('*')
              .limit(1);
          debugPrint('Estrutura produtos: $altTest');
        } catch (e2) {
          debugPrint('Erro ao acessar produtos: $e2');
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teste concluído - verifique o console'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      
    } catch (e) {
      debugPrint('Erro no teste: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no teste: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final nome = _nomeController.text.trim();
      final descricao = _descricaoController.text.trim();
      final precoText = _precoController.text.replaceAll(',', '.');
      final preco = double.parse(precoText);
      final estoque = int.tryParse(_estoqueController.text) ?? 0;
      
      // Debug: log dos dados
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        debugPrint('Adicionando produto:');
        debugPrint('- Nome: $nome');
        debugPrint('- Categoria: $_categoriaSelecionada');
        debugPrint('- Descrição: $descricao');
        debugPrint('- Preço: $preco');
        debugPrint('- Estoque: $estoque');
      }
      
      // Primeiro, encontrar ou criar a categoria
      int? categoriaId = await _getOrCreateCategoriaId(_categoriaSelecionada);
      
      if (categoriaId == null) {
        throw Exception('Erro ao obter categoria');
      }
      
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        debugPrint('- Categoria ID: $categoriaId');
      }
      
      // Preparar dados do produto (campos básicos primeiro)
      final productData = <String, dynamic>{
        'nome': nome,
        'ativo': true,
        'descricao': descricao.isNotEmpty ? descricao : 'Produto sem descrição', // Campo obrigatório
      };
      
      // Tentar adicionar preço (pode ter nomes diferentes)
      try {
        productData['preco_unitario'] = preco;
      } catch (e) {
        // Fallback para outros nomes de campo possíveis
        productData['preco'] = preco;
      }
      
      // Tentar adicionar categoria
      try {
        productData['categoria_id'] = categoriaId;
      } catch (e) {
        if (const bool.fromEnvironment('dart.vm.product') == false) {
          debugPrint('Erro ao adicionar categoria_id, tentando category_id');
        }
        productData['category_id'] = categoriaId;
      }
      
      // Adicionar estoque se fornecido
      if (estoque > 0) {
        productData['estoque'] = estoque;
      }
      
      // Adicionar tipo se possível
      try {
        productData['tipo_produto'] = _getTipoProduto(_categoriaSelecionada);
      } catch (e) {
        productData['tipo'] = _getTipoProduto(_categoriaSelecionada);
      }
      
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        debugPrint('Dados a inserir: $productData');
      }
      
      // Criar o produto
      dynamic response;
      try {
        response = await supabase
            .from('produtos')
            .insert(productData)
            .select();
      } catch (insertError) {
        if (const bool.fromEnvironment('dart.vm.product') == false) {
          debugPrint('Erro no insert, tentando versão simplificada: $insertError');
        }
        
        // Fallback: tentar com dados mínimos
        final simpleData = {
          'nome': nome,
          'preco_unitario': preco,
          'ativo': true,
        };
        
        response = await supabase
            .from('produtos')
            .insert(simpleData)
            .select();
      }
      
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        debugPrint('Resposta do insert: $response');
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produto "$nome" adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onProductAdded();
      }
      
    } catch (e, stackTrace) {
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        debugPrint('Erro detalhado: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      
      String errorMessage = 'Erro desconhecido';
      
      // Tratar erros específicos do PostgreSQL
      if (e.toString().contains('duplicate key')) {
        errorMessage = 'Produto com este nome já existe';
      } else if (e.toString().contains('foreign key')) {
        errorMessage = 'Erro de categoria inválida';
      } else if (e.toString().contains('not null')) {
        errorMessage = 'Campo obrigatório não preenchido';
      } else if (e.toString().contains('invalid input')) {
        errorMessage = 'Dados inválidos fornecidos';
      } else {
        errorMessage = 'Erro ao salvar: ${e.toString()}';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<int?> _getOrCreateCategoriaId(String categoriaNome) async {
    try {
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        debugPrint('Buscando categoria para: $categoriaNome');
      }
      
      // Mapear categoria para nomes no banco
      final mapeamentoBanco = {
        'Pizzas': 'Pizzas Salgadas', // Usar uma categoria padrão de pizza
        'Refrigerantes': 'Bebidas',
        'Sucos': 'Bebidas', // Sucos também vão para bebidas
        'Bordas': 'Bordas Recheadas',
      };
      
      final nomeBanco = mapeamentoBanco[categoriaNome] ?? categoriaNome;
      
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        debugPrint('Nome no banco: $nomeBanco');
      }
      
      // Tentar encontrar categoria existente
      final response = await supabase
          .from('categorias')
          .select('id, nome')
          .eq('nome', nomeBanco)
          .maybeSingle();
      
      if (response != null) {
        if (const bool.fromEnvironment('dart.vm.product') == false) {
          debugPrint('Categoria encontrada: $response');
        }
        return response['id'] as int;
      }
      
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        debugPrint('Categoria não encontrada, criando nova...');
      }
      
      // Se não encontrar, criar uma nova categoria
      final newCategoryData = {
        'nome': nomeBanco,
        'ativo': true,
      };
      
      final newCategoryResponse = await supabase
          .from('categorias')
          .insert(newCategoryData)
          .select('id, nome')
          .single();
      
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        debugPrint('Nova categoria criada: $newCategoryResponse');
      }
      
      return newCategoryResponse['id'] as int;
      
    } catch (e, stackTrace) {
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        debugPrint('Erro ao obter/criar categoria: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
    }
  }
  
  String _getTipoProduto(String categoria) {
    switch (categoria) {
      case 'Pizzas':
        return 'pizza';
      case 'Refrigerantes':
      case 'Sucos':
        return 'bebida';
      case 'Bordas':
        return 'borda';
      default:
        return 'produto';
    }
  }
}

class _ProdutoCard extends StatefulWidget {
  final Map<String, dynamic> produto;

  const _ProdutoCard({required this.produto});

  @override
  State<_ProdutoCard> createState() => _ProdutoCardState();
}

class _ProdutoCardState extends State<_ProdutoCard> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> precos = [];
  bool loadingPrecos = false;

  @override
  void initState() {
    super.initState();
    _loadPrecos();
  }

  Future<void> _loadPrecos() async {
    setState(() {
      loadingPrecos = true;
    });

    try {
      final precosResponse = await supabase
          .from('produtos_precos')
          .select('*, tamanhos(nome)')
          .eq('produto_id', widget.produto['id']);

      setState(() {
        precos = List<Map<String, dynamic>>.from(precosResponse);
        loadingPrecos = false;
      });
    } catch (e) {
      setState(() {
        loadingPrecos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final produto = widget.produto;
    final categoria = produto['categorias'];
    
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(minHeight: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do produto
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: produto['imagem'] != null && produto['imagem'].isNotEmpty
                    ? Image.network(
                        produto['imagem'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          );
                        },
                      )
                    : Icon(
                        _getIconForCategory(produto['tipo_produto']),
                        size: 50,
                        color: Colors.grey,
                      ),
              ),
            ),
            
            // Detalhes do produto
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome do produto
                    Text(
                      produto['nome'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Categoria
                    if (categoria != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          categoria['nome'] ?? '',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),
                    
                    // Descrição
                    if (produto['descricao'] != null)
                      Expanded(
                        child: Text(
                          produto['descricao'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Preços
                    if (loadingPrecos)
                      const Center(
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      _buildPriceSection(produto),
                    
                    const SizedBox(height: 12),
                    
                    // Ações do produto
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Switch ativo/inativo
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: produto['ativo'] == true,
                            onChanged: (value) => _toggleProductStatus(produto, value),
                          ),
                        ),
                        
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botão editar
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editProduct(produto),
                              iconSize: 18,
                              padding: const EdgeInsets.all(4),
                            ),
                            
                            // Botão estoque
                            IconButton(
                              icon: const Icon(Icons.inventory),
                              onPressed: () => _showStock(produto),
                              iconSize: 18,
                              padding: const EdgeInsets.all(4),
                            ),
                          ],
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

  Widget _buildPriceSection(Map<String, dynamic> produto) {
    final categoria = produto['categorias'];
    final categoriaNome = categoria?['nome'] ?? '';
    
    // Para pizzas, mostrar preços por tamanho
    if (categoriaNome.toLowerCase().contains('pizza')) {
      return _buildPizzaPrices(produto);
    }
    
    // Para outros produtos, mostrar preço unitário ou primeiro preço da lista
    if (produto['preco_unitario'] != null) {
      return _buildEditablePrice(produto, '', produto['preco_unitario'].toDouble());
    } else if (precos.isNotEmpty) {
      return _buildEditablePrice(produto, '', precos.first['preco'].toDouble());
    } else {
      return const Text(
        'Preço não disponível',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      );
    }
  }
  
  Widget _buildPizzaPrices(Map<String, dynamic> produto) {
    // Buscar preços por tamanho ou usar valores padrão
    final precoP = _getPriceForSize('P') ?? 25.00;
    final precoM = _getPriceForSize('M') ?? 35.00;
    final precoG = _getPriceForSize('G') ?? 45.00;
    final precoF = _getPriceForSize('GG') ?? 55.00; // GG para Família
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildEditablePrice(produto, 'P', precoP)),
            const SizedBox(width: 4),
            Expanded(child: _buildEditablePrice(produto, 'M', precoM)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: _buildEditablePrice(produto, 'G', precoG)),
            const SizedBox(width: 4),
            Expanded(child: _buildEditablePrice(produto, 'F', precoF)),
          ],
        ),
      ],
    );
  }
  
  double? _getPriceForSize(String size) {
    final preco = precos.firstWhere(
      (p) => p['tamanhos']?['nome']?.toString().toUpperCase() == size,
      orElse: () => <String, dynamic>{},
    );
    return preco['preco']?.toDouble();
  }
  
  Widget _buildEditablePrice(Map<String, dynamic> produto, String size, double price) {
    return InkWell(
      onTap: () => _showPriceEditDialog(produto, size, price),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Text(
          size.isNotEmpty ? '$size: R\$ ${price.toStringAsFixed(2)}' : 'R\$ ${price.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  void _showPriceEditDialog(Map<String, dynamic> produto, String size, double currentPrice) {
    final controller = TextEditingController(text: currentPrice.toStringAsFixed(2));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Preço${size.isNotEmpty ? ' - Tamanho $size' : ''}'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          decoration: const InputDecoration(
            labelText: 'Preço',
            prefixText: 'R\$ ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPriceText = controller.text.replaceAll(',', '.');
              final newPrice = double.tryParse(newPriceText);
              
              if (newPrice != null && newPrice > 0) {
                _updateProductPrice(produto, size, newPrice);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preço inválido')),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _updateProductPrice(Map<String, dynamic> produto, String size, double newPrice) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salvando preço...'), duration: Duration(seconds: 1)),
      );
      
      if (size.isEmpty) {
        // Atualizar preço unitário
        await supabase
            .from('produtos')
            .update({'preco_unitario': newPrice})
            .eq('id', produto['id']);
      } else {
        // Atualizar preço por tamanho
        final precoItem = precos.firstWhere(
          (p) => p['tamanhos']?['nome']?.toString().toUpperCase() == size,
          orElse: () => <String, dynamic>{},
        );
        
        if (precoItem.isNotEmpty) {
          await supabase
              .from('produtos_precos')
              .update({'preco': newPrice})
              .eq('id', precoItem['id']);
        }
      }
      
      // Recarregar preços
      await _loadPrecos();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preço atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar preço: $e')),
        );
      }
    }
  }
  
  Future<void> _toggleProductStatus(Map<String, dynamic> produto, bool newStatus) async {
    try {
      await supabase
          .from('produtos')
          .update({'ativo': newStatus})
          .eq('id', produto['id']);
      
      setState(() {
        produto['ativo'] = newStatus;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus ? 'Produto ativado!' : 'Produto desativado!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao alterar status: $e')),
        );
      }
    }
  }
  
  void _editProduct(Map<String, dynamic> produto) {
    showDialog(
      context: context,
      builder: (context) => _EditProductDialog(
        produto: produto,
        onProductUpdated: () {
          // Recarregar dados do produto
          setState(() {});
          // Atualizar tela pai
          if (mounted) {
            (context.findAncestorStateOfType<_ProdutosScreenState>())?._loadData();
          }
        },
      ),
    );
  }
  
  void _showStock(Map<String, dynamic> produto) {
    final stock = produto['estoque'] ?? 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estoque'),
        content: Text('Quantidade em estoque: $stock unidades'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String? tipoProduto) {
    switch (tipoProduto) {
      case 'pizza':
        return Icons.local_pizza;
      case 'bebida':
        return Icons.local_drink;
      case 'sobremesa':
        return Icons.cake;
      case 'borda':
        return Icons.donut_small;
      default:
        return Icons.fastfood;
    }
  }
}

class _EditProductDialog extends StatefulWidget {
  final Map<String, dynamic> produto;
  final VoidCallback onProductUpdated;
  
  const _EditProductDialog({
    required this.produto,
    required this.onProductUpdated,
  });
  
  @override
  State<_EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<_EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _categorias = [];
  int? _categoriaSelecionada;
  List<Map<String, dynamic>> _precos = [];
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  void _initializeData() {
    final produto = widget.produto;
    _nomeController.text = produto['nome'] ?? '';
    _descricaoController.text = produto['descricao'] ?? '';
    _precoController.text = produto['preco_unitario']?.toString() ?? '';
    _categoriaSelecionada = produto['categoria_id'];
    
    _loadCategorias();
    _loadPrecos();
  }
  
  Future<void> _loadCategorias() async {
    try {
      final response = await supabase
          .from('categorias')
          .select('id, nome')
          .eq('ativo', true)
          .order('nome');
      
      setState(() {
        _categorias = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      // Erro ao carregar categorias
    }
  }
  
  Future<void> _loadPrecos() async {
    try {
      final response = await supabase
          .from('produtos_precos')
          .select('*, tamanhos(id, nome)')
          .eq('produto_id', widget.produto['id']);
      
      setState(() {
        _precos = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      // Erro ao carregar preços
    }
  }
  
  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Produto'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nome
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Produto',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Categoria
                if (_categorias.isNotEmpty)
                  DropdownButtonFormField<int>(
                    value: _categoriaSelecionada,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    items: _categorias.map((categoria) {
                      return DropdownMenuItem<int>(
                        value: categoria['id'],
                        child: Text(categoria['nome']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _categoriaSelecionada = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecione uma categoria';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),
                
                // Descrição
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                
                // Preço base
                TextFormField(
                  controller: _precoController,
                  decoration: const InputDecoration(
                    labelText: 'Preço Base (R\$)',
                    border: OutlineInputBorder(),
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Preço é obrigatório';
                    }
                    if (double.tryParse(value.replaceAll(',', '.')) == null) {
                      return 'Preço inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Preços por tamanho
                if (_precos.isNotEmpty) ...[
                  const Text(
                    'Preços por Tamanho:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._precos.map((preco) {
                    final tamanho = preco['tamanhos'];
                    return Card(
                      child: ListTile(
                        title: Text(tamanho['nome'] ?? 'Tamanho'),
                        subtitle: Text('R\$ ${preco['preco']?.toStringAsFixed(2) ?? '0.00'}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editPrice(preco),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateProduct,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
  
  void _editPrice(Map<String, dynamic> preco) {
    final controller = TextEditingController(text: preco['preco']?.toString() ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Preço - ${preco['tamanhos']['nome']}'),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Preço (R\$)',
            border: OutlineInputBorder(),
            prefixText: 'R\$ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final novoPreco = double.tryParse(controller.text.replaceAll(',', '.'));
              if (novoPreco != null) {
                await _updatePrice(preco['id'], novoPreco);
                if (!mounted) return;
                Navigator.pop(context);
                _loadPrecos();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _updatePrice(int precoId, double novoPreco) async {
    try {
      await supabase
          .from('produtos_precos')
          .update({'preco': novoPreco, 'preco_promocional': novoPreco})
          .eq('id', precoId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preço atualizado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar preço: $e')),
      );
    }
  }
  
  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final dados = {
        'nome': _nomeController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'categoria_id': _categoriaSelecionada,
        'preco_unitario': double.parse(_precoController.text.replaceAll(',', '.')),
      };
      
      await supabase
          .from('produtos')
          .update(dados)
          .eq('id', widget.produto['id']);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto atualizado com sucesso!')),
      );
      
      widget.onProductUpdated();
      Navigator.pop(context);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar produto: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}