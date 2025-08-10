// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://akfmfdmsanobdaznfdjw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFrZm1mZG1zYW5vYmRhem5mZGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2NTQxMzgsImV4cCI6MjA0ODIzMDEzOH0.EfF8CeAehGgJy7sZg5LXnQgWKdPTwnQOiN5pjrPFzuo',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Criar Pizzas Doces',
      home: Scaffold(
        appBar: AppBar(title: const Text('Criar Pizzas Doces')),
        body: const CriarPizzasDoces(),
      ),
    );
  }
}

class CriarPizzasDoces extends StatefulWidget {
  const CriarPizzasDoces({super.key});

  @override
  State<CriarPizzasDoces> createState() => _CriarPizzasDocesState();
}

class _CriarPizzasDocesState extends State<CriarPizzasDoces> {
  final supabase = Supabase.instance.client;
  String status = 'Iniciando...';
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    criarPizzasDoces();
  }

  void addLog(String message) {
    setState(() {
      logs.add(message);
      status = message;
    });
  }

  Future<void> criarPizzasDoces() async {
    try {
      // 1. Buscar ou criar categoria "Pizzas Doces"
      addLog('Verificando categoria Pizzas Doces...');
      
      var categorias = await supabase
          .from('categorias')
          .select('id, nome')
          .or('nome.ilike.%pizza%doce%,nome.eq.Pizzas Doces');
      
      int categoriaId;
      
      if (categorias.isEmpty) {
        addLog('Categoria não encontrada. Criando...');
        
        final novaCategoria = await supabase
            .from('categorias')
            .insert({
              'nome': 'Pizzas Doces',
              'ativo': true
            })
            .select()
            .single();
        
        categoriaId = novaCategoria['id'];
        addLog('✅ Categoria criada com ID: $categoriaId');
      } else {
        categoriaId = categorias.first['id'];
        addLog('✅ Categoria encontrada: ${categorias.first['nome']} (ID: $categoriaId)');
      }
      
      // 2. Buscar tamanhos disponíveis
      addLog('Buscando tamanhos...');
      final tamanhos = await supabase
          .from('tamanhos')
          .select('id, nome')
          .order('id');
      
      addLog('Tamanhos encontrados: ${tamanhos.length}');
      
      // 3. Criar pizzas doces se não existirem
      addLog('Criando pizzas doces...');
      
      final pizzasDoces = [
        {
          'nome': 'Pizza de Chocolate',
          'descricao': 'Pizza doce com chocolate ao leite, granulado e morangos',
          'tipo': 'pizza'
        },
        {
          'nome': 'Pizza de Morango com Nutella',
          'descricao': 'Pizza doce com Nutella e morangos frescos',
          'tipo': 'pizza'
        },
        {
          'nome': 'Pizza Romeu e Julieta',
          'descricao': 'Pizza doce com goiabada e queijo',
          'tipo': 'pizza'
        },
        {
          'nome': 'Pizza de Banana com Canela',
          'descricao': 'Pizza doce com banana, açúcar e canela',
          'tipo': 'pizza'
        },
        {
          'nome': 'Pizza de Brigadeiro',
          'descricao': 'Pizza doce com brigadeiro e granulado',
          'tipo': 'pizza'
        },
        {
          'nome': 'Pizza de Prestígio',
          'descricao': 'Pizza doce com chocolate e coco ralado',
          'tipo': 'pizza'
        },
        {
          'nome': 'Pizza de Doce de Leite',
          'descricao': 'Pizza doce com doce de leite e coco',
          'tipo': 'pizza'
        }
      ];
      
      int criadas = 0;
      int jaExistentes = 0;
      
      for (var pizza in pizzasDoces) {
        // Verificar se já existe
        final existe = await supabase
            .from('produtos')
            .select('id')
            .eq('nome', pizza['nome']!)
            .maybeSingle();
        
        if (existe != null) {
          addLog('Pizza "${pizza['nome']}" já existe');
          jaExistentes++;
          continue;
        }
        
        // Criar produto
        final produto = await supabase
            .from('produtos')
            .insert({
              'nome': pizza['nome'],
              'descricao': pizza['descricao'],
              'categoria_id': categoriaId,
              'tipo_produto': pizza['tipo'],
              'preco_unitario': 35.00, // Preço base
              'ativo': true
            })
            .select()
            .single();
        
        addLog('✅ Pizza "${pizza['nome']}" criada');
        criadas++;
        
        // Criar preços por tamanho
        final precos = [
          {'tamanho': 'P', 'preco': 30.00},
          {'tamanho': 'M', 'preco': 40.00},
          {'tamanho': 'G', 'preco': 50.00},
          {'tamanho': 'GG', 'preco': 60.00},
        ];
        
        for (var precoInfo in precos) {
          // Buscar ID do tamanho
          final tamanho = tamanhos.firstWhere(
            (t) => t['nome'] == precoInfo['tamanho'],
            orElse: () => {'id': null}
          );
          
          if (tamanho['id'] != null) {
            await supabase
                .from('produtos_precos')
                .insert({
                  'produto_id': produto['id'],
                  'tamanho_id': tamanho['id'],
                  'preco': precoInfo['preco'],
                  'preco_promocional': precoInfo['preco']
                });
          }
        }
      }
      
      addLog('');
      addLog('=== PROCESSO CONCLUÍDO ===');
      addLog('Pizzas criadas: $criadas');
      addLog('Pizzas já existentes: $jaExistentes');
      addLog('Total de pizzas doces: ${criadas + jaExistentes}');
      
    } catch (e) {
      addLog('❌ Erro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              status,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    return Text(logs[index]);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => criarPizzasDoces(),
              child: const Text('Executar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}