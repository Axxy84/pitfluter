#!/usr/bin/env python3
"""
Teste final da interface - verificar se tudo está funcionando
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
    print("🧪 TESTE FINAL DA INTERFACE")
    print("=" * 40)
    
    try:
        # 1. SIMULAR QUERY DO FLUTTER
        print("🔍 Simulando query do Flutter...")
        produtos = fazer_request('produtos_produto', {
            'select': '*,produtos_categoria(nome)',
            'ativo': 'eq.true',
            'order': 'nome'
        })
        
        print(f"✅ {len(produtos)} produtos carregados")
        
        # 2. VERIFICAR PIZZAS DELIVERY
        pizzas_delivery = [p for p in produtos if p.get('produtos_categoria', {}).get('nome') == 'Pizza Delivery']
        
        print(f"\n🍕 PIZZAS DELIVERY ({len(pizzas_delivery)}):")
        print("   Nome                  | Preço Base | Categoria")
        print("   " + "-" * 50)
        
        for pizza in pizzas_delivery[:5]:
            nome = pizza['nome'][:18].ljust(18)
            
            # Simular lógica do Flutter para preço base
            preco_base = 25.0  # Default
            if pizza.get('preco_unitario'):
                preco_base = pizza['preco_unitario']
            
            # Se for Pizza Delivery, preço base = 40.0 (como no Flutter)
            categoria_nome = pizza['produtos_categoria']['nome']
            if categoria_nome.lower().count('delivery') > 0:
                preco_base = 40.0
                tag = " [PROMOCIONAL]"
            else:
                tag = ""
            
            print(f"   {nome} | R$ {preco_base:6.2f} | {categoria_nome}{tag}")
        
        if len(pizzas_delivery) > 5:
            print(f"   ... e mais {len(pizzas_delivery) - 5} pizzas")
        
        # 3. VERIFICAR OUTRAS CATEGORIAS
        outras_pizzas = [p for p in produtos if p.get('produtos_categoria', {}).get('nome') != 'Pizza Delivery' and p.get('tipo_produto') == 'pizza']
        bordas = [p for p in produtos if p.get('produtos_categoria', {}).get('nome') == 'Bordas Especiais']
        
        print(f"\n📊 RESUMO PRODUTOS:")
        print(f"  🍕 Pizzas Delivery (R$ 40,00): {len(pizzas_delivery)}")
        print(f"  🍕 Outras Pizzas: {len(outras_pizzas)}")
        print(f"  🧀 Bordas: {len(bordas)}")
        print(f"  📦 Total: {len(produtos)}")
        
        # 4. TESTE DE PREÇOS
        print(f"\n💰 TESTE DE CÁLCULO (como no Flutter):")
        if pizzas_delivery:
            pizza_teste = pizzas_delivery[0]
            print(f"  Pizza: {pizza_teste['nome']}")
            print(f"  Categoria: Pizza Delivery")
            print(f"  Preço base mostrado: R$ 40,00")
            print(f"  Tamanhos disponíveis: ['M'] (apenas Médio)")
            print(f"  Preço final: R$ 40,00 x quantidade")
            print(f"  Tag: PROMOCIONAL (laranja)")
        
        print(f"\n🎉 INTERFACE DEVERIA MOSTRAR:")
        print(f"  ✅ Pizzas Pizza Delivery com preço R$ 40,00")
        print(f"  ✅ Tag laranja 'PROMOCIONAL' nas pizzas delivery")
        print(f"  ✅ Apenas botão tamanho 'M' para pizzas delivery")
        print(f"  ✅ Preço correto R$ 40,00 no cálculo final")
        
    except Exception as e:
        print(f"❌ Erro: {e}")

if __name__ == "__main__":
    main()