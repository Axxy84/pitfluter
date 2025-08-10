#!/usr/bin/env python3
"""
Script simplificado para verificar tamanhos no Supabase usando supabase-py
"""

from supabase import create_client, Client
import json

# Configuração do Supabase
SUPABASE_URL = "https://dcdcgzdjlkbbqkcdpxwa.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRjZGNnemRqbGtiYnFrY2RweHdhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgxNzgxNDcsImV4cCI6MjA0Mzc1NDE0N30.8CglvLj0cs4Fls-K5JCvP4-JkGJ5sv79dOnYfAcY7rs"

def main():
    print("\n" + "="*80)
    print("🔍 VERIFICAÇÃO DE TAMANHOS E PREÇOS NO SUPABASE")
    print("="*80)
    
    # Criar cliente Supabase
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    try:
        # 1. Verificar tamanhos na tabela produtos_tamanho
        print("\n📊 Verificando tabela 'produtos_tamanho':")
        print("-" * 60)
        
        try:
            response = supabase.table('produtos_tamanho').select("*").execute()
            tamanhos = response.data
            
            if tamanhos:
                print(f"✅ Encontrados {len(tamanhos)} tamanhos:")
                for t in tamanhos:
                    print(f"  • ID {t['id']}: {t['nome']}")
            else:
                print("⚠️ Nenhum tamanho encontrado na tabela produtos_tamanho")
        except Exception as e:
            print(f"❌ Erro ao acessar produtos_tamanho: {e}")
            
        # 2. Tentar tabela 'tamanhos'
        print("\n📊 Verificando tabela 'tamanhos':")
        print("-" * 60)
        
        try:
            response = supabase.table('tamanhos').select("*").execute()
            tamanhos = response.data
            
            if tamanhos:
                print(f"✅ Encontrados {len(tamanhos)} tamanhos:")
                for t in tamanhos:
                    print(f"  • ID {t['id']}: {t['nome']}")
            else:
                print("⚠️ Nenhum tamanho encontrado na tabela tamanhos")
        except Exception as e:
            print(f"❌ Erro ao acessar tamanhos: {e}")
        
        # 3. Verificar produtos do tipo pizza
        print("\n🍕 Verificando produtos do tipo pizza:")
        print("-" * 60)
        
        response = supabase.table('produtos').select("id, nome, tipo_produto, preco_unitario").or_("tipo_produto.eq.pizza,nome.ilike.%pizza%").limit(5).execute()
        pizzas = response.data
        
        if pizzas:
            print(f"✅ Encontradas {len(pizzas)} pizzas (mostrando até 5):")
            for p in pizzas:
                print(f"  • {p['nome']} (ID: {p['id']}, Tipo: {p.get('tipo_produto', 'N/A')})")
        else:
            print("⚠️ Nenhuma pizza encontrada")
        
        # 4. Verificar preços por tamanho
        print("\n💰 Verificando preços por tamanho:")
        print("-" * 60)
        
        # Pegar o ID de uma pizza para teste
        if pizzas:
            pizza_id = pizzas[0]['id']
            pizza_nome = pizzas[0]['nome']
            
            print(f"\nTestando com: {pizza_nome} (ID: {pizza_id})")
            
            # Buscar preços desta pizza
            response = supabase.table('produtos_precos').select("*, produtos_tamanho(nome)").eq('produto_id', pizza_id).execute()
            precos = response.data
            
            if precos:
                print(f"  ✅ Preços encontrados:")
                for preco in precos:
                    tamanho_info = preco.get('produtos_tamanho', {})
                    tamanho_nome = tamanho_info.get('nome', 'Desconhecido') if tamanho_info else 'Sem tamanho'
                    print(f"    • Tamanho {tamanho_nome}: R$ {preco['preco']}")
            else:
                print(f"  ⚠️ Nenhum preço por tamanho encontrado para esta pizza")
                
                # Tentar com a tabela 'tamanhos'
                response = supabase.table('produtos_precos').select("*, tamanhos(nome)").eq('produto_id', pizza_id).execute()
                precos = response.data
                
                if precos:
                    print(f"  ✅ Preços encontrados (usando tabela 'tamanhos'):")
                    for preco in precos:
                        tamanho_info = preco.get('tamanhos', {})
                        tamanho_nome = tamanho_info.get('nome', 'Desconhecido') if tamanho_info else 'Sem tamanho'
                        print(f"    • Tamanho {tamanho_nome}: R$ {preco['preco']}")
        
        # 5. Contar total de registros
        print("\n📊 Estatísticas gerais:")
        print("-" * 60)
        
        # Total de produtos
        response = supabase.table('produtos').select("id", count='exact').execute()
        print(f"  • Total de produtos: {response.count}")
        
        # Total de pizzas
        response = supabase.table('produtos').select("id", count='exact').or_("tipo_produto.eq.pizza,nome.ilike.%pizza%").execute()
        print(f"  • Total de pizzas: {response.count}")
        
        # Total de preços
        response = supabase.table('produtos_precos').select("id", count='exact').execute()
        print(f"  • Total de registros de preços: {response.count}")
        
        print("\n" + "="*80)
        print("✅ VERIFICAÇÃO CONCLUÍDA")
        print("="*80)
        
        # Sugestão de correção
        print("\n💡 DIAGNÓSTICO:")
        print("-" * 60)
        print("Se os tamanhos não estão aparecendo no Flutter, verifique:")
        print("1. O nome correto da tabela (produtos_tamanho vs tamanhos)")
        print("2. Se existem registros na tabela de tamanhos")
        print("3. Se os produtos têm preços associados aos tamanhos")
        print("4. Se o código Flutter está usando o nome correto da tabela")
        
    except Exception as e:
        print(f"\n❌ Erro geral: {e}")

if __name__ == "__main__":
    main()