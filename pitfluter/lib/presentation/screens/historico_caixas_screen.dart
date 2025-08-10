import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoricoCaixasScreen extends StatefulWidget {
  const HistoricoCaixasScreen({super.key});

  @override
  State<HistoricoCaixasScreen> createState() => _HistoricoCaixasScreenState();
}

class _HistoricoCaixasScreenState extends State<HistoricoCaixasScreen> {
  final formatoMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final formatoData = DateFormat('dd/MM/yyyy');
  final formatoHora = DateFormat('HH:mm');
  final _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> caixasHistorico = [];
  bool isLoading = true;
  String? selectedMonth;
  String? selectedYear;
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> meses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];
  
  final List<String> anos = ['2025', '2024', '2023', '2022'];
  
  @override
  void initState() {
    super.initState();
    selectedMonth = meses[DateTime.now().month - 1];
    selectedYear = DateTime.now().year.toString();
    _carregarHistorico();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarHistorico() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      // Buscar caixas fechados do Supabase
      final response = await _supabase
          .from('caixa')
          .select()
          .not('hora_fechamento', 'is', null)
          .order('data_abertura', ascending: false);
      
      final List<Map<String, dynamic>> caixasProcessados = [];
      
      for (final caixa in response) {
        final dataAbertura = DateTime.parse(caixa['data_abertura']);
        final dataFechamento = caixa['hora_fechamento'] != null 
            ? DateTime.parse(caixa['hora_fechamento']) 
            : null;
        
        caixasProcessados.add({
          'id': caixa['id'].toString(),
          'numero': 'CX${caixa['id'].toString().padLeft(3, '0')}',
          'data': dataAbertura,
          'operador': caixa['operador_nome'] ?? 'Não informado',
          'abertura': dataAbertura,
          'fechamento': dataFechamento,
          'valorInicial': (caixa['valor_inicial'] ?? 0).toDouble(),
          'valorFinal': (caixa['valor_final'] ?? 0).toDouble(),
          'totalVendas': (caixa['valor_vendas'] ?? 0).toDouble(),
          'totalDinheiro': (caixa['valor_dinheiro'] ?? 0).toDouble(),
          'totalCartao': (caixa['valor_cartao'] ?? 0).toDouble(),
          'totalPix': (caixa['valor_pix'] ?? 0).toDouble(),
          'diferenca': ((caixa['valor_final'] ?? 0) - (caixa['valor_inicial'] ?? 0) - (caixa['valor_vendas'] ?? 0)).toDouble(),
        });
      }
      
      if (!mounted) return;
      
      setState(() {
        caixasHistorico = caixasProcessados;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        caixasHistorico = [];
        isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar histórico: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
  
  List<Map<String, dynamic>> get caixasFiltrados {
    var caixas = caixasHistorico;
    
    // Filtro por mês/ano
    if (selectedMonth != null && selectedYear != null) {
      final mesIndex = meses.indexOf(selectedMonth!) + 1;
      final ano = int.tryParse(selectedYear!) ?? DateTime.now().year;
      
      caixas = caixas.where((caixa) {
        final data = caixa['data'] as DateTime;
        return data.month == mesIndex && data.year == ano;
      }).toList();
    }
    
    // Filtro por busca
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      caixas = caixas.where((caixa) {
        final numero = caixa['numero'].toString().toLowerCase();
        final operador = caixa['operador'].toString().toLowerCase();
        return numero.contains(searchQuery) || operador.contains(searchQuery);
      }).toList();
    }
    
    return caixas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.history),
            SizedBox(width: 8),
            Text('Histórico de Caixas'),
          ],
        ),
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Estatísticas no topo
                _buildEstatisticas(),
                
                // Filtros
                _buildFiltros(),
                
                // Lista de caixas
                Expanded(
                  child: _buildListaCaixas(),
                ),
              ],
            ),
    );
  }

  Widget _buildEstatisticas() {
    final caixasFiltro = caixasFiltrados;
    final totalMes = caixasFiltro.fold<double>(
      0, (sum, item) => sum + item['totalVendas'],
    );
    final mediaDiaria = caixasFiltro.isNotEmpty ? totalMes / caixasFiltro.length : 0;
    final melhorDia = caixasFiltro.fold<double>(
      0, (max, item) => item['totalVendas'] > max ? item['totalVendas'] : max,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Expanded(
            child: _buildCardEstatistica(
              'Total do Mês',
              formatoMoeda.format(totalMes),
              Icons.attach_money,
              Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildCardEstatistica(
              'Média Diária',
              formatoMoeda.format(mediaDiaria),
              Icons.trending_up,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildCardEstatistica(
              'Melhor Dia',
              formatoMoeda.format(melhorDia),
              Icons.star,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildCardEstatistica(
              'Dias Trabalhados',
              '${caixasFiltro.length}',
              Icons.calendar_today,
              Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardEstatistica(String titulo, String valor, IconData icone, Color cor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 16, color: cor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 10,
                    color: cor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Mês',
                prefixIcon: Icon(Icons.calendar_month),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: selectedMonth,
              items: meses.map((mes) => 
                DropdownMenuItem(value: mes, child: Text(mes))
              ).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMonth = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Ano',
                prefixIcon: Icon(Icons.date_range),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              value: selectedYear,
              items: anos.map((ano) => 
                DropdownMenuItem(value: ano, child: Text(ano))
              ).toList(),
              onChanged: (value) {
                setState(() {
                  selectedYear = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar...',
                hintText: 'Número do caixa, operador...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaCaixas() {
    final caixasFiltro = caixasFiltrados;
    
    if (caixasFiltro.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum caixa encontrado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente alterar os filtros ou período',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: caixasFiltro.length,
      itemBuilder: (context, index) {
        final caixa = caixasFiltro[index];
        return _buildCaixaCard(caixa);
      },
    );
  }

  Widget _buildCaixaCard(Map<String, dynamic> caixa) {
    final diferenca = caixa['diferenca'] as double;
    final corDiferenca = diferenca >= 0 ? Colors.green : Colors.red;
    final corBorda = diferenca >= 0 ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: corBorda, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.point_of_sale, color: Color(0xFFDC2626), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${formatoData.format(caixa['data'])} - ${caixa['numero']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Fechado',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Informações do operador
            Row(
              children: [
                Icon(Icons.person, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Operador: ${caixa['operador']}',
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Horários
            Row(
              children: [
                Icon(Icons.access_time, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Abertura: ${formatoHora.format(caixa['abertura'])} | '
                  'Fechamento: ${caixa['fechamento'] != null ? formatoHora.format(caixa['fechamento']) : 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Valores principais
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Vendas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatoMoeda.format(caixa['totalVendas']),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 40, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Diferença',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${diferenca >= 0 ? '+' : ''}${formatoMoeda.format(diferenca)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: corDiferenca,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDetalhes(caixa),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Ver Detalhes'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _imprimir(caixa),
                    icon: const Icon(Icons.print, size: 16),
                    label: const Text('Imprimir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _gerarPdf(caixa),
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetalhes(Map<String, dynamic> caixa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalhes - ${caixa['numero']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Operador: ${caixa['operador']}'),
            Text('Data: ${formatoData.format(caixa['data'])}'),
            Text('Total Vendas: ${formatoMoeda.format(caixa['totalVendas'])}'),
            Text('Diferença: ${formatoMoeda.format(caixa['diferenca'])}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _imprimir(Map<String, dynamic> caixa) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Imprimindo caixa ${caixa['numero']}...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _gerarPdf(Map<String, dynamic> caixa) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gerando PDF do caixa ${caixa['numero']}...'),
        backgroundColor: Colors.red,
      ),
    );
  }
}