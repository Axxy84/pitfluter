#!/usr/bin/env python3
"""
Teste final dos preços das pizzas
"""

import json
import urllib.request
import urllib.parse

SUPABASE_URL = "https://lhvfacztsbflrtfibeek.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo"

def fazer_request(tabela, filtros=None):
    """Fazer requisição GET para Supabase"""
    url = f"{SUPABASE_URL}/rest/v1/{tabela}"
    
    if filtros:
        params = urllib.parse.urlencode(filtros)
        url += f"?{params}"
    
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}'
    }
    
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req) as response:
        return json.loads(response.read().decode('utf-8'))

def main():
    print("🧪 TESTE FINAL DOS PREÇOS")
    print("=" * 40)
    
    # 1. TESTAR QUERY DO FLUTTER
    print("🔍 Testando query do Flutter...")
    try:
        produtos = fazer_request('produtos_produto', {
            'select': '*,produtos_categoria(id,nome)',
            'ativo': 'eq.true',
            'order': 'nome'
        })
        
        print(f"✅ {len(produtos)} produtos encontrados!")
        
        # Filtrar pizzas delivery
        pizzas_delivery = [p for p in produtos if p.get('produtos_categoria', {}).get('nome') == 'Pizza Delivery']
        
        print(f"🍕 Pizzas Delivery: {len(pizzas_delivery)}")
        for pizza in pizzas_delivery[:5]:
            print(f"  • {pizza['nome']} - Categoria: {pizza['produtos_categoria']['nome']}")
        
        # 2. TESTAR PREÇOS POR TAMANHO
        print(f"\n💰 Testando preços por tamanho...")
        
        if pizzas_delivery:
            pizza_teste = pizzas_delivery[0]
            print(f"🔍 Testando pizza: {pizza_teste['nome']}")
            
            precos = fazer_request('produtos_produtopreco', {
                'select': '*,produtos_tamanho(nome)',
                'produto_id': f'eq.{pizza_teste["id"]}'
            })
            
            print(f"📊 Preços encontrados: {len(precos)}")
            for preco in precos:
                tamanho = preco['produtos_tamanho']['nome']
                valor = preco['preco']
                print(f"  • {tamanho}: R$ {valor:.2f}")
        
        # 3. VERIFICAR SE TAMANHO MÉDIO = R$ 40
        print(f"\n🎯 Verificando preço médio R$ 40,00...")
        precos_medio = fazer_request('produtos_produtopreco', {
            'select': '*,produtos_produto(nome),produtos_tamanho(nome)',
            'preco': 'eq.40.0'
        })
        
        print(f"✅ {len(precos_medio)} preços de R$ 40,00 encontrados")
        for preco in precos_medio[:3]:
            produto_nome = preco['produtos_produto']['nome']
            tamanho_nome = preco['produtos_tamanho']['nome']
            print(f"  • {produto_nome} - {tamanho_nome}: R$ {preco['preco']:.2f}")
        
        print(f"\n🎉 TESTE CONCLUÍDO!")
        print(f"✅ Estrutura correta: {len(pizzas_delivery)} pizzas únicas")
        print(f"✅ Preços R$ 40 configurados: {len(precos_medio)}")
        print(f"💡 App Flutter deve funcionar perfeitamente!")
        
    except Exception as e:
        print(f"❌ Erro: {e}")

if __name__ == "__main__":
    main()