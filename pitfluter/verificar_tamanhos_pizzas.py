#!/usr/bin/env python3
"""
Script para verificar a estrutura de tamanhos e preços de pizzas no Supabase
"""

import psycopg2
from psycopg2 import sql
import json
from tabulate import tabulate

# Configurações de conexão
DB_CONFIG = {
    'host': 'aws-0-sa-east-1.pooler.supabase.com',
    'port': 6543,
    'database': 'postgres',
    'user': 'postgres.dcdcgzdjlkbbqkcdpxwa',
    'password': 'mZkvxD5z#sR:7'
}

def conectar():
    """Estabelece conexão com o banco"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"❌ Erro ao conectar: {e}")
        return None

def verificar_tabelas(conn):
    """Verifica quais tabelas existem relacionadas a produtos e tamanhos"""
    print("\n" + "="*80)
    print("📋 VERIFICANDO TABELAS EXISTENTES")
    print("="*80)
    
    cur = conn.cursor()
    
    # Buscar todas as tabelas que contém 'produto' ou 'tamanho'
    query = """
    SELECT table_name, table_schema
    FROM information_schema.tables
    WHERE table_schema = 'public'
    AND (
        table_name LIKE '%produto%' 
        OR table_name LIKE '%tamanho%'
        OR table_name LIKE '%preco%'
        OR table_name LIKE '%produ%'
    )
    ORDER BY table_name;
    """
    
    cur.execute(query)
    tabelas = cur.fetchall()
    
    print("\nTabelas encontradas:")
    for tabela in tabelas:
        print(f"  • {tabela[0]} (schema: {tabela[1]})")
    
    cur.close()
    return [t[0] for t in tabelas]

def verificar_estrutura_tabela(conn, nome_tabela):
    """Verifica a estrutura de uma tabela específica"""
    print(f"\n📊 Estrutura da tabela '{nome_tabela}':")
    print("-" * 60)
    
    cur = conn.cursor()
    
    query = """
    SELECT 
        column_name,
        data_type,
        character_maximum_length,
        is_nullable,
        column_default
    FROM information_schema.columns
    WHERE table_schema = 'public'
    AND table_name = %s
    ORDER BY ordinal_position;
    """
    
    cur.execute(query, (nome_tabela,))
    colunas = cur.fetchall()
    
    if colunas:
        headers = ['Coluna', 'Tipo', 'Tamanho', 'Nullable', 'Default']
        print(tabulate(colunas, headers=headers, tablefmt='grid'))
    else:
        print(f"  ⚠️ Tabela '{nome_tabela}' não encontrada ou sem colunas")
    
    cur.close()

def verificar_tamanhos(conn):
    """Verifica os tamanhos cadastrados"""
    print("\n" + "="*80)
    print("🍕 TAMANHOS CADASTRADOS")
    print("="*80)
    
    cur = conn.cursor()
    
    # Tentar diferentes nomes de tabela
    tabelas_possiveis = ['tamanhos', 'produtos_tamanho', 'produto_tamanho']
    
    for tabela in tabelas_possiveis:
        try:
            query = f"SELECT * FROM {tabela} ORDER BY id"
            cur.execute(query)
            tamanhos = cur.fetchall()
            
            if tamanhos:
                print(f"\n✅ Tamanhos encontrados na tabela '{tabela}':")
                
                # Obter nomes das colunas
                col_names = [desc[0] for desc in cur.description]
                print(tabulate(tamanhos, headers=col_names, tablefmt='grid'))
                
                print(f"\nTotal: {len(tamanhos)} tamanhos")
                break
        except Exception as e:
            print(f"  ❌ Tabela '{tabela}' não existe ou erro: {str(e)[:50]}")
    
    cur.close()

def verificar_produtos_pizzas(conn):
    """Verifica produtos que são pizzas"""
    print("\n" + "="*80)
    print("🍕 PRODUTOS DO TIPO PIZZA")
    print("="*80)
    
    cur = conn.cursor()
    
    query = """
    SELECT 
        p.id,
        p.nome,
        p.tipo_produto,
        c.nome as categoria,
        p.preco_unitario,
        p.ativo
    FROM produtos p
    LEFT JOIN categorias c ON p.categoria_id = c.id
    WHERE 
        p.tipo_produto = 'pizza'
        OR p.nome ILIKE '%pizza%'
        OR c.nome ILIKE '%pizza%'
    ORDER BY p.nome
    LIMIT 10;
    """
    
    try:
        cur.execute(query)
        pizzas = cur.fetchall()
        
        if pizzas:
            headers = ['ID', 'Nome', 'Tipo', 'Categoria', 'Preço Base', 'Ativo']
            print(tabulate(pizzas, headers=headers, tablefmt='grid'))
            print(f"\n(Mostrando até 10 pizzas)")
        else:
            print("  ⚠️ Nenhuma pizza encontrada")
    except Exception as e:
        print(f"  ❌ Erro ao buscar pizzas: {e}")
    
    cur.close()

def verificar_precos_tamanhos(conn):
    """Verifica a relação entre produtos, preços e tamanhos"""
    print("\n" + "="*80)
    print("💰 PREÇOS POR TAMANHO (PIZZAS)")
    print("="*80)
    
    cur = conn.cursor()
    
    # Primeiro, descobrir o nome correto da tabela de tamanhos
    tabela_tamanho = None
    for nome in ['tamanhos', 'produtos_tamanho', 'produto_tamanho']:
        try:
            cur.execute(f"SELECT 1 FROM {nome} LIMIT 1")
            tabela_tamanho = nome
            break
        except:
            continue
    
    if not tabela_tamanho:
        print("  ❌ Não foi possível encontrar a tabela de tamanhos")
        return
    
    query = f"""
    SELECT 
        p.nome as produto,
        t.nome as tamanho,
        pp.preco,
        pp.preco_promocional
    FROM produtos_precos pp
    JOIN produtos p ON pp.produto_id = p.id
    JOIN {tabela_tamanho} t ON pp.tamanho_id = t.id
    WHERE p.tipo_produto = 'pizza' OR p.nome ILIKE '%pizza%'
    ORDER BY p.nome, t.id
    LIMIT 20;
    """
    
    try:
        cur.execute(query)
        precos = cur.fetchall()
        
        if precos:
            headers = ['Produto', 'Tamanho', 'Preço', 'Preço Promocional']
            print(tabulate(precos, headers=headers, tablefmt='grid'))
            print(f"\n(Mostrando até 20 registros)")
        else:
            print("  ⚠️ Nenhum preço por tamanho encontrado para pizzas")
            
            # Verificar se existem registros na tabela produtos_precos
            cur.execute("SELECT COUNT(*) FROM produtos_precos")
            total = cur.fetchone()[0]
            print(f"  📊 Total de registros em produtos_precos: {total}")
            
    except Exception as e:
        print(f"  ❌ Erro ao buscar preços: {e}")
    
    cur.close()

def verificar_problema_especifico(conn):
    """Verifica especificamente o problema de pizzas sem tamanhos"""
    print("\n" + "="*80)
    print("🔍 DIAGNÓSTICO DO PROBLEMA")
    print("="*80)
    
    cur = conn.cursor()
    
    # 1. Contar pizzas sem preços por tamanho
    query = """
    SELECT 
        COUNT(DISTINCT p.id) as pizzas_sem_preco
    FROM produtos p
    LEFT JOIN produtos_precos pp ON p.id = pp.produto_id
    WHERE 
        (p.tipo_produto = 'pizza' OR p.nome ILIKE '%pizza%')
        AND pp.id IS NULL;
    """
    
    try:
        cur.execute(query)
        resultado = cur.fetchone()
        print(f"\n📊 Pizzas sem preços por tamanho: {resultado[0]}")
    except Exception as e:
        print(f"  ❌ Erro: {e}")
    
    # 2. Listar algumas pizzas sem preços
    query = """
    SELECT 
        p.id,
        p.nome,
        p.tipo_produto,
        p.preco_unitario
    FROM produtos p
    LEFT JOIN produtos_precos pp ON p.id = pp.produto_id
    WHERE 
        (p.tipo_produto = 'pizza' OR p.nome ILIKE '%pizza%')
        AND pp.id IS NULL
    LIMIT 5;
    """
    
    try:
        cur.execute(query)
        pizzas_sem_preco = cur.fetchall()
        
        if pizzas_sem_preco:
            print("\n🚨 Exemplos de pizzas SEM preços por tamanho:")
            headers = ['ID', 'Nome', 'Tipo', 'Preço Unitário']
            print(tabulate(pizzas_sem_preco, headers=headers, tablefmt='grid'))
    except Exception as e:
        print(f"  ❌ Erro: {e}")
    
    # 3. Verificar se a tabela produtos_tamanho tem dados
    for tabela in ['tamanhos', 'produtos_tamanho']:
        try:
            cur.execute(f"SELECT COUNT(*) FROM {tabela}")
            total = cur.fetchone()[0]
            if total > 0:
                print(f"\n✅ Tabela '{tabela}' tem {total} registros")
                
                # Mostrar os tamanhos
                cur.execute(f"SELECT id, nome FROM {tabela} ORDER BY id")
                tamanhos = cur.fetchall()
                print("  Tamanhos disponíveis:")
                for t in tamanhos:
                    print(f"    • ID {t[0]}: {t[1]}")
                break
        except:
            continue
    
    cur.close()

def main():
    """Função principal"""
    print("\n" + "🔧 VERIFICAÇÃO DO BANCO DE DADOS SUPABASE " + "🔧")
    print("="*80)
    
    # Conectar ao banco
    conn = conectar()
    if not conn:
        return
    
    print("✅ Conectado com sucesso!")
    
    try:
        # 1. Verificar tabelas existentes
        tabelas = verificar_tabelas(conn)
        
        # 2. Verificar estrutura das tabelas importantes
        for tabela in ['produtos', 'produtos_precos', 'produtos_tamanho', 'tamanhos']:
            if tabela in tabelas:
                verificar_estrutura_tabela(conn, tabela)
        
        # 3. Verificar tamanhos cadastrados
        verificar_tamanhos(conn)
        
        # 4. Verificar produtos do tipo pizza
        verificar_produtos_pizzas(conn)
        
        # 5. Verificar preços por tamanho
        verificar_precos_tamanhos(conn)
        
        # 6. Diagnóstico específico
        verificar_problema_especifico(conn)
        
        print("\n" + "="*80)
        print("✅ VERIFICAÇÃO CONCLUÍDA")
        print("="*80)
        
    except Exception as e:
        print(f"\n❌ Erro durante verificação: {e}")
    finally:
        conn.close()
        print("\n🔌 Conexão fechada")

if __name__ == "__main__":
    main()