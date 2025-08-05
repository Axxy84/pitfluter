#!/usr/bin/env python3
"""
Script para criar TODA a estrutura do banco automaticamente
"""

from supabase import create_client, Client
import time

# Configurações do novo banco
SUPABASE_URL = "https://lhvfacztsbflrtfibeek.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo"

def main():
    print("🚀 CRIANDO ESTRUTURA COMPLETA DO BANCO AUTOMATICAMENTE")
    print("=" * 70)
    
    try:
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✅ Conectado ao Supabase")
        
        # 1. CRIAR CATEGORIAS
        print("\n📂 CRIANDO CATEGORIAS...")
        categorias = [
            {'nome': 'Pizzas Promocionais', 'descricao': 'Pizzas com preço especial - R$ 40,00', 'ativo': True},
            {'nome': 'Pizzas Tradicionais', 'descricao': 'Pizzas clássicas do cardápio', 'ativo': True},
            {'nome': 'Bebidas', 'descricao': 'Refrigerantes e sucos', 'ativo': True},
            {'nome': 'Sobremesas', 'descricao': 'Doces e sobremesas', 'ativo': True},
            {'nome': 'Bordas Recheadas', 'descricao': 'Opções de bordas especiais', 'ativo': True}
        ]
        
        for categoria in categorias:
            try:
                supabase.table('produtos_categoria').insert(categoria).execute()
                print(f"  ✅ {categoria['nome']}")
            except Exception as e:
                if "already exists" in str(e) or "duplicate" in str(e):
                    print(f"  ⚠️ {categoria['nome']} (já existe)")
                else:
                    print(f"  ❌ {categoria['nome']}: {e}")
        
        # 2. CRIAR TAMANHOS
        print("\n📏 CRIANDO TAMANHOS...")
        tamanhos = [
            {'nome': 'Broto', 'ordem': 1, 'ativo': True},
            {'nome': 'Média', 'ordem': 2, 'ativo': True},
            {'nome': 'Grande', 'ordem': 3, 'ativo': True},
            {'nome': 'Família', 'ordem': 4, 'ativo': True},
            {'nome': '8 Pedaços', 'ordem': 5, 'ativo': True}
        ]
        
        for tamanho in tamanhos:
            try:
                supabase.table('produtos_tamanho').insert(tamanho).execute()
                print(f"  ✅ {tamanho['nome']}")
            except Exception as e:
                if "already exists" in str(e) or "duplicate" in str(e):
                    print(f"  ⚠️ {tamanho['nome']} (já existe)")
                else:
                    print(f"  ❌ {tamanho['nome']}: {e}")
        
        # 3. BUSCAR IDs DAS CATEGORIAS E TAMANHOS
        print("\n🔍 BUSCANDO IDs...")
        cat_promocional = supabase.table('produtos_categoria').select('id').eq('nome', 'Pizzas Promocionais').execute()
        tamanho_8_pedacos = supabase.table('produtos_tamanho').select('id').eq('nome', '8 Pedaços').execute()
        
        if not cat_promocional.data or not tamanho_8_pedacos.data:
            print("❌ Erro: Não foi possível encontrar categoria ou tamanho")
            return
            
        categoria_id = cat_promocional.data[0]['id']
        tamanho_id = tamanho_8_pedacos.data[0]['id']
        print(f"  ✅ Categoria Promocional ID: {categoria_id}")
        print(f"  ✅ Tamanho 8 Pedaços ID: {tamanho_id}")
        
        # 4. CRIAR PIZZAS
        print("\n🍕 CRIANDO PIZZAS...")
        pizzas = [
            {'nome': 'Alho Frito', 'descricao': 'Molho, mussarela, alho frito e orégano'},
            {'nome': 'Atum', 'descricao': 'Molho, mussarela, atum, cebola e orégano'},
            {'nome': 'Bacon', 'descricao': 'Molho, mussarela, bacon e orégano'},
            {'nome': 'Baiana', 'descricao': 'Molho, mussarela, calabresa moída, pimenta calabresa, tomate em rodela e orégano'},
            {'nome': 'Banana Caramelizada', 'descricao': 'Leite condensado, banana caramelizada e canela em pó'},
            {'nome': 'Baurú', 'descricao': 'Molho, mussarela, presunto, milho verde e orégano'},
            {'nome': 'Calabresa', 'descricao': 'Molho, mussarela, calabresa, cebola e orégano'},
            {'nome': 'Frango ao Catupiry', 'descricao': 'Molho, mussarela, peito de frango e orégano'},
            {'nome': 'Marguerita', 'descricao': 'Molho, mussarela, tomate, manjericão e orégano'},
            {'nome': 'Luzitana', 'descricao': 'Molho, mussarela, ervilha, ovo, cebola e orégano'},
            {'nome': 'Milho Verde', 'descricao': 'Molho, mussarela, milho verde e orégano'},
            {'nome': 'Mussarela', 'descricao': 'Molho, mussarela, tomate em rodela e orégano'},
            {'nome': 'Portuguesa sem Palmito', 'descricao': 'Molho, mussarela, presunto, cebola, vinagrete, milho verde, ovos, pimentão e orégano'},
            {'nome': 'Lombo', 'descricao': 'Molho, mussarela, presunto, lombo canadense e orégano'},
            {'nome': 'Abacaxi Gratinado', 'descricao': 'Leite condensado, mussarela, abacaxi gratinado e canela'},
            {'nome': 'Romeu e Julieta', 'descricao': 'Leite condensado, mussarela e goiabada'}
        ]
        
        produtos_inseridos = []
        for pizza in pizzas:
            try:
                produto_data = {
                    'nome': pizza['nome'],
                    'descricao': pizza['descricao'],
                    'categoria_id': categoria_id,
                    'tipo_produto': 'pizza',
                    'preco_unitario': 40.00,
                    'ingredientes': pizza['descricao'],
                    'estoque_disponivel': 100,
                    'ativo': True
                }
                
                result = supabase.table('produtos_produto').insert(produto_data).execute()
                produtos_inseridos.append(result.data[0])
                print(f"  ✅ {pizza['nome']}")
                time.sleep(0.1)  # Evitar sobrecarga
                
            except Exception as e:
                if "already exists" in str(e) or "duplicate" in str(e):
                    print(f"  ⚠️ {pizza['nome']} (já existe)")
                else:
                    print(f"  ❌ {pizza['nome']}: {e}")
        
        # 5. CRIAR PREÇOS
        print(f"\n💰 CRIANDO PREÇOS PARA {len(produtos_inseridos)} PIZZAS...")
        for produto in produtos_inseridos:
            try:
                preco_data = {
                    'produto_id': produto['id'],
                    'tamanho_id': tamanho_id,
                    'preco': 40.00,
                    'preco_promocional': 40.00
                }
                
                supabase.table('produtos_produtopreco').insert(preco_data).execute()
                print(f"  ✅ Preço para {produto['nome']}")
                time.sleep(0.05)
                
            except Exception as e:
                print(f"  ❌ Erro no preço de {produto['nome']}: {e}")
        
        # 6. VERIFICAÇÃO FINAL
        print("\n🔍 VERIFICAÇÃO FINAL...")
        total_categorias = supabase.table('produtos_categoria').select('*').execute()
        total_tamanhos = supabase.table('produtos_tamanho').select('*').execute()
        total_produtos = supabase.table('produtos_produto').select('*').execute()
        total_precos = supabase.table('produtos_produtopreco').select('*').execute()
        
        print(f"📊 RESULTADO FINAL:")
        print(f"  ✅ Categorias: {len(total_categorias.data)}")
        print(f"  ✅ Tamanhos: {len(total_tamanhos.data)}")
        print(f"  ✅ Produtos: {len(total_produtos.data)}")
        print(f"  ✅ Preços: {len(total_precos.data)}")
        
        print(f"\n🎉 BANCO CRIADO COM SUCESSO!")
        print(f"💡 Agora teste o app Flutter - as pizzas devem aparecer!")
        
        # Mostrar algumas pizzas
        print(f"\n🍕 PIZZAS DISPONÍVEIS:")
        for i, produto in enumerate(total_produtos.data[:8], 1):
            print(f"  {i:2d}. {produto['nome']}")
        if len(total_produtos.data) > 8:
            print(f"     ... e mais {len(total_produtos.data) - 8}")
            
    except Exception as e:
        print(f"❌ ERRO GERAL: {e}")
        print(f"\n💡 Se o erro for sobre tabelas não existirem:")
        print(f"   Execute o SQL manualmente no Supabase Dashboard primeiro")

if __name__ == "__main__":
    main()