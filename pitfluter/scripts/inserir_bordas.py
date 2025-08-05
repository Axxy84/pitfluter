#!/usr/bin/env python3
"""
Script para inserir bordas recheadas no banco
"""

import json
import urllib.request
import time

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
    print("🥪 INSERINDO BORDAS RECHEADAS")
    print("=" * 50)
    
    try:
        # 1. BUSCAR CATEGORIA BORDAS
        print("🔍 Buscando categoria 'Bordas Recheadas'...")
        categoria_bordas = fazer_request('produtos_categoria', metodo='GET', 
                                       filtros={'nome': 'eq.Bordas Recheadas', 'select': 'id'})
        
        if not categoria_bordas:
            print("❌ Categoria 'Bordas Recheadas' não encontrada!")
            return
            
        categoria_id = categoria_bordas[0]['id']
        print(f"✅ Categoria encontrada: ID {categoria_id}")
        
        # 2. BUSCAR TAMANHO PADRÃO (8 Pedaços)
        tamanho_8 = fazer_request('produtos_tamanho', metodo='GET',
                                filtros={'nome': 'eq.8 Pedaços', 'select': 'id'})
        
        if not tamanho_8:
            print("❌ Tamanho '8 Pedaços' não encontrado!")
            return
            
        tamanho_id = tamanho_8[0]['id']
        print(f"✅ Tamanho encontrado: ID {tamanho_id}")
        
        # 3. BORDAS PARA INSERIR
        bordas = [
            {'nome': 'Borda Catupiry', 'descricao': 'Borda recheada com catupiry', 'preco': 7.00},
            {'nome': 'Borda Cheddar', 'descricao': 'Borda recheada com cheddar', 'preco': 8.00},
            {'nome': 'Borda Mussarela', 'descricao': 'Borda recheada com mussarela', 'preco': 7.00},
            {'nome': 'Borda Nutella', 'descricao': 'Borda recheada com nutella', 'preco': 10.00},
            {'nome': 'Borda Romeu e Julieta', 'descricao': 'Borda com goiabada e queijo', 'preco': 10.00},
            {'nome': 'Borda Beijinho', 'descricao': 'Borda doce com beijinho', 'preco': 8.00},
            {'nome': 'Borda Brigadeiro', 'descricao': 'Borda doce com brigadeiro', 'preco': 8.00},
            {'nome': 'Borda Doce de Leite', 'descricao': 'Borda com doce de leite', 'preco': 8.00},
            {'nome': 'Borda Goiabada', 'descricao': 'Borda com goiabada', 'preco': 7.00}
        ]
        
        print(f"\n🥪 INSERINDO {len(bordas)} BORDAS...")
        bordas_inseridas = []
        
        for borda in bordas:
            try:
                produto_data = {
                    'nome': borda['nome'],
                    'descricao': borda['descricao'],
                    'categoria_id': categoria_id,
                    'tipo_produto': 'borda',
                    'preco_unitario': borda['preco'],
                    'ingredientes': borda['descricao'],
                    'estoque_disponivel': 100,
                    'ativo': True
                }
                
                resultado = fazer_request('produtos_produto', produto_data)
                if resultado:
                    bordas_inseridas.extend(resultado if isinstance(resultado, list) else [resultado])
                    print(f"  ✅ {borda['nome']} - R$ {borda['preco']:.2f}")
                time.sleep(0.1)
                
            except Exception as e:
                if "already exists" in str(e) or "duplicate" in str(e):
                    print(f"  ⚠️ {borda['nome']} (já existe)")
                else:
                    print(f"  ❌ {borda['nome']}: {e}")
        
        # 4. CRIAR PREÇOS PARA AS BORDAS
        print(f"\n💰 CRIANDO PREÇOS...")
        for borda in bordas_inseridas:
            try:
                preco_data = {
                    'produto_id': borda['id'],
                    'tamanho_id': tamanho_id,
                    'preco': borda['preco_unitario'],
                    'preco_promocional': borda['preco_unitario']
                }
                
                fazer_request('produtos_produtopreco', preco_data)
                print(f"  ✅ Preço para {borda['nome']}")
                time.sleep(0.05)
                
            except Exception as e:
                print(f"  ❌ Erro no preço de {borda['nome']}: {e}")
        
        # 5. VERIFICAÇÃO FINAL
        print(f"\n🔍 VERIFICAÇÃO FINAL...")
        total_bordas = fazer_request('produtos_produto', metodo='GET',
                                   filtros={'categoria_id': f'eq.{categoria_id}'})
        
        print(f"📊 RESULTADO:")
        print(f"  ✅ Bordas inseridas: {len(bordas_inseridas)}")
        print(f"  ✅ Total de bordas: {len(total_bordas) if total_bordas else 0}")
        
        print(f"\n🎉 BORDAS INSERIDAS COM SUCESSO!")
        print(f"💡 Agora teste a aba 'Bordas' no app Flutter!")
        
        if total_bordas:
            print(f"\n🥪 BORDAS DISPONÍVEIS:")
            for i, borda in enumerate(total_bordas, 1):
                print(f"  {i:2d}. {borda['nome']} - R$ {borda['preco_unitario']:.2f}")
                
    except Exception as e:
        print(f"❌ ERRO GERAL: {e}")

if __name__ == "__main__":
    main()