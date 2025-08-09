import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://akfmfdmsanobdaznfdjw.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFrZm1mZG1zYW5vYmRhem5mZGp3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI2NTQxMzgsImV4cCI6MjA0ODIzMDEzOH0.EfF8CeAehGgJy7sZg5LXnQgWKdPTwnQOiN5pjrPFzuo',
  );

  // === ADICIONANDO PIZZAS DOCES ===

  try {
    // 1. Criar categoria "Pizzas Doces" se não existir
    // 1. Criando categoria Pizzas Doces...
    
    final categoriasExistentes = await supabase
        .from('produtos_categoria')
        .select('id, nome')
        .eq('nome', 'Pizzas Doces');
    
    int? categoriaDocesId;
    
    if (categoriasExistentes.isEmpty) {
      final novaCategoria = await supabase
          .from('produtos_categoria')
          .insert({
            'nome': 'Pizzas Doces',
            'descricao': 'Pizzas doces especiais',
            'ordem': 5,
            'ativo': true,
          })
          .select()
          .single();
      
      categoriaDocesId = novaCategoria['id'];
      // ✅ Categoria Pizzas Doces criada com ID: $categoriaDocesId
    } else {
      categoriaDocesId = categoriasExistentes.first['id'];
      // ✅ Categoria Pizzas Doces já existe com ID: $categoriaDocesId
    }

    // 2. Buscar IDs dos tamanhos
    final tamanhos = await supabase
        .from('produtos_tamanho')
        .select('id, nome');
    
    Map<String, int> tamanhoIds = {};
    for (final t in tamanhos) {
      // Normalizar nomes dos tamanhos
      String nomeNormalizado = t['nome'];
      if (nomeNormalizado == 'P' || nomeNormalizado == 'Pequena') {
        tamanhoIds['Pequena'] = t['id'];
      } else if (nomeNormalizado == 'M' || nomeNormalizado == 'Média') {
        tamanhoIds['Média'] = t['id'];
      } else if (nomeNormalizado == 'G' || nomeNormalizado == 'Grande') {
        tamanhoIds['Grande'] = t['id'];
      } else if (nomeNormalizado == 'GG' || nomeNormalizado == 'Família' || nomeNormalizado == 'Familia') {
        tamanhoIds['Família'] = t['id'];
      }
    }
    // ✅ Tamanhos encontrados: ${tamanhoIds.keys.join(', ')}

    // 3. Adicionar Pizzas Doces
    // 2. Adicionando Pizzas Doces...
    
    final pizzasDoces = [
      {
        'nome': 'Abacaxi Gratinado',
        'descricao': 'Leite condensado, mussarela, abacaxi em cubos gratinado e canela em pó',
        'precos': {'Pequena': 31.00, 'Média': 35.00, 'Grande': 39.00, 'Família': 45.00}
      },
      {
        'nome': 'Abacaxi ao Chocolate',
        'descricao': 'Leite condensado, abacaxi e chocolate branco',
        'precos': {'Pequena': 34.00, 'Média': 38.00, 'Grande': 42.00, 'Família': 48.00}
      },
      {
        'nome': 'Banana Caramelizada',
        'descricao': 'Leite condensado, mussarela, banana caramelizada e canela em pó',
        'precos': {'Pequena': 28.00, 'Média': 34.00, 'Grande': 37.00, 'Família': 41.00}
      },
      {
        'nome': 'Charge Branco',
        'descricao': 'Leite condensado, chocolate branco e amendoim triturado',
        'precos': {'Pequena': 34.00, 'Média': 36.00, 'Grande': 40.00, 'Família': 45.00}
      },
      {
        'nome': 'Nevada',
        'descricao': 'Leite condensado, banana, chocolate branco e canela',
        'precos': {'Pequena': 30.00, 'Média': 33.00, 'Grande': 38.00, 'Família': 43.00}
      },
      {
        'nome': 'Nutella com Morangos',
        'descricao': 'Creme de leite, Nutella e morangos',
        'precos': {'Pequena': 30.00, 'Média': 33.00, 'Grande': 38.00, 'Família': 43.00}
      },
      {
        'nome': 'Romeu e Julieta',
        'descricao': 'Leite condensado, mussarela e goiabada',
        'precos': {'Pequena': 29.00, 'Média': 35.00, 'Grande': 43.00, 'Família': 45.00}
      },
      {
        'nome': 'Romeu e Julieta com Gorgonzola',
        'descricao': 'Leite condensado, mussarela, goiabada e gorgonzola',
        'precos': {'Pequena': 34.00, 'Média': 37.00, 'Grande': 40.00, 'Família': 48.00}
      },
    ];

    for (final pizza in pizzasDoces) {
      // Verificar se já existe
      final existe = await supabase
          .from('produtos_produto')
          .select('id')
          .eq('nome', pizza['nome'] as String)
          .eq('categoria_id', categoriaDocesId!)
          .maybeSingle();
      
      if (existe == null) {
        // Criar produto
        final produto = await supabase
            .from('produtos_produto')
            .insert({
              'nome': pizza['nome'],
              'descricao': pizza['descricao'],
              'categoria_id': categoriaDocesId,
              'tipo_produto': 'pizza',
              'ativo': true,
              'ordem': 0,
            })
            .select()
            .single();
        
        // Adicionar preços para cada tamanho
        final precos = pizza['precos'] as Map<String, double>;
        for (final tamanho in precos.keys) {
          if (tamanhoIds.containsKey(tamanho)) {
            await supabase.from('produtos_produtopreco').insert({
              'produto_id': produto['id'],
              'tamanho_id': tamanhoIds[tamanho],
              'preco': precos[tamanho],
              'ativo': true,
            });
          }
        }
        
        // ✅ Pizza "${pizza['nome']}" adicionada com sucesso
      } else {
        // ⏭️  Pizza "${pizza['nome']}" já existe
      }
    }

    // ✅ PROCESSO CONCLUÍDO COM SUCESSO!
    // 🍫 Total de pizzas doces: ${pizzasDoces.length}
    
  } catch (e) {
    // ❌ Erro: $e
  }
}