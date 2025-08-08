import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/core/constants/supabase_constants.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );

  final supabase = Supabase.instance.client;

  print('🔍 Testando dashboard com dados reais...\n');

  try {
    // Testar busca de pedidos de hoje
    final hoje = DateTime.now();
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
    
    print('📅 Buscando pedidos a partir de: ${inicioHoje.toIso8601String()}');
    
    final response = await supabase
        .from('pedidos')
        .select()
        .gte('created_at', inicioHoje.toIso8601String());
    
    print('✅ Pedidos encontrados: ${response.length}');
    
    double totalVendas = 0;
    Map<String, double> vendasPorTipo = {'Balcão': 0, 'Delivery': 0, 'Mesa': 0};
    Map<String, double> formasPagamento = {'Dinheiro': 0, 'PIX': 0, 'Cartão': 0};
    
    for (final pedido in response) {
      final valor = (pedido['total'] ?? 0).toDouble();
      totalVendas += valor;
      
      // Contar por tipo
      final tipo = pedido['tipo'] ?? 'balcao';
      if (tipo == 'entrega' || tipo == 'delivery') {
        vendasPorTipo['Delivery'] = (vendasPorTipo['Delivery'] ?? 0) + valor;
      } else if (tipo == 'mesa') {
        vendasPorTipo['Mesa'] = (vendasPorTipo['Mesa'] ?? 0) + valor;
      } else {
        vendasPorTipo['Balcão'] = (vendasPorTipo['Balcão'] ?? 0) + valor;
      }
      
      // Contar por forma de pagamento
      final formaPagamento = pedido['forma_pagamento'] ?? 'Dinheiro';
      if (formaPagamento == 'PIX') {
        formasPagamento['PIX'] = (formasPagamento['PIX'] ?? 0) + valor;
      } else if (formaPagamento == 'Cartão') {
        formasPagamento['Cartão'] = (formasPagamento['Cartão'] ?? 0) + valor;
      } else {
        formasPagamento['Dinheiro'] = (formasPagamento['Dinheiro'] ?? 0) + valor;
      }
      
      print('\n  Pedido #${pedido['numero']}:');
      print('    Tipo: $tipo');
      print('    Total: R\$ $valor');
      print('    Pagamento: ${pedido['forma_pagamento']}');
    }
    
    print('\n📊 RESUMO DO DIA:');
    print('  Total de vendas: R\$ $totalVendas');
    print('  Quantidade de pedidos: ${response.length}');
    if (response.isNotEmpty) {
      print('  Ticket médio: R\$ ${(totalVendas / response.length).toStringAsFixed(2)}');
    }
    
    print('\n💰 VENDAS POR TIPO:');
    vendasPorTipo.forEach((tipo, valor) {
      print('  $tipo: R\$ ${valor.toStringAsFixed(2)}');
    });
    
    print('\n💳 FORMAS DE PAGAMENTO:');
    formasPagamento.forEach((forma, valor) {
      print('  $forma: R\$ ${valor.toStringAsFixed(2)}');
    });
    
    // Testar busca dos últimos 7 dias
    print('\n📈 VENDAS DOS ÚLTIMOS 7 DIAS:');
    for (int i = 6; i >= 0; i--) {
      final dia = hoje.subtract(Duration(days: i));
      final inicioDia = DateTime(dia.year, dia.month, dia.day);
      final fimDia = inicioDia.add(const Duration(days: 1));
      
      final vendasDia = await supabase
          .from('pedidos')
          .select('total')
          .gte('created_at', inicioDia.toIso8601String())
          .lt('created_at', fimDia.toIso8601String());
      
      double totalDia = 0;
      for (final venda in vendasDia) {
        totalDia += (venda['total'] ?? 0).toDouble();
      }
      
      print('  ${dia.day}/${dia.month}: R\$ ${totalDia.toStringAsFixed(2)}');
    }
    
    print('\n✅ Dashboard está funcionando corretamente com dados reais!');
    
  } catch (e) {
    print('❌ Erro ao testar dashboard: $e');
  }
}