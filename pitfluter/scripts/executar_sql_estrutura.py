#!/usr/bin/env python3
"""
Script para executar o SQL de criação das tabelas no novo banco Supabase
"""

from supabase import create_client, Client

# Configurações do NOVO banco Supabase
SUPABASE_URL = "https://lhvfacztsbflrtfibeek.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo"

def main():
    print("🚀 EXECUTANDO SQL NO NOVO BANCO SUPABASE")
    print("=" * 60)
    print("📋 Estrutura que será criada:")
    print("   ✅ produtos_categoria (5 categorias)")
    print("   ✅ produtos_tamanho (5 tamanhos)")
    print("   ✅ produtos_produto (16 pizzas)")
    print("   ✅ produtos_produtopreco (preços por tamanho)")
    print()
    
    try:
        # Conectar ao Supabase
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        
        print("🔍 TESTANDO CONEXÃO...")
        # Testar conexão simples
        test_response = supabase.table('_test_connection').select('*').limit(1).execute()
        print("✅ Conexão com Supabase funcionando!")
        
    except Exception as e:
        if "table" in str(e).lower() and "not found" in str(e).lower():
            print("✅ Conexão OK (tabela de teste não existe, como esperado)")
        else:
            print(f"❌ Erro de conexão: {e}")
            return
    
    print()
    print("⚠️  IMPORTANTE:")
    print("   📝 O SQL deve ser executado MANUALMENTE no painel do Supabase")
    print("   🌐 Acesse: https://lhvfacztsbflrtfibeek.supabase.co/project/default/sql")
    print("   📄 Copie o conteúdo do arquivo: scripts/criar_estrutura_banco.sql")
    print("   ▶️  Execute o SQL no editor do Supabase")
    print()
    
    print("🔧 PASSOS PARA EXECUTAR:")
    print("1. Abra o Supabase Dashboard")
    print("2. Vá em 'SQL Editor' no menu lateral")
    print("3. Cole o SQL do arquivo criar_estrutura_banco.sql")
    print("4. Clique em 'Run' para executar")
    print("5. Volte aqui e execute o teste")
    print()
    
    input("⏸️  Pressione Enter após executar o SQL no Supabase...")
    
    # Testar se as tabelas foram criadas
    print("🔍 VERIFICANDO ESTRUTURA CRIADA...")
    
    try:
        # Testar categorias
        categorias = supabase.table('produtos_categoria').select('*').execute()
        print(f"✅ produtos_categoria: {len(categorias.data)} registros")
        
        # Testar tamanhos
        tamanhos = supabase.table('produtos_tamanho').select('*').execute()
        print(f"✅ produtos_tamanho: {len(tamanhos.data)} registros")
        
        # Testar produtos
        produtos = supabase.table('produtos_produto').select('*').execute()
        print(f"✅ produtos_produto: {len(produtos.data)} registros")
        
        # Testar preços
        precos = supabase.table('produtos_produtopreco').select('*').execute()
        print(f"✅ produtos_produtopreco: {len(precos.data)} registros")
        
        print()
        print("🎉 ESTRUTURA CRIADA COM SUCESSO!")
        print("💡 Agora teste o app Flutter para ver as pizzas carregando")
        
        # Mostrar algumas pizzas como exemplo
        print()
        print("🍕 PIZZAS INSERIDAS:")
        for i, produto in enumerate(produtos.data[:5], 1):
            print(f"   {i}. {produto['nome']} - {produto['descricao']}")
        if len(produtos.data) > 5:
            print(f"   ... e mais {len(produtos.data) - 5} pizzas")
            
    except Exception as e:
        print(f"❌ Erro ao verificar tabelas: {e}")
        print()
        print("💡 Possíveis soluções:")
        print("1. Verifique se executou o SQL corretamente no Supabase")
        print("2. Verifique se não houve erros no SQL Editor")
        print("3. Tente executar as queries uma por vez")

if __name__ == "__main__":
    main()