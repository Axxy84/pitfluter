#!/usr/bin/env python3
"""
Script para inserir pizzas com preços corretos automaticamente
"""

from supabase import create_client, Client
import uuid

# Configurações do Supabase (SUBSTITUA pelas suas configurações)
SUPABASE_URL = "https://your-project.supabase.co"  # MUDE AQUI
SUPABASE_KEY = "your-anon-key"  # MUDE AQUI

# PIZZAS COM PREÇOS CORRETOS (AJUSTE CONFORME NECESSÁRIO)
PIZZAS_CORRETAS = [
    {
        'nome': 'Pizza Margherita',
        'descricao': 'Molho de tomate, mozzarella e manjericão',
        'preco_unitario': 35.90,
        'categoria': 'Pizza',
        'tipo_produto': 'Pizza',
        'ativo': True,
        'ingredientes': ['molho de tomate', 'mozzarella', 'manjericão'],
        'tamanhos_precos': {
            'Pequena': 23.34,    # 35.90 * 0.65
            'Média': 30.52,      # 35.90 * 0.85
            'Grande': 35.90,     # 35.90 * 1.0
            'Família': 46.67     # 35.90 * 1.3
        }
    },
    {
        'nome': 'Pizza Calabresa',
        'descricao': 'Molho de tomate, mozzarella, calabresa e cebola',
        'preco_unitario': 38.90,
        'categoria': 'Pizza',
        'tipo_produto': 'Pizza',
        'ativo': True,
        'ingredientes': ['molho de tomate', 'mozzarella', 'calabresa', 'cebola'],
        'tamanhos_precos': {
            'Pequena': 25.29,
            'Média': 33.07,
            'Grande': 38.90,
            'Família': 50.57
        }
    },
    {
        'nome': 'Pizza Portuguesa',
        'descricao': 'Molho de tomate, mozzarella, presunto, ovos, cebola e azeitona',
        'preco_unitario': 42.90,
        'categoria': 'Pizza',
        'tipo_produto': 'Pizza',
        'ativo': True,
        'ingredientes': ['molho de tomate', 'mozzarella', 'presunto', 'ovos', 'cebola', 'azeitona'],
        'tamanhos_precos': {
            'Pequena': 27.89,
            'Média': 36.47,
            'Grande': 42.90,
            'Família': 55.77
        }
    },
    {
        'nome': 'Pizza 4 Queijos',
        'descricao': 'Mozzarella, gorgonzola, parmesão e catupiry',
        'preco_unitario': 45.90,
        'categoria': 'Pizza',
        'tipo_produto': 'Pizza',
        'ativo': True,
        'ingredientes': ['mozzarella', 'gorgonzola', 'parmesão', 'catupiry'],
        'tamanhos_precos': {
            'Pequena': 29.84,
            'Média': 39.02,
            'Grande': 45.90,
            'Família': 59.67
        }
    },
    {
        'nome': 'Pizza Vegetariana',
        'descricao': 'Molho de tomate, mozzarella, tomate, pimentão, cebola, azeitona e orégano',
        'preco_unitario': 39.90,
        'categoria': 'Pizza',
        'tipo_produto': 'Pizza',
        'ativo': True,
        'ingredientes': ['molho de tomate', 'mozzarella', 'tomate', 'pimentão', 'cebola', 'azeitona', 'orégano'],
        'tamanhos_precos': {
            'Pequena': 25.94,
            'Média': 33.92,
            'Grande': 39.90,
            'Família': 51.87
        }
    },
    {
        'nome': 'Pizza Napolitana',
        'descricao': 'Molho de tomate, mozzarella, tomate e manjericão',
        'preco_unitario': 37.90,
        'categoria': 'Pizza',
        'tipo_produto': 'Pizza',
        'ativo': True,
        'ingredientes': ['molho de tomate', 'mozzarella', 'tomate', 'manjericão'],
        'tamanhos_precos': {
            'Pequena': 24.64,
            'Média': 32.22,
            'Grande': 37.90,
            'Família': 49.27
        }
    },
    {
        'nome': 'Pizza Frango com Catupiry',
        'descricao': 'Molho de tomate, mozzarella, frango desfiado e catupiry',
        'preco_unitario': 41.90,
        'categoria': 'Pizza',
        'tipo_produto': 'Pizza',
        'ativo': True,
        'ingredientes': ['molho de tomate', 'mozzarella', 'frango desfiado', 'catupiry'],
        'tamanhos_precos': {
            'Pequena': 27.24,
            'Média': 35.62,
            'Grande': 41.90,
            'Família': 54.47
        }
    },
    {
        'nome': 'Pizza Pepperoni',
        'descricao': 'Molho de tomate, mozzarella e pepperoni',
        'preco_unitario': 43.90,
        'categoria': 'Pizza',
        'tipo_produto': 'Pizza',
        'ativo': True,
        'ingredientes': ['molho de tomate', 'mozzarella', 'pepperoni'],
        'tamanhos_precos': {
            'Pequena': 28.54,
            'Média': 37.32,
            'Grande': 43.90,
            'Família': 57.07
        }
    }
]

