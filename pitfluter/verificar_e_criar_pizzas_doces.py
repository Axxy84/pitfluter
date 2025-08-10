#!/usr/bin/env python3
"""
Script para verificar e criar pizzas doces com preços no Supabase
"""

import requests
import json

# Configuração do Supabase
SUPABASE_URL = "https://dcdcgzdjlkbbqkcdpxwa.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRjZGNnemRqbGtiYnFrY2RweHdhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgxNzgxNDcsImV4cCI6MjA0Mzc1NDE0N30.8CglvLj0cs4Fls-K5JCvP4-JkGJ5sv79dOnYfAcY7rs"

headers = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=representation"
}

def fazer_requisicao(endpoint, method="GET", data=None):
    """Faz requisição ao Supabase"""
    url = f"{SUPABASE_URL}/rest/v1/{endpoint}"
    
    if method == "GET":
        response = requests.get(url, headers=headers)
    elif method == "POST":
        response = requests.post(url, headers=headers, json=data)
    elif method == "PATCH":
        response = requests.patch(url, headers=headers, json=data)
    
    return response

def verificar_tabelas():
    """Verifica se as tabelas existem e têm dados"""
    print("\n" + "="*80)
    print("📊 VERIFICANDO TABELAS")
    print("="*80)
    
    # Verificar produtos
    response = fazer_requisicao("produtos?select=count")
    if response.status_code == 200:
        print(f"✅ Tabela 'produtos' acessível")
    else:
        print(f"❌ Erro ao acessar 'produtos': {response.status_code}")
    
    # Verificar categorias
    response = fazer_requisicao("categorias?select=count")
    if response.status_code == 200:
        print(f"✅ Tabela 'categorias' acessível")
    else:
        print(f"❌ Erro ao acessar 'categorias': {response.status_code}")
    
    # Verificar produtos_tamanho
    response = fazer_requisicao("produtos_tamanho?select=count")
    if response.status_code == 200:
        print(f"✅ Tabela 'produtos_tamanho' acessível")
    else:
        print(f"❌ Erro ao acessar 'produtos_tamanho': {response.status_code}")
    
    # Verificar produtos_precos
    response = fazer_requisicao("produtos_precos?select=count")
    if response.status_code == 200:
        print(f"✅ Tabela 'produtos_precos' acessível")
    else:
        print(f"❌ Erro ao acessar 'produtos_precos': {response.status_code}")

def verificar_pizzas_doces():
    """Verifica pizzas doces existentes"""
    print("\n" + "="*80)
    print("🍕 VERIFICANDO PIZZAS DOCES")
    print("="*80)
    
    # Buscar pizzas doces
    response = fazer_requisicao("produtos?nome=ilike.*doce*,nome=ilike.*chocolate*,nome=ilike.*nutella*,nome=ilike.*brigadeiro*&select=id,nome,tipo_produto,preco_unitario")
    
    if response.status_code == 200:
        pizzas = response.json()
        if pizzas:
            print(f"\n✅ Encontradas {len(pizzas)} pizzas doces:")
            for pizza in pizzas:
                print(f"  • ID {pizza['id']}: {pizza['nome']} (R$ {pizza.get('preco_unitario', 0)})")
            return pizzas
        else:
            print("⚠️ Nenhuma pizza doce encontrada")
            return []
    else:
        print(f"❌ Erro ao buscar pizzas doces: {response.status_code}")
        print(f"   Resposta: {response.text}")
        return []

def criar_categoria_pizzas_doces():
    """Cria ou busca categoria de pizzas doces"""
    print("\n" + "="*80)
    print("📁 VERIFICANDO CATEGORIA PIZZAS DOCES")
    print("="*80)
    
    # Verificar se existe
    response = fazer_requisicao("categorias?nome=eq.Pizzas%20Doces&select=id,nome")
    
    if response.status_code == 200:
        categorias = response.json()
        if categorias:
            print(f"✅ Categoria já existe: ID {categorias[0]['id']}")
            return categorias[0]['id']
    
    # Criar nova categoria
    nova_categoria = {
        "nome": "Pizzas Doces",
        "ativo": True
    }
    
    response = fazer_requisicao("categorias", method="POST", data=nova_categoria)
    
    if response.status_code in [200, 201]:
        categoria = response.json()[0] if isinstance(response.json(), list) else response.json()
        print(f"✅ Categoria criada: ID {categoria['id']}")
        return categoria['id']
    else:
        print(f"❌ Erro ao criar categoria: {response.status_code}")
        print(f"   Resposta: {response.text}")
        return None

