import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoricoCaixasScreen extends StatefulWidget {
  const HistoricoCaixasScreen({super.key});

  @override
  State<HistoricoCaixasScreen> createState() => _HistoricoCaixasScreenState();
}

class _HistoricoCaixasScreenState extends State<HistoricoCaixasScreen> {
  final formatoMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final formatoData = DateFormat('dd/MM/yyyy');
  final formatoHora = DateFormat('HH:mm');

  // Dados mockados para demonstração
  final List<Map<String, dynamic>> caixasMockados = [
    {
      'id': '1',
      'numero': 'CX001',
      'data': DateTime.now().subtract(const Duration(days: 1)),
      'operador': 'João Silva',
      'abertura': DateTime.now().subtract(const Duration(days: 1, hours: 14)),
      'fechamento': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      'totalVendas': 2450.00,
      'diferenca': 2.50,
    },
    {
      'id': '2',
      'numero': 'CX002',
      'data': DateTime.now().subtract(const Duration(days: 2)),
      'operador': 'Maria Santos',
      'abertura': DateTime.now().subtract(const Duration(days: 2, hours: 15)),
      'fechamento': DateTime.now().subtract(const Duration(days: 2, hours: 1)),
      'totalVendas': 1890.00,
      'diferenca': -5.00,
    },
    {
      'id': '3',
      'numero': 'CX003',
      'data': DateTime.now().subtract(const Duration(days: 3)),
      'operador': 'Pedro Costa',
      'abertura': DateTime.now().subtract(const Duration(days: 3, hours: 13)),
      'fechamento': DateTime.now().subtract(const Duration(days: 3, hours: 3)),
      'totalVendas': 3200.00,
      'diferenca': 10.00,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.history, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Histórico de Caixas',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
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
    final totalMes = caixasMockados.fold<double>(
      0, (sum, item) => sum + item['totalVendas'],
    );
    final mediaDiaria = totalMes / caixasMockados.length;
    final melhorDia = caixasMockados.fold<double>(
      0, (max, item) => item['totalVendas'] > max ? item['totalVendas'] : max,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
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
              '${caixasMockados.length}',
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
      color: Colors.white,
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
              value: 'Janeiro',
              items: const [
                DropdownMenuItem(value: 'Janeiro', child: Text('Janeiro')),
                DropdownMenuItem(value: 'Fevereiro', child: Text('Fevereiro')),
                DropdownMenuItem(value: 'Março', child: Text('Março')),
              ],
              onChanged: (value) {},
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
              value: '2025',
              items: const [
                DropdownMenuItem(value: '2025', child: Text('2025')),
                DropdownMenuItem(value: '2024', child: Text('2024')),
              ],
              onChanged: (value) {},
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Buscar...',
                hintText: 'Número do caixa, operador...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaCaixas() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: caixasMockados.length,
      itemBuilder: (context, index) {
        final caixa = caixasMockados[index];
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Fechado',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
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
                Icon(Icons.person, color: Colors.grey[600], size: 16),
                const SizedBox(width: 8),
                Text(
                  'Operador: ${caixa['operador']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Horários
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                const SizedBox(width: 8),
                Text(
                  'Abertura: ${formatoHora.format(caixa['abertura'])} | '
                  'Fechamento: ${formatoHora.format(caixa['fechamento'])}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Valores principais
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
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
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatoMoeda.format(caixa['totalVendas']),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 40, color: Colors.grey[300]),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Diferença',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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