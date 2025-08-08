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
    required String nomeCliente,
    String? telefoneCliente,
    String? enderecoCliente,
    required List<Map<String, dynamic>> itens,
    required double subtotal,
    required double taxaEntrega,
    required double total,
    String? formaPagamento,
    String? observacoesPedido,
  }) async {
    try {
      final pdf = await _gerarPdfComanda(
        numeroPedido: numeroPedido,
        dataPedido: dataPedido,
        nomeCliente: nomeCliente,
        telefoneCliente: telefoneCliente,
        enderecoCliente: enderecoCliente,
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
    required String nomeCliente,
    String? telefoneCliente,
    String? enderecoCliente,
    required List<Map<String, dynamic>> itens,
    required double subtotal,
    required double taxaEntrega,
    required double total,
    String? formaPagamento,
    String? observacoesPedido,
  }) async {
    try {
      final pdf = await _gerarPdfComanda(
        numeroPedido: numeroPedido,
        dataPedido: dataPedido,
        nomeCliente: nomeCliente,
        telefoneCliente: telefoneCliente,
        enderecoCliente: enderecoCliente,
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
    required String nomeCliente,
    String? telefoneCliente,
    String? enderecoCliente,
    required List<Map<String, dynamic>> itens,
    required double subtotal,
    required double taxaEntrega,
    required double total,
    String? formaPagamento,
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
                  pw.Flexible(
                    child: pw.Text(
                      'Cliente: $nomeCliente',
                      style: pw.TextStyle(font: fonte, fontSize: 9),
                      overflow: pw.TextOverflow.clip,
                    ),
                  ),
                  if (telefoneCliente != null && telefoneCliente.isNotEmpty)
                    pw.Text(
                      'Tel: $telefoneCliente',
                      style: pw.TextStyle(font: fonte, fontSize: 9),
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

              if (enderecoCliente != null && enderecoCliente.isNotEmpty)
                pw.Center(
                  child: pw.Text(
                    'End: $enderecoCliente',
                    style: pw.TextStyle(font: fonte, fontSize: 8),
                    textAlign: pw.TextAlign.center,
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
}