def criar_tamanhos():
    """Cria tamanhos se não existirem"""
    print("\n" + "="*80)
    print("📏 VERIFICANDO TAMANHOS")
    print("="*80)
    
    # Verificar tamanhos existentes
    response = fazer_requisicao("produtos_tamanho?select=id,nome")
    
    if response.status_code == 200:
        tamanhos_existentes = response.json()
        nomes_existentes = [t['nome'] for t in tamanhos_existentes]
        
        print(f"Tamanhos existentes: {nomes_existentes}")
        
        tamanhos_necessarios = ['P', 'M', 'G', 'GG']
        tamanhos_map = {}
        
        for tamanho_nome in tamanhos_necessarios:
            # Buscar tamanho existente
            tamanho_existe = next((t for t in tamanhos_existentes if t['nome'] == tamanho_nome), None)
            
            if tamanho_existe:
                tamanhos_map[tamanho_nome] = tamanho_existe['id']
                print(f"  ✅ Tamanho {tamanho_nome}: ID {tamanho_existe['id']}")
            else:
                # Criar novo tamanho
                novo_tamanho = {"nome": tamanho_nome}
                response = fazer_requisicao("produtos_tamanho", method="POST", data=novo_tamanho)
                
                if response.status_code in [200, 201]:
                    tamanho_criado = response.json()[0] if isinstance(response.json(), list) else response.json()
                    tamanhos_map[tamanho_nome] = tamanho_criado['id']
                    print(f"  ✅ Tamanho {tamanho_nome} criado: ID {tamanho_criado['id']}")
                else:
                    print(f"  ❌ Erro ao criar tamanho {tamanho_nome}: {response.status_code}")
        
        return tamanhos_map
    else:
        print(f"❌ Erro ao verificar tamanhos: {response.status_code}")
        return {}

def criar_pizzas_doces(categoria_id):
    """Cria pizzas doces se não existirem"""
    print("\n" + "="*80)
    print("🍕 CRIANDO PIZZAS DOCES")
    print("="*80)
    
    pizzas_doces = [
        {"nome": "Pizza de Chocolate", "descricao": "Pizza doce com chocolate ao leite e morangos", "preco": 35.00},
        {"nome": "Pizza de Morango com Nutella", "descricao": "Pizza doce com Nutella e morangos frescos", "preco": 40.00},
        {"nome": "Pizza Romeu e Julieta", "descricao": "Pizza doce com goiabada e queijo", "preco": 35.00},
        {"nome": "Pizza de Banana com Canela", "descricao": "Pizza doce com banana e canela", "preco": 30.00},
        {"nome": "Pizza de Brigadeiro", "descricao": "Pizza doce com brigadeiro e granulado", "preco": 35.00},
        {"nome": "Pizza de Chocolate Branco", "descricao": "Pizza doce com chocolate branco e frutas vermelhas", "preco": 40.00},
        {"nome": "Pizza de Doce de Leite", "descricao": "Pizza doce com doce de leite e coco ralado", "preco": 35.00},
    ]
    
    pizzas_criadas = []
    
    for pizza_info in pizzas_doces:
        # Verificar se já existe
        response = fazer_requisicao(f"produtos?nome=eq.{pizza_info['nome']}&select=id,nome")
        
        if response.status_code == 200:
            pizzas_existentes = response.json()
            
            if pizzas_existentes:
                print(f"  ⚠️ Pizza já existe: {pizza_info['nome']} (ID: {pizzas_existentes[0]['id']})")
                pizzas_criadas.append(pizzas_existentes[0])
            else:
                # Criar nova pizza
                nova_pizza = {
                    "nome": pizza_info['nome'],
                    "descricao": pizza_info['descricao'],
                    "categoria_id": categoria_id,
                    "tipo_produto": "pizza",
                    "preco_unitario": pizza_info['preco'],
                    "ativo": True
                }
                
                response = fazer_requisicao("produtos", method="POST", data=nova_pizza)
                
                if response.status_code in [200, 201]:
                    pizza_criada = response.json()[0] if isinstance(response.json(), list) else response.json()
                    print(f"  ✅ Pizza criada: {pizza_info['nome']} (ID: {pizza_criada['id']})")
                    pizzas_criadas.append(pizza_criada)
                else:
                    print(f"  ❌ Erro ao criar pizza {pizza_info['nome']}: {response.status_code}")
                    print(f"     Resposta: {response.text}")
    
    return pizzas_criadas

