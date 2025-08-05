#!/usr/bin/env python3
"""
Script para limpar pizzas duplicadas e manter apenas 16 únicas
"""

import json
import urllib.request
import urllib.parse
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
    elif metodo == 'DELETE':
        req = urllib.request.Request(url, headers=headers)
        req.get_method = lambda: 'DELETE'
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
    print("🧹 LIMPANDO PIZZAS DUPLICADAS")
    print("=" * 50)
    
    try:
        # 1. BUSCAR CATEGORIA PIZZA DELIVERY
        categoria_delivery = fazer_request('produtos_categoria', metodo='GET',
                                         filtros={'nome': 'eq.Pizza Delivery', 'select': 'id'})
        
        if not categoria_delivery:
            print("❌ Categoria 'Pizza Delivery' não encontrada!")
            return
            
        categoria_id = categoria_delivery[0]['id']
        print(f"✅ Categoria Pizza Delivery: ID {categoria_id}")
        
        # 2. BUSCAR TODAS AS PIZZAS DELIVERY
        pizzas_delivery = fazer_request('produtos_produto', metodo='GET',
                                      filtros={'categoria_id': f'eq.{categoria_id}',
                                             'select': 'id,nome'})
        
        print(f"🔍 Total de pizzas encontradas: {len(pizzas_delivery)}")
        
        # 3. IDENTIFICAR DUPLICATAS
        nomes_vistos = {}
        duplicatas = []
        originais = []
        
        for pizza in pizzas_delivery:
            nome = pizza['nome']
            if nome in nomes_vistos:
                # Esta é uma duplicata
                duplicatas.append(pizza)
                print(f"  🔄 DUPLICATA: {nome} (ID: {pizza['id']})")
            else:
                # Esta é a original
                nomes_vistos[nome] = pizza['id']
                originais.append(pizza)
                print(f"  ✅ ORIGINAL: {nome} (ID: {pizza['id']})")
        
        print(f"\n📊 ANÁLISE:")
        print(f"  • Pizzas originais: {len(originais)}")
        print(f"  • Pizzas duplicadas: {len(duplicatas)}")
        
        if len(duplicatas) == 0:
            print("🎉 Não há duplicatas para remover!")
            return
        
        # 4. DELETAR DUPLICATAS
        print(f"\n🗑️ DELETANDO {len(duplicatas)} PIZZAS DUPLICADAS...")
        
        deletadas = 0
        erros = 0
        
        for pizza in duplicatas:
            try:
                # Deletar preços primeiro (foreign key)
                fazer_request('produtos_produtopreco', metodo='DELETE',
                            filtros={'produto_id': f'eq.{pizza["id"]}'})
                
                # Deletar produto
                fazer_request('produtos_produto', metodo='DELETE',
                            filtros={'id': f'eq.{pizza["id"]}'})
                
                deletadas += 1
                print(f"  ✅ Deletada: {pizza['nome']} (ID: {pizza['id']})")
                time.sleep(0.1)
                
            except Exception as e:
                erros += 1
                print(f"  ❌ Erro ao deletar {pizza['nome']}: {e}")
        
        # 5. VERIFICAÇÃO FINAL
        print(f"\n🔍 VERIFICAÇÃO FINAL...")
        pizzas_restantes = fazer_request('produtos_produto', metodo='GET',
                                       filtros={'categoria_id': f'eq.{categoria_id}'})
        
        print(f"📊 RESULTADO FINAL:")
        print(f"  ✅ Pizzas deletadas: {deletadas}")
        print(f"  ❌ Erros: {erros}")
        print(f"  🍕 Pizzas restantes: {len(pizzas_restantes) if pizzas_restantes else 0}")
        
        if pizzas_restantes:
            print(f"\n🍕 PIZZAS FINAIS (únicas):")
            for i, pizza in enumerate(pizzas_restantes, 1):
                print(f"  {i:2d}. {pizza['nome']}")
        
        print(f"\n🎉 LIMPEZA CONCLUÍDA!")
        print(f"💡 Agora você tem apenas pizzas únicas na categoria Pizza Delivery")
        
    except Exception as e:
        print(f"❌ ERRO GERAL: {e}")

if __name__ == "__main__":
    main()