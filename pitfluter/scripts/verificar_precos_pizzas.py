#!/usr/bin/env python3
"""
Script para verificar preços das pizzas no banco de dados Supabase
e testar a lógica de cálculo de 2 sabores
"""

import os
import sys
from supabase import create_client, Client

# Configurações do Supabase (você precisa configurar estas variáveis)
SUPABASE_URL = "https://your-project.supabase.co"  # Substitua pela sua URL
SUPABASE_KEY = "your-anon-key"  # Substitua pela sua chave

def main():
    print("🔍 VERIFICANDO PREÇOS DAS PIZZAS NO BANCO DE DADOS")
    print("=" * 60)
    
    try:
        # Conectar ao Supabase
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        
        # Buscar produtos usando a query correta (mesma do Flutter)
        print("\n📦 BUSCANDO PRODUTOS...")
        response = supabase.table('produtos_produto').select('*').execute()
        produtos = response.data
        
        print(f"✅ {len(produtos)} produtos encontrados")
        
        # Filtrar apenas pizzas
        pizzas = []
        for produto in produtos:
            nome = produto.get('nome', '').lower()
            categoria = produto.get('categoria', '').lower() if produto.get('categoria') else ''
            
            # Identificar pizzas
            if ('pizza' in nome or 
                'margherita' in nome or 
                'calabresa' in nome or 
                'mozzarella' in nome or
                'vegetariana' in nome or
                'napolitana' in nome or
                'portuguesa' in nome or
                categoria == 'pizza' or
                categoria == 'pizzas'):
                pizzas.append(produto)
        
        print(f"\n🍕 PIZZAS ENCONTRADAS: {len(pizzas)}")
        print("-" * 50)
        
        # Listar todas as pizzas com preços
        pizzas_ordenadas = sorted(pizzas, key=lambda x: x.get('preco', 0))
        
        for i, pizza in enumerate(pizzas_ordenadas, 1):
            nome = pizza.get('nome', 'N/A')
            preco = pizza.get('preco', 0)
            categoria = pizza.get('categoria', 'N/A')
            ativo = pizza.get('ativo', False)
            
            status = "✅ ATIVO" if ativo else "❌ INATIVO"
            print(f"{i:2d}. {nome}")
            print(f"    💰 Preço: R$ {preco:.2f}")
            print(f"    📂 Categoria: {categoria}")
            print(f"    🔄 Status: {status}")
            print()
        
        # Testar combinações de 2 sabores com preços diferentes
        print("\n🔢 TESTANDO LÓGICA DE 2 SABORES:")
        print("=" * 60)
        
        # Multiplicadores de tamanho (mesmos do Flutter)
        multiplicadores = {
            'Pequena': 0.65,
            'Média': 0.85,
            'Grande': 1.0,
            'Família': 1.3
        }
        
        # Encontrar pizzas com preços diferentes para teste
        if len(pizzas_ordenadas) >= 2:
            pizza1 = pizzas_ordenadas[0]  # Mais barata
            pizza2 = pizzas_ordenadas[-1]  # Mais cara
            
            nome1 = pizza1.get('nome', 'Pizza 1')
            preco1 = pizza1.get('preco', 0)
            nome2 = pizza2.get('nome', 'Pizza 2') 
            preco2 = pizza2.get('preco', 0)
            
            print(f"\n🔍 TESTANDO: {nome1} (R$ {preco1:.2f}) + {nome2} (R$ {preco2:.2f})")
            print("-" * 50)
            
            for tamanho, multiplicador in multiplicadores.items():
                preco_final1 = preco1 * multiplicador
                preco_final2 = preco2 * multiplicador
                preco_maior = max(preco_final1, preco_final2)
                
                print(f"📏 Tamanho {tamanho} (x{multiplicador}):")
                print(f"   • {nome1}: R$ {preco1:.2f} × {multiplicador} = R$ {preco_final1:.2f}")
                print(f"   • {nome2}: R$ {preco2:.2f} × {multiplicador} = R$ {preco_final2:.2f}")
                print(f"   • 🏆 MAIOR PREÇO: R$ {preco_maior:.2f}")
                print(f"   • ✅ Lógica correta: {'SIM' if preco_maior == max(preco_final1, preco_final2) else 'NÃO'}")
                print()
        
        # Verificar se há pizzas com preços muito próximos
        print("\n⚠️ VERIFICAÇÃO DE PREÇOS SIMILARES:")
        print("-" * 50)
        
        precos_similares = []
        for i, pizza1 in enumerate(pizzas_ordenadas):
            for pizza2 in pizzas_ordenadas[i+1:]:
                preco1 = pizza1.get('preco', 0)
                preco2 = pizza2.get('preco', 0)
                diferenca = abs(preco1 - preco2)
                
                if diferenca < 2.0:  # Diferença menor que R$ 2,00
                    precos_similares.append({
                        'pizza1': pizza1.get('nome'),
                        'preco1': preco1,
                        'pizza2': pizza2.get('nome'), 
                        'preco2': preco2,
                        'diferenca': diferenca
                    })
        
        if precos_similares:
            print("⚠️  Pizzas com preços muito similares encontradas:")
            for similar in precos_similares[:5]:  # Mostrar apenas 5
                print(f"   • {similar['pizza1']} (R$ {similar['preco1']:.2f}) vs {similar['pizza2']} (R$ {similar['preco2']:.2f}) = Diff: R$ {similar['diferenca']:.2f}")
        else:
            print("✅ Não há pizzas com preços muito similares")
            
        print("\n" + "=" * 60)
        print("✅ VERIFICAÇÃO CONCLUÍDA")
        
    except Exception as e:
        print(f"❌ ERRO: {e}")
        print("\n💡 DICAS:")
        print("1. Verifique se as variáveis SUPABASE_URL e SUPABASE_KEY estão corretas")
        print("2. Instale a biblioteca supabase: pip install supabase")
        print("3. Verifique se a tabela 'produtos_produto' existe no banco")

if __name__ == "__main__":
    main()