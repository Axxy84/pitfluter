#!/usr/bin/env python3
"""
Script Python para deletar automaticamente todas as pizzas com preços incorretos
ATENÇÃO: Este script irá DELETAR dados do banco. Use com cuidado!
"""

from supabase import create_client, Client
import time

# Configurações do Supabase (SUBSTITUA pelas suas configurações)
SUPABASE_URL = "https://your-project.supabase.co"  # MUDE AQUI
SUPABASE_KEY = "your-anon-key"  # MUDE AQUI

def main():
    print("🔥 SCRIPT DE DELEÇÃO AUTOMÁTICA DE PIZZAS")
    print("=" * 60)
    print("⚠️  ATENÇÃO: Este script irá DELETAR pizzas do banco de dados!")
    print("⚠️  Certifique-se de que você quer continuar.")
    print()
    
    try:
        # Conectar ao Supabase
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        
        # 1. BUSCAR TODAS AS PIZZAS
        print("🔍 BUSCANDO TODAS AS PIZZAS NO BANCO...")
        response = supabase.table('produtos_produto').select('*').order('nome').execute()
        produtos = response.data
        
        # Filtrar apenas pizzas
        pizzas = []
        palavras_pizza = [
            'pizza', 'margherita', 'calabresa', 'vegetariana', 'portuguesa',
            'napolitana', 'mozzarella', 'queijo', '4 queijos', 'frango'
        ]
        
        for produto in produtos:
            nome = produto.get('nome', '').lower()
            categoria = produto.get('categoria', '').lower() if produto.get('categoria') else ''
            tipo_produto = produto.get('tipo_produto', '').lower() if produto.get('tipo_produto') else ''
            
            # Verificar se é pizza
            eh_pizza = any(palavra in nome or palavra in categoria or palavra in tipo_produto 
                          for palavra in palavras_pizza)
            
            if eh_pizza:
                pizzas.append(produto)
        
        print(f"🍕 PIZZAS ENCONTRADAS: {len(pizzas)}")
        print("-" * 50)
        
        # 2. LISTAR PIZZAS QUE SERÃO DELETADAS
        if not pizzas:
            print("✅ Nenhuma pizza encontrada para deletar.")
            return
            
        for i, pizza in enumerate(pizzas, 1):
            preco = pizza.get('preco_unitario') or pizza.get('preco') or 0
            print(f"{i:2d}. {pizza['nome']} - R$ {preco}")
        
        print()
        print(f"⚠️  CONFIRME: {len(pizzas)} pizzas serão DELETADAS permanentemente!")
        confirmacao = input("⚠️  Digite 'CONFIRMAR_DELETAR' para continuar ou Enter para cancelar: ")
        
        if confirmacao != 'CONFIRMAR_DELETAR':
            print("❌ OPERAÇÃO CANCELADA pelo usuário.")
            return
        
        # 3. DELETAR TODAS AS PIZZAS
        print("🔥 INICIANDO DELEÇÃO AUTOMÁTICA...")
        print()
        
        deletadas = 0
        erros = 0
        
        for pizza in pizzas:
            try:
                # Deletar pizza
                supabase.table('produtos_produto').delete().eq('id', pizza['id']).execute()
                
                deletadas += 1
                print(f"✅ Deletada: {pizza['nome']}")
                
                # Pequena pausa para não sobrecarregar o banco
                time.sleep(0.1)
                
            except Exception as e:
                erros += 1
                print(f"❌ Erro ao deletar {pizza['nome']}: {e}")
        
        print()
        print("🎯 RESULTADO FINAL:")
        print(f"✅ Pizzas deletadas: {deletadas}")
        print(f"❌ Erros: {erros}")
        print(f"📊 Total processadas: {deletadas + erros}/{len(pizzas)}")
        
        if deletadas > 0:
            print()
            print("🎉 LIMPEZA CONCLUÍDA COM SUCESSO!")
            print("💡 Agora você pode adicionar as pizzas com preços corretos.")
            print("💡 Sugestão: Use um arquivo CSV ou planilha para inserir os dados corretos.")
        
    except Exception as e:
        print(f"❌ ERRO GERAL: {e}")
        print()
        print("💡 DICAS PARA CORRIGIR:")
        print("1. Verifique se SUPABASE_URL e SUPABASE_KEY estão corretos")
        print("2. Instale a biblioteca: pip install supabase")
        print("3. Verifique se a tabela 'produtos_produto' existe")
        print("4. Verifique as permissões de DELETE no Supabase")

if __name__ == "__main__":
    main()