import 'package:supabase_flutter/supabase_flutter.dart';

class MesaService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getMesasAbertas() async {
    try {
      final response = await _supabase
          .from('pedidos')
          .select('mesa_id, created_at, total, numero')
          .not('mesa_id', 'is', null)
          .isFilter('data_hora_entrega', null)  // Pedidos não finalizados
          .order('created_at');

      final mesasMap = <int, Map<String, dynamic>>{};
      
      for (final pedido in response) {
        final mesaId = pedido['mesa_id'] as int;
        if (mesasMap.containsKey(mesaId)) {
          mesasMap[mesaId]!['total'] = (mesasMap[mesaId]!['total'] ?? 0.0) + (pedido['total'] ?? 0.0);
          mesasMap[mesaId]!['pedidos'].add(pedido);
        } else {
          final mesaResponse = await _supabase
              .from('mesas')
              .select()
              .eq('id', mesaId)
              .single();

          mesasMap[mesaId] = {
            'mesa': mesaResponse,
            'total': pedido['total'] ?? 0.0,
            'abertura': pedido['created_at'],
            'pedidos': [pedido],
          };
        }
      }

      return mesasMap.values.toList();
    } catch (e) {
      // DEBUG: Erro ao buscar mesas abertas: $e
      return [];
    }
  }

  Future<Map<String, dynamic>?> getDetalhesMesa(int mesaId) async {
    try {
      // Buscar apenas pedidos por enquanto, sem joins
      final pedidosResponse = await _supabase
          .from('pedidos')
          .select()
          .eq('mesa_id', mesaId)
          .isFilter('data_hora_entrega', null);  // Pedidos não finalizados

      if (pedidosResponse.isEmpty) {
        return null;
      }

      final mesaResponse = await _supabase
          .from('mesas')
          .select()
          .eq('id', mesaId)
          .single();

      double total = 0.0;
      for (final pedido in pedidosResponse) {
        total += pedido['total'] ?? 0.0;
      }

      return {
        'mesa': mesaResponse,
        'pedidos': pedidosResponse,
        'total': total,
      };
    } catch (e) {
      // DEBUG: Erro ao buscar detalhes da mesa: $e
      return null;
    }
  }

  Future<bool> fecharContaMesa(int mesaId, String formaPagamento) async {
    try {
      await _supabase
          .from('pedidos')
          .update({
            'forma_pagamento': formaPagamento,
            'data_hora_entrega': DateTime.now().toIso8601String(),
          })
          .eq('mesa_id', mesaId)
          .isFilter('data_hora_entrega', null);  // Apenas pedidos não finalizados

      await _supabase
          .from('mesas')
          .update({'ocupada': false})
          .eq('id', mesaId);

      return true;
    } catch (e) {
      // DEBUG: Erro ao fechar conta da mesa: $e
      return false;
    }
  }

  Future<bool> abrirMesa(int mesaId) async {
    try {
      await _supabase
          .from('mesas')
          .update({'ocupada': true})
          .eq('id', mesaId);

      return true;
    } catch (e) {
      // DEBUG: Erro ao abrir mesa: $e
      return false;
    }
  }

  Future<bool> adicionarConsumo(int mesaId, Map<String, dynamic> itemData) async {
    try {
      // Criar novo pedido para o consumo adicional
      final pedidoData = {
        'numero': 'MESA-$mesaId-${DateTime.now().millisecondsSinceEpoch}',
        'mesa_id': mesaId,
        'tipo': 'mesa',
        'total': itemData['total'],
        'subtotal': itemData['total'],
        'taxa_entrega': 0,
        'desconto': 0,
        'forma_pagamento': 'Pendente',
        'observacoes': itemData['observacoes'] ?? 'Consumo adicional',
        'tempo_estimado_minutos': 10,
      };

      final pedidoResponse = await _supabase
          .from('pedidos')
          .insert(pedidoData)
          .select()
          .single();

      // Adicionar item ao pedido
      await _supabase.from('itens_pedido').insert({
        'pedido_id': pedidoResponse['id'],
        'produto_id': itemData['produto_id'],
        'quantidade': itemData['quantidade'],
        'preco_unitario': itemData['preco_unitario'],
        'subtotal': itemData['total'],
        'observacoes': itemData['observacoes'] ?? '',
      });

      return true;
    } catch (e) {
      // DEBUG: Erro ao adicionar consumo: $e
      return false;
    }
  }
}