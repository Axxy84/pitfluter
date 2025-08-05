#!/usr/bin/env python3
"""
Script para corrigir preços das pizzas Pizza Delivery
- Manter apenas preço de tamanho Médio R$ 40,00
- Remover preços de outros tamanhos
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
            if response.getcode() == 204:  # No content
                return []
            return json.loads(response.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8')
        raise Exception(f"HTTP {e.code}: {error_body}")

def main():
    print("🔧 CORRIGINDO PREÇOS PIZZA DELIVERY")
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
        
        # 2. BUSCAR TAMANHO MÉDIO
        tamanho_medio = fazer_request('produtos_tamanho', metodo='GET',
                                    filtros={'nome': 'eq.Média', 'select': 'id'})
        
        if not tamanho_medio:
            print("❌ Tamanho 'Média' não encontrado!")
            return
            
        tamanho_medio_id = tamanho_medio[0]['id']
        print(f"✅ Tamanho Médio: ID {tamanho_medio_id}")
        
        # 3. BUSCAR TODAS AS PIZZAS DELIVERY
        pizzas_delivery = fazer_request('produtos_produto', metodo='GET',
                                      filtros={'categoria_id': f'eq.{categoria_id}',
                                             'select': 'id,nome'})
        
        print(f"🍕 Encontradas {len(pizzas_delivery)} pizzas Pizza Delivery")
        
        # 4. LIMPAR PREÇOS INCORRETOS
        print(f"\\n🧹 Removendo preços de tamanhos incorretos...")
        
        precos_removidos = 0
        erros = 0
        
        for pizza in pizzas_delivery:
            try:
                # Buscar todos os preços desta pizza
                precos = fazer_request('produtos_produtopreco', metodo='GET',
                                     filtros={'produto_id': f'eq.{pizza["id"]}',
                                            'select': 'id,preco,tamanho_id,produtos_tamanho(nome)'})
                
                for preco in precos:
                    tamanho_nome = preco['produtos_tamanho']['nome']
                    
                    # Se NÃO for tamanho médio, deletar
                    if tamanho_nome != 'Média':
                        fazer_request('produtos_produtopreco', metodo='DELETE',
                                    filtros={'id': f'eq.{preco["id"]}'})
                        
                        precos_removidos += 1
                        print(f"  ❌ Removido: {pizza['nome']} - {tamanho_nome}")
                        time.sleep(0.05)
                
            except Exception as e:
                erros += 1
                print(f"  ❌ Erro em {pizza['nome']}: {e}")
        
        # 5. VERIFICAÇÃO FINAL
        print(f"\\n🔍 VERIFICAÇÃO FINAL...")
        
        total_precos_corretos = 0
        for pizza in pizzas_delivery:
            precos = fazer_request('produtos_produtopreco', metodo='GET',
                                 filtros={'produto_id': f'eq.{pizza["id"]}',
                                        'select': 'preco,produtos_tamanho(nome)'})
            
            for preco in precos:
                if (preco['produtos_tamanho']['nome'] == 'Média' and 
                    preco['preco'] == 40.0):
                    total_precos_corretos += 1
        
        print(f"📊 RESULTADO:")
        print(f"  ✅ Preços removidos: {precos_removidos}")
        print(f"  ❌ Erros: {erros}")
        print(f"  🍕 Pizzas com preço correto (Média R$ 40): {total_precos_corretos}")
        print(f"  🎯 Esperado: {len(pizzas_delivery)} pizzas")
        
        if total_precos_corretos == len(pizzas_delivery):
            print(f"\\n🎉 SUCESSO! TODAS AS PIZZAS CORRIGIDAS!")
            print(f"💡 Agora cada pizza tem apenas:")
            print(f"   • Tamanho: Média")
            print(f"   • Preço: R$ 40,00")
            print(f"💡 O app Flutter deve funcionar perfeitamente!")
        else:
            print(f"\\n⚠️ ATENÇÃO: Algumas pizzas podem ter problemas")
            print(f"💡 Execute o script de teste novamente para verificar")
        
    except Exception as e:
        print(f"❌ ERRO GERAL: {e}")

if __name__ == "__main__":
    main()