def criar_precos_por_tamanho(pizzas, tamanhos_map):
    """Cria preços por tamanho para as pizzas"""
    print("\n" + "="*80)
    print("💰 CRIANDO PREÇOS POR TAMANHO")
    print("="*80)
    
    precos_por_tamanho = {
        'P': 30.00,
        'M': 40.00,
        'G': 50.00,
        'GG': 60.00
    }
    
    for pizza in pizzas:
        print(f"\n📍 Configurando preços para: {pizza['nome']}")
        
        for tamanho_nome, tamanho_id in tamanhos_map.items():
            # Verificar se já existe preço
            response = fazer_requisicao(f"produtos_precos?produto_id=eq.{pizza['id']}&tamanho_id=eq.{tamanho_id}&select=id")
            
            if response.status_code == 200:
                precos_existentes = response.json()
                
                if precos_existentes:
                    print(f"  ⚠️ Preço já existe para tamanho {tamanho_nome}")
                else:
                    # Criar novo preço
                    novo_preco = {
                        "produto_id": pizza['id'],
                        "tamanho_id": tamanho_id,
                        "preco": precos_por_tamanho[tamanho_nome],
                        "preco_promocional": precos_por_tamanho[tamanho_nome]
                    }
                    
                    response = fazer_requisicao("produtos_precos", method="POST", data=novo_preco)
                    
                    if response.status_code in [200, 201]:
                        print(f"  ✅ Preço criado: Tamanho {tamanho_nome} = R$ {precos_por_tamanho[tamanho_nome]}")
                    else:
                        print(f"  ❌ Erro ao criar preço para tamanho {tamanho_nome}: {response.status_code}")

def verificar_resultado_final():
    """Verifica o resultado final"""
    print("\n" + "="*80)
    print("🔍 VERIFICAÇÃO FINAL")
    print("="*80)
    
    # Buscar pizzas doces com preços
    response = fazer_requisicao("produtos?nome=ilike.*doce*,nome=ilike.*chocolate*,nome=ilike.*nutella*,nome=ilike.*brigadeiro*&select=id,nome,produtos_precos(preco,produtos_tamanho(nome))")
    
    if response.status_code == 200:
        pizzas = response.json()
        
        for pizza in pizzas:
            precos = pizza.get('produtos_precos', [])
            if precos:
                print(f"\n✅ {pizza['nome']}:")
                for preco in precos:
                    tamanho = preco.get('produtos_tamanho', {}).get('nome', 'N/A')
                    valor = preco.get('preco', 0)
                    print(f"  • Tamanho {tamanho}: R$ {valor}")
            else:
                print(f"\n⚠️ {pizza['nome']}: SEM PREÇOS POR TAMANHO")
    else:
        print(f"❌ Erro na verificação final: {response.status_code}")

def main():
    print("\n" + "🍕 CONFIGURAÇÃO DE PIZZAS DOCES NO SUPABASE 🍕")
    print("="*80)
    
    # 1. Verificar tabelas
    verificar_tabelas()
    
    # 2. Criar ou buscar categoria
    categoria_id = criar_categoria_pizzas_doces()
    
    if not categoria_id:
        print("\n❌ Não foi possível criar/encontrar categoria. Abortando.")
        return
    
    # 3. Criar tamanhos
    tamanhos_map = criar_tamanhos()
    
    if not tamanhos_map:
        print("\n❌ Não foi possível criar/verificar tamanhos. Abortando.")
        return
    
    # 4. Criar pizzas doces
    pizzas = criar_pizzas_doces(categoria_id)
    
    # 5. Buscar pizzas doces existentes (caso já existam)
    pizzas_existentes = verificar_pizzas_doces()
    
    # Combinar listas
    todas_pizzas = pizzas + [p for p in pizzas_existentes if p['id'] not in [pizza['id'] for pizza in pizzas]]
    
    if todas_pizzas:
        # 6. Criar preços por tamanho
        criar_precos_por_tamanho(todas_pizzas, tamanhos_map)
    
    # 7. Verificar resultado
    verificar_resultado_final()
    
    print("\n" + "="*80)
    print("✅ PROCESSO CONCLUÍDO!")
    print("="*80)

if __name__ == "__main__":
    main()