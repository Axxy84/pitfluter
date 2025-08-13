import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class ImpressaoService {
  static const double _larguraImpressora = 80 * PdfPageFormat.mm; // 80mm
  static final DateFormat _formatoData = DateFormat('dd/MM/yyyy HH:mm');
  static final NumberFormat _formatoMoeda = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$ ',
    decimalDigits: 2,
  );

  /// Imprime uma comanda/pedido formatada
  static Future<bool> imprimirComanda({
    required String numeroPedido,
    required DateTime dataPedido,
    required List<Map<String, dynamic>> itens,
    required double subtotal,
    required double taxaEntrega,
    required double total,
    String? formaPagamento,
    String? observacoesPedido,
    String? informacoesEntrega,
  }) async {
    try {
      final pdf = await _gerarPdfComanda(
        numeroPedido: numeroPedido,
        dataPedido: dataPedido,
        informacoesEntrega: informacoesEntrega,
        itens: itens,
        subtotal: subtotal,
        taxaEntrega: taxaEntrega,
        total: total,
        formaPagamento: formaPagamento,
        observacoesPedido: observacoesPedido,
      );

      // Imprimir diretamente
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf,
        name: 'Comanda_$numeroPedido',
        format: const PdfPageFormat(
          _larguraImpressora,
          double.infinity,
          marginAll: 5 * PdfPageFormat.mm,
        ),
      );

      return true;
    } catch (e) {
      // Log error (use logging framework in production)
      // ignore: avoid_print
      // Erro ao imprimir comanda
      return false;
    }
  }

  /// Compartilha a comanda como PDF
  static Future<bool> compartilharComanda({
    required String numeroPedido,
    required DateTime dataPedido,
    required List<Map<String, dynamic>> itens,
    required double subtotal,
    required double taxaEntrega,
    required double total,
    String? formaPagamento,
    String? observacoesPedido,
    String? informacoesEntrega,
  }) async {
    try {
      final pdf = await _gerarPdfComanda(
        numeroPedido: numeroPedido,
        dataPedido: dataPedido,
        informacoesEntrega: informacoesEntrega,
        itens: itens,
        subtotal: subtotal,
        taxaEntrega: taxaEntrega,
        total: total,
        formaPagamento: formaPagamento,
        observacoesPedido: observacoesPedido,
      );

      await Printing.sharePdf(
        bytes: pdf,
        filename: 'Comanda_$numeroPedido.pdf',
      );

      return true;
    } catch (e) {
      // Log error (use logging framework in production)
      // ignore: avoid_print
      // Erro ao compartilhar comanda
      return false;
    }
  }

  /// Gera PDF da comanda no formato especificado
  static Future<Uint8List> _gerarPdfComanda({
    required String numeroPedido,
    required DateTime dataPedido,
    required List<Map<String, dynamic>> itens,
    required double subtotal,
    required double taxaEntrega,
    required double total,
    String? formaPagamento,
    String? observacoesPedido,
    String? informacoesEntrega,
  }) async {
    final pdf = pw.Document();

    // Fonte monoespaçada para alinhamento
    final fonte = await PdfGoogleFonts.robotoMonoRegular();
    final fonteBold = await PdfGoogleFonts.robotoMonoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          _larguraImpressora,
          double.infinity,
          marginAll: 2 * PdfPageFormat.mm,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              pw.Center(
                child: pw.Text(
                  '========================================',
                  style: pw.TextStyle(font: fonte, fontSize: 8),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'PIZZARIA SISTEMA',
                  style: pw.TextStyle(font: fonteBold, fontSize: 12),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  '========================================',
                  style: pw.TextStyle(font: fonte, fontSize: 8),
                ),
              ),
              pw.SizedBox(height: 5),

              // Informações do pedido
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Pedido: #$numeroPedido',
                    style: pw.TextStyle(font: fonte, fontSize: 9),
                  ),
                  pw.Text(
                    'Data: ${_formatoData.format(dataPedido)}',
                    style: pw.TextStyle(font: fonte, fontSize: 9),
                  ),
                ],
              ),

              // Informações do cliente
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (informacoesEntrega != null && informacoesEntrega.isNotEmpty)
                    pw.Flexible(
                      child: pw.Text(
                        'Entrega: $informacoesEntrega',
                        style: pw.TextStyle(font: fonte, fontSize: 9),
                        overflow: pw.TextOverflow.clip,
                      ),
                    ),
                ],
              ),

              // Divisória
              pw.Text(
                '----------------------------------------',
                style: pw.TextStyle(font: fonte, fontSize: 8),
              ),

              // Itens do pedido
              ...itens.map((item) => _construirItemPdf(item, fonte)),

              // Divisória
              pw.Text(
                '----------------------------------------',
                style: pw.TextStyle(font: fonte, fontSize: 8),
              ),

              // Totais
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Subtotal:',
                    style: pw.TextStyle(font: fonte, fontSize: 9),
                  ),
                  pw.Text(
                    _formatoMoeda.format(subtotal),
                    style: pw.TextStyle(font: fonte, fontSize: 9),
                  ),
                ],
              ),

              if (taxaEntrega > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Taxa Entrega:',
                      style: pw.TextStyle(font: fonte, fontSize: 9),
                    ),
                    pw.Text(
                      _formatoMoeda.format(taxaEntrega),
                      style: pw.TextStyle(font: fonte, fontSize: 9),
                    ),
                  ],
                ),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL:',
                    style: pw.TextStyle(font: fonteBold, fontSize: 10),
                  ),
                  pw.Text(
                    _formatoMoeda.format(total),
                    style: pw.TextStyle(font: fonteBold, fontSize: 10),
                  ),
                ],
              ),

              // Rodapé
              pw.Center(
                child: pw.Text(
                  '========================================',
                  style: pw.TextStyle(font: fonte, fontSize: 8),
                ),
              ),

              if (formaPagamento != null && formaPagamento.isNotEmpty)
                pw.Center(
                  child: pw.Text(
                    'Pagamento: $formaPagamento',
                    style: pw.TextStyle(font: fonte, fontSize: 9),
                  ),
                ),


              pw.Center(
                child: pw.Text(
                  '========================================',
                  style: pw.TextStyle(font: fonte, fontSize: 8),
                ),
              ),

              if (observacoesPedido != null && observacoesPedido.isNotEmpty) ...[
                pw.SizedBox(height: 5),
                pw.Text(
                  'Observações: $observacoesPedido',
                  style: pw.TextStyle(font: fonte, fontSize: 8),
                ),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Gera PDF específico para comanda da cozinha (sem valores)
  static Future<Uint8List> _gerarPdfComandaCozinha({
    required String numeroPedido,
    required DateTime dataPedido,
    required List<Map<String, dynamic>> itens,
    String? tipoPedido,
    String? mesa,
    String? cliente,
    String? endereco,
    String? observacoesPedido,
  }) async {
    final pdf = pw.Document();

    // Fonte monoespaçada para alinhamento
    final fonte = await PdfGoogleFonts.robotoMonoRegular();
    final fonteBold = await PdfGoogleFonts.robotoMonoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          _larguraImpressora,
          double.infinity,
          marginAll: 2 * PdfPageFormat.mm,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho da cozinha
              pw.Center(
                child: pw.Text(
                  '=======================================',
                  style: pw.TextStyle(font: fonte, fontSize: 8),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'COMANDA DA COZINHA',
                  style: pw.TextStyle(font: fonteBold, fontSize: 14),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  '=======================================',
                  style: pw.TextStyle(font: fonte, fontSize: 8),
                ),
              ),
              pw.SizedBox(height: 8),

              // Informações do pedido
              pw.Text(
                'Pedido Nº: $numeroPedido',
                style: pw.TextStyle(font: fonteBold, fontSize: 12),
              ),
              
              // Tipo do pedido e informações específicas
              if (tipoPedido != null) ...[
                pw.SizedBox(height: 4),
                if (tipoPedido.toLowerCase() == 'delivery') ...[
                  pw.Text(
                    'Tipo: DELIVERY',
                    style: pw.TextStyle(font: fonteBold, fontSize: 10),
                  ),
                  if (cliente != null && cliente.isNotEmpty)
                    pw.Text(
                      'Cliente: ${cliente.toUpperCase()}',
                      style: pw.TextStyle(font: fonte, fontSize: 10),
                    ),
                  if (endereco != null && endereco.isNotEmpty)
                    pw.Text(
                      'Endereço: ${endereco.toUpperCase()}',
                      style: pw.TextStyle(font: fonte, fontSize: 9),
                    ),
                ] else if (tipoPedido.toLowerCase() == 'mesa') ...[
                  if (mesa != null)
                    pw.Text(
                      'Mesa: $mesa',
                      style: pw.TextStyle(font: fonteBold, fontSize: 10),
                    ),
                  pw.Text(
                    'Tipo: Salão',
                    style: pw.TextStyle(font: fonte, fontSize: 10),
                  ),
                ] else if (tipoPedido.toLowerCase() == 'balcao') ...[
                  pw.Text(
                    'Tipo: Balcão',
                    style: pw.TextStyle(font: fonte, fontSize: 10),
                  ),
                  if (cliente != null && cliente.isNotEmpty)
                    pw.Text(
                      'Cliente: ${cliente.toUpperCase()}',
                      style: pw.TextStyle(font: fonte, fontSize: 10),
                    ),
                ],
              ],
              
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Data: ${DateFormat('dd/MM/yyyy').format(dataPedido)}',
                    style: pw.TextStyle(font: fonte, fontSize: 9),
                  ),
                  pw.Text(
                    'Hora: ${DateFormat('HH:mm').format(dataPedido)}',
                    style: pw.TextStyle(font: fonte, fontSize: 9),
                  ),
                ],
              ),

              pw.SizedBox(height: 8),

              // Divisória
              pw.Center(
                child: pw.Text(
                  '-------------------------------------',
                  style: pw.TextStyle(font: fonte, fontSize: 8),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  '|         DETALHES DO PEDIDO        |',
                  style: pw.TextStyle(font: fonteBold, fontSize: 10),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  '-------------------------------------',
                  style: pw.TextStyle(font: fonte, fontSize: 8),
                ),
              ),
              pw.SizedBox(height: 5),

              // Itens do pedido para cozinha
              ...itens.map((item) => _construirItemPdfCozinha(item, fonte, fonteBold)),

              pw.SizedBox(height: 8),

              // Divisória
              pw.Text(
                '---------------------------------------',
                style: pw.TextStyle(font: fonte, fontSize: 8),
              ),

              // Observações
              if (observacoesPedido != null && observacoesPedido.isNotEmpty) ...[
                pw.SizedBox(height: 5),
                pw.Text(
                  '- Nota Geral: $observacoesPedido',
                  style: pw.TextStyle(font: fonte, fontSize: 9),
                ),
                pw.SizedBox(height: 8),
              ],

              // Seção de conferência
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'APONTAR CONFERÊNCIA: (   )',
                  style: pw.TextStyle(font: fonteBold, fontSize: 11),
                ),
              ),
              
              pw.SizedBox(height: 15),
              
              pw.Text(
                '-------------------------------------',
                style: pw.TextStyle(font: fonte, fontSize: 8),
              ),
              pw.Text(
                'Responsável: ___________________________',
                style: pw.TextStyle(font: fonte, fontSize: 10),
              ),
              pw.Text(
                '-------------------------------------',
                style: pw.TextStyle(font: fonte, fontSize: 8),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Constrói um item individual no PDF para cozinha (sem preços)
  static pw.Widget _construirItemPdfCozinha(
    Map<String, dynamic> item,
    pw.Font fonte,
    pw.Font fonteBold,
  ) {
    final quantidade = item['quantidade'] ?? 1;
    final nome = item['nome'] ?? item['descricao'] ?? 'Item';
    final observacao = item['observacao'] as String?;
    final tamanho = item['tamanho'] as String?;

    // Determinar abreviação do tamanho
    String tamanhoAbrev = '';
    if (tamanho != null) {
      switch (tamanho.toLowerCase()) {
        case 'pequena':
        case 'pequeno':
        case 'p':
          tamanhoAbrev = 'P';
          break;
        case 'média':
        case 'medio':
        case 'm':
          tamanhoAbrev = 'M';
          break;
        case 'grande':
        case 'g':
          tamanhoAbrev = 'G';
          break;
        case 'família':
        case 'familia':
        case 'f':
          tamanhoAbrev = 'F';
          break;
        default:
          tamanhoAbrev = '';
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            if (tamanhoAbrev.isNotEmpty)
              pw.Container(
                width: 15,
                child: pw.Text(
                  tamanhoAbrev,
                  style: pw.TextStyle(font: fonteBold, fontSize: 10),
                ),
              ),
            pw.Text(
              '[${quantidade}x]',
              style: pw.TextStyle(font: fonteBold, fontSize: 10),
            ),
            pw.SizedBox(width: 5),
            pw.Expanded(
              child: pw.Text(
                nome,
                style: pw.TextStyle(font: fonte, fontSize: 10),
              ),
            ),
          ],
        ),
        if (observacao != null && observacao.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 20, top: 2),
            child: pw.Text(
              '- Observação: ${observacao.toUpperCase()}',
              style: pw.TextStyle(font: fonte, fontSize: 9),
            ),
          ),
        pw.SizedBox(height: 4),
      ],
    );
  }

  /// Constrói um item individual no PDF
  static pw.Widget _construirItemPdf(
    Map<String, dynamic> item,
    pw.Font fonte,
  ) {
    final quantidade = item['quantidade'] ?? 1;
    final nome = item['nome'] ?? item['descricao'] ?? 'Item';
    final preco = (item['total'] ?? item['preco'] ?? 0.0) as double;
    final observacao = item['observacao'] as String?;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Flexible(
              flex: 3,
              child: pw.Text(
                '${quantidade}x $nome',
                style: pw.TextStyle(font: fonte, fontSize: 9),
                overflow: pw.TextOverflow.clip,
              ),
            ),
            pw.Text(
              _formatoMoeda.format(preco),
              style: pw.TextStyle(font: fonte, fontSize: 9),
            ),
          ],
        ),
        if (observacao != null && observacao.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 10),
            child: pw.Text(
              'Obs: $observacao',
              style: pw.TextStyle(font: fonte, fontSize: 8),
            ),
          ),
      ],
    );
  }

  /// Imprime comanda específica para cozinha (sem valores)
  static Future<bool> imprimirComandaCozinha({
    required String numeroPedido,
    required DateTime dataPedido,
    required List<Map<String, dynamic>> itens,
    String? tipoPedido, // delivery, mesa, balcao
    String? mesa,
    String? cliente,
    String? endereco,
    String? observacoesPedido,
  }) async {
    try {
      final pdf = await _gerarPdfComandaCozinha(
        numeroPedido: numeroPedido,
        dataPedido: dataPedido,
        itens: itens,
        tipoPedido: tipoPedido,
        mesa: mesa,
        cliente: cliente,
        endereco: endereco,
        observacoesPedido: observacoesPedido,
      );

      // Imprimir diretamente
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf,
        name: 'Comanda_Cozinha_$numeroPedido',
        format: const PdfPageFormat(
          _larguraImpressora,
          double.infinity,
          marginAll: 5 * PdfPageFormat.mm,
        ),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> imprimirContaMesa(Map<String, dynamic> detalhesMesa) async {
    try {
      final mesa = detalhesMesa['mesa'];
      final pedidos = detalhesMesa['pedidos'] as List;
      final total = detalhesMesa['total'] as double;
      
      final List<Map<String, dynamic>> todosItens = [];
      
      for (final pedido in pedidos) {
        if (pedido['itens_pedido'] != null) {
          for (final item in pedido['itens_pedido']) {
            todosItens.add({
              'quantidade': item['quantidade'],
              'nome': item['produtos']?['nome'] ?? 'Produto',
              'total': item['preco_unitario'] * item['quantidade'],
            });
          }
        }
      }

      await imprimirComanda(
        numeroPedido: 'Mesa ${mesa['numero']}',
        dataPedido: DateTime.now(),
        itens: todosItens,
        subtotal: total,
        taxaEntrega: 0,
        total: total,
        observacoesPedido: 'Conta da Mesa',
        informacoesEntrega: 'Mesa ${mesa['numero']}',
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }
}