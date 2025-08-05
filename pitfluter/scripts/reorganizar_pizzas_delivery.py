#!/usr/bin/env python3
"""
Script para reorganizar pizzas para categoria Pizza Delivery
com preço R$ 40,00 apenas para tamanho médio
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
    elif metodo == 'PATCH':
        data = json.dumps(dados).encode('utf-8') if dados else None
        req = urllib.request.Request(url, data=data, headers=headers)
        req.get_method = lambda: 'PATCH'
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
    print("🍕 REORGANIZANDO PIZZAS PARA DELIVERY")
    print("=" * 60)
    
    try:
        # 1. CRIAR/BUSCAR CATEGORIA PIZZA DELIVERY
        print("📂 Criando categoria 'Pizza Delivery'...")
        try:
            categoria_delivery = {
                'nome': 'Pizza Delivery',
                'descricao': 'Pizzas para delivery - Tamanho médio R$ 40,00',
                'ativo': True
            }
            resultado = fazer_request('produtos_categoria', categoria_delivery)
            categoria_delivery_id = resultado[0]['id'] if isinstance(resultado, list) else resultado['id']
            print(f"  ✅ Categoria criada: ID {categoria_delivery_id}")
        except Exception as e:
            if "already exists" in str(e) or "duplicate" in str(e):
                # Buscar categoria existente
                categoria_delivery = fazer_request('produtos_categoria', metodo='GET',
                                                 filtros={'nome': 'eq.Pizza Delivery', 'select': 'id'})
                categoria_delivery_id = categoria_delivery[0]['id']
                print(f"  ⚠️ Categoria já existe: ID {categoria_delivery_id}")
            else:
                raise e
        
        # 2. BUSCAR TAMANHOS
        print("\n📏 Buscando tamanhos...")
        tamanhos = fazer_request('produtos_tamanho', metodo='GET', filtros={'select': 'id,nome'})
        tamanho_medio_id = None
        
        for tamanho in tamanhos:
            if tamanho['nome'].lower() == 'média':
                tamanho_medio_id = tamanho['id']
                print(f"  ✅ Tamanho Médio encontrado: ID {tamanho_medio_id}")
                break
        
        if not tamanho_medio_id:
            print("  ❌ Tamanho 'Média' não encontrado!")
            return
        
        # 3. BUSCAR PIZZAS PROMOCIONAIS
        print("\n🔍 Buscando pizzas promocionais...")
        categoria_promocional = fazer_request('produtos_categoria', metodo='GET',
                                            filtros={'nome': 'eq.Pizzas Promocionais', 'select': 'id'})
        
        if not categoria_promocional:
            print("  ❌ Categoria 'Pizzas Promocionais' não encontrada!")
            return
            
        categoria_promocional_id = categoria_promocional[0]['id']
        
        # Buscar todas as pizzas promocionais
        pizzas_promocionais = fazer_request('produtos_produto', metodo='GET',
                                          filtros={'categoria_id': f'eq.{categoria_promocional_id}',
                                                 'tipo_produto': 'eq.pizza'})
        
        print(f"  ✅ {len(pizzas_promocionais)} pizzas promocionais encontradas")
        
        # 4. MOVER PIZZAS PARA CATEGORIA DELIVERY
        print(f"\n🚚 Movendo pizzas para categoria Delivery...")
        for pizza in pizzas_promocionais:
            try:
                # Atualizar categoria da pizza
                dados_atualizacao = {'categoria_id': categoria_delivery_id}
                fazer_request('produtos_produto', dados_atualizacao, 'PATCH',
                            filtros={'id': f'eq.{pizza["id"]}'})
                
                print(f"  ✅ {pizza['nome']} movida para Delivery")
                time.sleep(0.1)
                
            except Exception as e:
                print(f"  ❌ Erro ao mover {pizza['nome']}: {e}")
        
        # 5. ATUALIZAR PREÇOS PARA TAMANHO MÉDIO = R$ 40,00
        print(f"\n💰 Configurando preços R$ 40,00 para tamanho MÉDIO...")
        
        # Buscar pizzas da nova categoria
        pizzas_delivery = fazer_request('produtos_produto', metodo='GET',
                                      filtros={'categoria_id': f'eq.{categoria_delivery_id}'})
        
        for pizza in pizzas_delivery:
            try:
                # Verificar se já existe preço para tamanho médio
                precos_existentes = fazer_request('produtos_produtopreco', metodo='GET',
                                                filtros={'produto_id': f'eq.{pizza["id"]}',
                                                       'tamanho_id': f'eq.{tamanho_medio_id}'})
                
                if precos_existentes:
                    # Atualizar preço existente
                    dados_preco = {'preco': 40.00, 'preco_promocional': 40.00}
                    fazer_request('produtos_produtopreco', dados_preco, 'PATCH',
                                filtros={'produto_id': f'eq.{pizza["id"]}',
                                       'tamanho_id': f'eq.{tamanho_medio_id}'})
                    print(f"  ✅ Preço atualizado: {pizza['nome']} - Médio R$ 40,00")
                else:
                    # Criar novo preço
                    dados_preco = {
                        'produto_id': pizza['id'],
                        'tamanho_id': tamanho_medio_id,
                        'preco': 40.00,
                        'preco_promocional': 40.00
                    }
                    fazer_request('produtos_produtopreco', dados_preco)
                    print(f"  ✅ Preço criado: {pizza['nome']} - Médio R$ 40,00")
                
                time.sleep(0.05)
                
            except Exception as e:
                print(f"  ❌ Erro no preço de {pizza['nome']}: {e}")
        
        # 6. VERIFICAÇÃO FINAL
        print(f"\n🔍 VERIFICAÇÃO FINAL...")
        total_delivery = fazer_request('produtos_produto', metodo='GET',
                                     filtros={'categoria_id': f'eq.{categoria_delivery_id}'})
        
        precos_medio = fazer_request('produtos_produtopreco', metodo='GET',
                                   filtros={'tamanho_id': f'eq.{tamanho_medio_id}',
                                          'preco': 'eq.40.0'})
        
        print(f"📊 RESULTADO:")
        print(f"  ✅ Pizzas na categoria Delivery: {len(total_delivery) if total_delivery else 0}")
        print(f"  ✅ Preços R$ 40,00 tamanho médio: {len(precos_medio) if precos_medio else 0}")
        
        print(f"\n🎉 REORGANIZAÇÃO CONCLUÍDA!")
        print(f"💡 Agora as pizzas estão na categoria 'Pizza Delivery'")
        print(f"💡 Preço R$ 40,00 configurado APENAS para tamanho MÉDIO")
        
        if total_delivery:
            print(f"\n🍕 PIZZAS DELIVERY:")
            for pizza in total_delivery[:8]:
                print(f"  • {pizza['nome']}")
            if len(total_delivery) > 8:
                print(f"  ... e mais {len(total_delivery) - 8}")
                
    except Exception as e:
        print(f"❌ ERRO GERAL: {e}")

if __name__ == "__main__":
    main()