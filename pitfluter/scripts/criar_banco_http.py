#!/usr/bin/env python3
"""
Script para criar estrutura do banco usando HTTP direto (sem dependências)
"""

import json
import urllib.request
import urllib.parse
import time

# Configurações do novo banco
SUPABASE_URL = "https://lhvfacztsbflrtfibeek.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo"

def fazer_request(tabela, dados=None, metodo='POST', filtros=None):
    """Fazer requisição HTTP para Supabase"""
    url = f"{SUPABASE_URL}/rest/v1/{tabela}"
    
    if filtros:
        params = urllib.parse.urlencode(filtros)
        url += f"?{params}"
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    }
    
    if metodo == 'GET':
        req = urllib.request.Request(url, headers=headers)
    else:
        data = json.dumps(dados).encode('utf-8') if dados else None
        req = urllib.request.Request(url, data=data, headers=headers)
        req.get_method = lambda: metodo
    
    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8')
        raise Exception(f"HTTP {e.code}: {error_body}")

def main():
    print("🚀 CRIANDO ESTRUTURA DO BANCO VIA HTTP")
    print("=" * 60)
    
    try:
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
                resultado = fazer_request('produtos_categoria', categoria)
                print(f"  ✅ {categoria['nome']}")
            except Exception as e:
                if "already exists" in str(e) or "duplicate" in str(e) or "violates unique constraint" in str(e):
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
                resultado = fazer_request('produtos_tamanho', tamanho)
                print(f"  ✅ {tamanho['nome']}")
            except Exception as e:
                if "already exists" in str(e) or "duplicate" in str(e) or "violates unique constraint" in str(e):
                    print(f"  ⚠️ {tamanho['nome']} (já existe)")
                else:
                    print(f"  ❌ {tamanho['nome']}: {e}")
        
        # 3. BUSCAR IDs
        print("\n🔍 BUSCANDO IDs...")
        cat_promocional = fazer_request('produtos_categoria', metodo='GET', filtros={'nome': 'eq.Pizzas Promocionais', 'select': 'id'})
        tamanho_8_pedacos = fazer_request('produtos_tamanho', metodo='GET', filtros={'nome': 'eq.8 Pedaços', 'select': 'id'})
        
        if not cat_promocional or not tamanho_8_pedacos:
            print("❌ Erro: Não foi possível encontrar categoria ou tamanho")
            return
            
        categoria_id = cat_promocional[0]['id']
        tamanho_id = tamanho_8_pedacos[0]['id']
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
                
                resultado = fazer_request('produtos_produto', produto_data)
                if resultado:
                    produtos_inseridos.extend(resultado if isinstance(resultado, list) else [resultado])
                    print(f"  ✅ {pizza['nome']}")
                time.sleep(0.2)
                
            except Exception as e:
                if "already exists" in str(e) or "duplicate" in str(e):
                    print(f"  ⚠️ {pizza['nome']} (já existe)")
                else:
                    print(f"  ❌ {pizza['nome']}: {e}")
        
        # 5. CRIAR PREÇOS
        print(f"\n💰 CRIANDO PREÇOS...")
        for produto in produtos_inseridos:
            try:
                preco_data = {
                    'produto_id': produto['id'],
                    'tamanho_id': tamanho_id,
                    'preco': 40.00,
                    'preco_promocional': 40.00
                }
                
                fazer_request('produtos_produtopreco', preco_data)
                print(f"  ✅ Preço para {produto['nome']}")
                time.sleep(0.1)
                
            except Exception as e:
                print(f"  ❌ Erro no preço de {produto['nome']}: {e}")
        
        # 6. VERIFICAÇÃO FINAL
        print("\n🔍 VERIFICAÇÃO FINAL...")
        try:
            total_categorias = fazer_request('produtos_categoria', metodo='GET')
            total_tamanhos = fazer_request('produtos_tamanho', metodo='GET')
            total_produtos = fazer_request('produtos_produto', metodo='GET')
            total_precos = fazer_request('produtos_produtopreco', metodo='GET')
            
            print(f"📊 RESULTADO FINAL:")
            print(f"  ✅ Categorias: {len(total_categorias) if total_categorias else 0}")
            print(f"  ✅ Tamanhos: {len(total_tamanhos) if total_tamanhos else 0}")
            print(f"  ✅ Produtos: {len(total_produtos) if total_produtos else 0}")
            print(f"  ✅ Preços: {len(total_precos) if total_precos else 0}")
            
            print(f"\n🎉 BANCO POPULADO COM SUCESSO!")
            print(f"💡 Agora teste o app Flutter!")
            
            # Mostrar pizzas
            if total_produtos:
                print(f"\n🍕 PIZZAS DISPONÍVEIS:")
                for i, produto in enumerate(total_produtos[:8], 1):
                    print(f"  {i:2d}. {produto['nome']}")
                if len(total_produtos) > 8:
                    print(f"     ... e mais {len(total_produtos) - 8}")
        except Exception as e:
            print(f"⚠️ Erro na verificação final: {e}")
            
    except Exception as e:
        print(f"❌ ERRO GERAL: {e}")
        print(f"\n💡 Possíveis soluções:")
        print(f"   1. Verifique se as tabelas foram criadas no Supabase")
        print(f"   2. Execute o SQL das tabelas manualmente primeiro")
        print(f"   3. Verifique as permissões RLS no Supabase")

if __name__ == "__main__":
    main()