def main():
    print("🍕 SCRIPT PARA INSERIR PIZZAS COM PREÇOS CORRETOS")
    print("=" * 60)
    print(f"📊 {len(PIZZAS_CORRETAS)} pizzas serão inseridas no banco")
    print()
    
    try:
        # Conectar ao Supabase
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        
        # Buscar categoria de Pizza (ou criar se não existir)
        categoria_id = None
        try:
            categoria_response = supabase.table('produtos_categoria').select('*').eq('nome', 'Pizza').execute()
            if categoria_response.data:
                categoria_id = categoria_response.data[0]['id']
                print(f"✅ Categoria 'Pizza' encontrada: {categoria_id}")
            else:
                # Criar categoria Pizza
                nova_categoria = supabase.table('produtos_categoria').insert({
                    'nome': 'Pizza',
                    'descricao': 'Pizzas tradicionais e especiais'
                }).execute()
                categoria_id = nova_categoria.data[0]['id']
                print(f"✅ Categoria 'Pizza' criada: {categoria_id}")
        except:
            print("⚠️  Não foi possível buscar/criar categoria. Continuando sem categoria...")
        
        print()
        print("🚀 INSERINDO PIZZAS...")
        print("-" * 50)
        
        inseridas = 0
        erros = 0
        
        for pizza in PIZZAS_CORRETAS:
            try:
                # Preparar dados da pizza
                dados_pizza = {
                    'id': str(uuid.uuid4()),
                    'nome': pizza['nome'],
                    'descricao': pizza['descricao'],
                    'preco_unitario': pizza['preco_unitario'],
                    'categoria': pizza['categoria'],
                    'tipo_produto': pizza['tipo_produto'],
                    'ativo': pizza['ativo'],
                    'ingredientes': pizza['ingredientes'],
                    'tamanhos_precos': pizza['tamanhos_precos'],
                    'estoque_disponivel': True
                }
                
                # Adicionar categoria_id se disponível
                if categoria_id:
                    dados_pizza['categoria_id'] = categoria_id
                
                # Inserir no banco
                supabase.table('produtos_produto').insert(dados_pizza).execute()
                
                inseridas += 1
                print(f"✅ Inserida: {pizza['nome']} - R$ {pizza['preco_unitario']}")
                
            except Exception as e:
                erros += 1
                print(f"❌ Erro ao inserir {pizza['nome']}: {e}")
        
        print()
        print("🎯 RESULTADO FINAL:")
        print(f"✅ Pizzas inseridas: {inseridas}")
        print(f"❌ Erros: {erros}")
        print(f"📊 Total processadas: {inseridas + erros}/{len(PIZZAS_CORRETAS)}")
        
        if inseridas > 0:
            print()
            print("🎉 PIZZAS INSERIDAS COM SUCESSO!")
            print("💡 Agora as pizzas têm preços corretos e tamanhos calculados automaticamente.")
            print("💡 Teste no app para verificar se os preços estão aparecendo corretamente.")
        
    except Exception as e:
        print(f"❌ ERRO GERAL: {e}")
        print()
        print("💡 DICAS PARA CORRIGIR:")
        print("1. Verifique se SUPABASE_URL e SUPABASE_KEY estão corretos")
        print("2. Instale a biblioteca: pip install supabase")
        print("3. Verifique se a tabela 'produtos_produto' existe")
        print("4. Verifique as permissões de INSERT no Supabase")
        print("5. Ajuste os preços no array PIZZAS_CORRETAS conforme necessário")

if __name__ == "__main__":
    main()