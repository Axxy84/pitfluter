#!/usr/bin/env python3
"""
Teste específico para verificar se as pizzas Pizza Delivery 
estão com preço correto de R$ 40,00
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
    print("🍕 TESTE ESPECÍFICO: PIZZA DELIVERY PREÇOS")
    print("=" * 50)
    
    try:
        # 1. BUSCAR PIZZAS DELIVERY
        print("🔍 Buscando pizzas da categoria Pizza Delivery...")
        produtos = fazer_request('produtos_produto', {
            'select': '*,produtos_categoria(nome)',
            'ativo': 'eq.true'
        })
        
        pizzas_delivery = [p for p in produtos if p.get('produtos_categoria', {}).get('nome') == 'Pizza Delivery']
        print(f"✅ Encontradas {len(pizzas_delivery)} pizzas Pizza Delivery")
        
        # 2. VERIFICAR PREÇOS DE CADA PIZZA
        print(f"\n💰 Verificando preços por pizza:")
        problemas = 0
        
        for pizza in pizzas_delivery:
            nome = pizza['nome']
            pizza_id = pizza['id']
            
            # Buscar preços desta pizza
            precos = fazer_request('produtos_produtopreco', {
                'select': '*,produtos_tamanho(nome)',
                'produto_id': f'eq.{pizza_id}'
            })
            
            print(f"\n🍕 {nome}:")
            precos_corretos = 0
            precos_incorretos = 0
            
            for preco in precos:
                tamanho = preco['produtos_tamanho']['nome']
                valor = preco['preco']
                
                if tamanho == 'Média' and valor == 40.0:
                    print(f"  ✅ {tamanho}: R$ {valor:.2f} ✓")
                    precos_corretos += 1
                elif tamanho == 'Média' and valor != 40.0:
                    print(f"  ❌ {tamanho}: R$ {valor:.2f} (DEVERIA SER R$ 40,00)")
                    precos_incorretos += 1
                    problemas += 1
                else:
                    print(f"  ⚠️ {tamanho}: R$ {valor:.2f} (não deveria existir)")
                    precos_incorretos += 1
                    problemas += 1
            
            if precos_corretos == 0:
                print(f"  ❌ PIZZA SEM PREÇO MÉDIO R$ 40,00!")
                problemas += 1
        
        # 3. RESULTADO FINAL
        print(f"\n📊 RESULTADO FINAL:")
        if problemas == 0:
            print(f"🎉 SUCESSO! Todas as {len(pizzas_delivery)} pizzas estão configuradas corretamente:")
            print(f"  ✅ Categoria: Pizza Delivery")
            print(f"  ✅ Preço: R$ 40,00 para tamanho Médio")
            print(f"💡 O app Flutter deve mostrar apenas tamanho Médio e preço R$ 40,00")
        else:
            print(f"❌ PROBLEMAS ENCONTRADOS: {problemas}")
            print(f"💡 É necessário corrigir os preços no banco de dados")
        
        # 4. TESTAR QUERY DO FLUTTER
        print(f"\n🔍 SIMULANDO QUERY DO FLUTTER:")
        print(f"SELECT produtos_produto.*, produtos_categoria.nome as categoria")
        print(f"FROM produtos_produto JOIN produtos_categoria")
        print(f"WHERE produtos_categoria.nome = 'Pizza Delivery'")
        print(f"Resultado: {len(pizzas_delivery)} produtos encontrados")
        
        if pizzas_delivery:
            pizza_exemplo = pizzas_delivery[0]
            print(f"\n📋 EXEMPLO DE PRODUTO (para teste no Flutter):")
            print(f"  Nome: {pizza_exemplo['nome']}")
            print(f"  ID: {pizza_exemplo['id']}")
            print(f"  Categoria: {pizza_exemplo['produtos_categoria']['nome']}")
            print(f"  Tipo: {pizza_exemplo.get('tipo_produto', 'N/A')}")
        
    except Exception as e:
        print(f"❌ ERRO: {e}")

if __name__ == "__main__":
    main()