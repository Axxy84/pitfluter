// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script de teste para Claude Code executar
/// Verifica se todas as funcionalidades estão funcionando

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://lhvfacztsbflrtfibeek.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM4NzI5NzAsImV4cCI6MjA0OTQ0ODk3MH0.67e122dad62fb48482b22a3a238bfebe218cde3e',
  );

  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teste Pitfluter',
      home: TestScreen(),
    );
  }
}

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final supabase = Supabase.instance.client;
  List<String> resultados = [];

  @override
  void initState() {
    super.initState();
    executarTestes();
  }

  Future<void> executarTestes() async {
    resultados.clear();

    try {
      // Teste 1: Conectar ao Supabase
      resultados.add('✅ Conectado ao Supabase');

      // Teste 2: Verificar tabelas
      await testarTabelas();

      // Teste 3: Verificar categorias
      await testarCategorias();

      // Teste 4: Verificar produtos
      await testarProdutos();

      // Teste 5: Verificar preços
      await testarPrecos();

      // Teste 6: Verificar pizzas doces especificamente
      await testarPizzasDoces();
    } catch (e) {
      resultados.add('❌ Erro: $e');
    }

    setState(() {});
  }

  Future<void> testarTabelas() async {
    final tables = await supabase.rpc('get_tables');
    resultados.add('✅ Tabelas encontradas: ${tables.length}');
  }

  Future<void> testarCategorias() async {
    final categorias = await supabase.from('categorias').select('*');
    resultados.add('✅ Categorias: ${categorias.length} encontradas');

    for (final cat in categorias) {
      resultados.add('   - ${cat['nome']}');
    }
  }

  Future<void> testarProdutos() async {
    final produtos = await supabase.from('produtos').select('*');
    resultados.add('✅ Produtos: ${produtos.length} encontrados');
  }

  Future<void> testarPrecos() async {
    final precos = await supabase.from('produtos_precos').select('*');
    resultados.add('✅ Preços: ${precos.length} encontrados');
  }

  Future<void> testarPizzasDoces() async {
    final pizzasDoces = await supabase.from('produtos').select('''
          nome,
          produtos_precos (
            preco,
            produtos_tamanho ( nome )
          )
        ''').eq('categoria_id', 2); // ID da categoria Pizzas Doces

    resultados.add('✅ Pizzas Doces: ${pizzasDoces.length} encontradas');

    for (final pizza in pizzasDoces) {
      final precos = pizza['produtos_precos'] as List;
      resultados.add('   - ${pizza['nome']}: ${precos.length} preços');

      for (final preco in precos) {
        final tamanho = preco['produtos_tamanho']?['nome'] ?? '?';
        final valor = preco['preco'];
        resultados.add('     * $tamanho: R\$ $valor');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teste Pitfluter - Claude Code'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🧪 Testes Automatizados',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Claude Code executando verificações...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: resultados.length,
                itemBuilder: (context, index) {
                  final resultado = resultados[index];
                  final isSuccess = resultado.startsWith('✅');
                  final isError = resultado.startsWith('❌');

                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isError
                          ? Colors.red[50]
                          : isSuccess
                              ? Colors.green[50]
                              : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isError
                            ? Colors.red
                            : isSuccess
                                ? Colors.green
                                : Colors.grey,
                      ),
                    ),
                    child: Text(
                      resultado,
                      style: TextStyle(
                        color: isError
                            ? Colors.red[800]
                            : isSuccess
                                ? Colors.green[800]
                                : Colors.grey[800],
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: executarTestes,
              child: Text('🔄 Executar Testes Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
