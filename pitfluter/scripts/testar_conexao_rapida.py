#!/usr/bin/env python3
"""
Teste rápido da conexão e dados
"""

import json
import urllib.request

SUPABASE_URL = "https://lhvfacztsbflrtfibeek.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo"

def testar_tabela(tabela):
    url = f"{SUPABASE_URL}/rest/v1/{tabela}?select=*&limit=5"
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}'
    }
    
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as response:
            dados = json.loads(response.read().decode('utf-8'))
            return dados
    except Exception as e:
        return f"Erro: {e}"

print("🧪 TESTE RÁPIDO DO BANCO")
print("=" * 40)

# Testar query que o Flutter usa
print("🔍 Testando query do Flutter...")
try:
    url = f"{SUPABASE_URL}/rest/v1/produtos_produto?select=*,produtos_categoria(id,nome)&ativo=eq.true&order=nome"
    headers = {
        'apikey': SUPABASE_KEY,
        'Authorization': f'Bearer {SUPABASE_KEY}'
    }
    
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req) as response:
        produtos = json.loads(response.read().decode('utf-8'))
        
    print(f"✅ {len(produtos)} produtos encontrados!")
    print("\n🍕 Algumas pizzas:")
    for i, produto in enumerate(produtos[:5], 1):
        categoria = produto.get('produtos_categoria', {}) or {}
        cat_nome = categoria.get('nome', 'Sem categoria')
        print(f"  {i}. {produto['nome']} - {cat_nome}")
        
    # Verificar se tem pizzas da categoria correta
    pizzas_promocionais = [p for p in produtos if p.get('produtos_categoria', {}).get('nome') == 'Pizzas Promocionais']
    print(f"\n🎯 Pizzas Promocionais: {len(pizzas_promocionais)}")
    
    if pizzas_promocionais:
        print("✅ TUDO FUNCIONANDO! O Flutter deve carregar as pizzas.")
    else:
        print("⚠️ Pizzas promocionais não encontradas")
        
except Exception as e:
    print(f"❌ Erro na query do Flutter: {e}")
    
print("\n💡 Se aparecer 'TUDO FUNCIONANDO', o app Flutter está pronto!")