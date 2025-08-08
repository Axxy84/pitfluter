import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../domain/entities/caixa.dart';
import '../domain/entities/movimento_caixa.dart';

class RelatorioCaixaService {
  static Future<void> imprimirRelatorio(
    Caixa caixa,
    List<MovimentoCaixa> movimentacoes,
  ) async {
    final pdf = await _gerarPDF(caixa, movimentacoes);
    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf,
      name: 'Relatório de Caixa - ${caixa.generateReportNumber()}',
    );
  }

  static Future<Uint8List> _gerarPDF(
    Caixa caixa,
    List<MovimentoCaixa> movimentacoes,
  ) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: _buildHeader,
        footer: _buildFooter,
        build: (pw.Context context) {
          return [
            _buildTitulo(caixa),
            pw.SizedBox(height: 20),
            _buildInformacoesCaixa(caixa, dateFormat),
            pw.SizedBox(height: 20),
            _buildResumoFinanceiro(caixa),
            pw.SizedBox(height: 20),
            _buildFormasPagamento(caixa),
            pw.SizedBox(height: 20),
            _buildMovimentacoes(movimentacoes, dateFormat),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
      padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey),
        ),
      ),
      child: pw.Text(
        'Pizzaria Sistema',
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
      child: pw.Text(
        'Página ${context.pageNumber}/${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
      ),
    );
  }

  static pw.Widget _buildTitulo(Caixa caixa) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'RELATÓRIO DE CAIXA',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Número: ${caixa.generateReportNumber()}',
          style: pw.TextStyle(
            fontSize: 14,
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          'Gerado em: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInformacoesCaixa(Caixa caixa, DateFormat dateFormat) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMAÇÕES DO CAIXA',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem('Status:', caixa.estaAberto ? 'ABERTO' : 'FECHADO'),
                    _buildInfoItem('Responsável:', 'João Silva'), // TODO: pegar do auth
                    _buildInfoItem('Data de Abertura:', dateFormat.format(caixa.dataAbertura)),
                    if (caixa.dataFechamento != null)
                      _buildInfoItem('Data de Fechamento:', dateFormat.format(caixa.dataFechamento!)),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (caixa.observacoes != null)
                      _buildInfoItem('Observações:', caixa.observacoes!),
                    if (caixa.dataFechamento != null) ...[
                      _buildInfoItem('Valor Contado:', 'R\$ ${caixa.saldoFinal.toStringAsFixed(2)}'),
                      _buildInfoItem('Diferença:', 
                        'R\$ ${caixa.diferencaCaixa.toStringAsFixed(2)}',
                        color: caixa.diferencaCaixa >= 0 ? PdfColors.green800 : PdfColors.red800,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoItem(String label, String value, {PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
            pw.TextSpan(
              text: value,
              style: pw.TextStyle(fontSize: 12, color: color ?? PdfColors.black),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildResumoFinanceiro(Caixa caixa) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RESUMO FINANCEIRO',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              _buildTableRow('Valor de Abertura', caixa.saldoInicial, isHeader: true),
              _buildTableRow('Total de Vendas', caixa.totalVendas),
              _buildTableRow('Total de Sangrias', -caixa.totalSangrias, isNegative: true),
              _buildTableRow('Valor Esperado', caixa.saldoAtual, isBold: true),
              if (caixa.dataFechamento != null) ...[
                _buildTableRow('Valor Contado', caixa.saldoFinal),
                _buildTableRow(
                  'Diferença', 
                  caixa.diferencaCaixa, 
                  isBold: true,
                  isNegative: caixa.diferencaCaixa < 0,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static pw.TableRow _buildTableRow(
    String label, 
    double value, {
    bool isHeader = false,
    bool isBold = false,
    bool isNegative = false,
  }) {
    final textStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: isHeader || isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: isNegative ? PdfColors.red800 : (isHeader ? PdfColors.blue800 : PdfColors.black),
    );

    return pw.TableRow(
      decoration: isHeader ? const pw.BoxDecoration(color: PdfColors.grey200) : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label, style: textStyle),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}',
              style: textStyle,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFormasPagamento(Caixa caixa) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'FORMAS DE PAGAMENTO',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple800,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              _buildPaymentRow('Dinheiro', caixa.totalDinheiro, caixa.totalVendas),
              _buildPaymentRow('Cartão', caixa.totalCartao, caixa.totalVendas),
              _buildPaymentRow('PIX', caixa.totalPix, caixa.totalVendas),
              _buildPaymentRow('TOTAL', caixa.totalVendas, caixa.totalVendas, isBold: true),
            ],
          ),
        ],
      ),
    );
  }

  static pw.TableRow _buildPaymentRow(String method, double value, double total, {bool isBold = false}) {
    final percentage = total > 0 ? (value / total * 100) : 0.0;
    final textStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );

    return pw.TableRow(
      decoration: isBold ? const pw.BoxDecoration(color: PdfColors.grey200) : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(method, style: textStyle),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}',
              style: textStyle,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              '${percentage.toStringAsFixed(1)}%',
              style: textStyle,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildMovimentacoes(List<MovimentoCaixa> movimentacoes, DateFormat dateFormat) {
    if (movimentacoes.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(16),
        child: pw.Text(
          'Nenhuma movimentação registrada.',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'MOVIMENTAÇÕES',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.orange800,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400),
          columnWidths: {
            0: const pw.FixedColumnWidth(80),
            1: const pw.FixedColumnWidth(80),
            2: const pw.FlexColumnWidth(),
            3: const pw.FixedColumnWidth(80),
            4: const pw.FixedColumnWidth(80),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableHeader('Data'),
                _buildTableHeader('Hora'),
                _buildTableHeader('Descrição'),
                _buildTableHeader('Tipo'),
                _buildTableHeader('Valor'),
              ],
            ),
            // Movimentações
            ...movimentacoes.map((mov) => _buildMovimentacaoRow(mov, dateFormat)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.TableRow _buildMovimentacaoRow(MovimentoCaixa mov, DateFormat dateFormat) {
    final isEntrada = mov.isEntrada;
    final color = isEntrada ? PdfColors.green800 : PdfColors.red800;
    
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            DateFormat('dd/MM/yy').format(mov.dataHora),
            style: pw.TextStyle(fontSize: 9),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            DateFormat('HH:mm').format(mov.dataHora),
            style: pw.TextStyle(fontSize: 9),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            mov.descricao,
            style: pw.TextStyle(fontSize: 9),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            _getTipoMovimentoDescricao(mov.tipo),
            style: pw.TextStyle(fontSize: 9),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              '${isEntrada ? '+' : '-'} R\$ ${mov.valor.toStringAsFixed(2)}',
              style: pw.TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static String _getTipoMovimentoDescricao(TipoMovimento tipo) {
    switch (tipo) {
      case TipoMovimento.venda:
        return 'Venda';
      case TipoMovimento.sangria:
        return 'Sangria';
      case TipoMovimento.suprimento:
        return 'Suprimento';
      case TipoMovimento.abertura:
        return 'Abertura';
      case TipoMovimento.fechamento:
        return 'Fechamento';
    }
  }
}