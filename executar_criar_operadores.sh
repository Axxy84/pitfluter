#!/bin/bash

# Configurações do Supabase
SUPABASE_URL="https://lhvfacztsbflrtfibeek.supabase.co"
SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodmZhY3p0c2JmbHJ0ZmliZWVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0MzQzMzcsImV4cCI6MjA3MDAxMDMzN30.wB90XIx4AEF9DORBPtWHBTyM7cVcpXyLSuafxYh0LBo"

echo "CRIANDO TABELA DE OPERADORES NO SUPABASE"
echo "========================================"

# Função para criar tabela operadores via RPC (se disponível)
echo "1. Tentando criar tabela via RPC..."

# Como não temos acesso direto ao SQL, vamos usar inserções API para simular
echo "2. Criando dados básicos via API REST..."

# Verificar se a tabela já existe
response=$(curl -s -w "%{http_code}" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    "${SUPABASE_URL}/rest/v1/operadores?limit=1" \
    -o /dev/null)

case $response in
    200)
        echo "✅ Tabela 'operadores' já existe"
        ;;
    404)
        echo "❌ Tabela 'operadores' não existe"
        echo "⚠️  A tabela precisa ser criada diretamente no painel do Supabase"
        echo "   Execute o SQL contido em: criar_tabela_operadores.sql"
        exit 1
        ;;
    *)
        echo "❓ Status desconhecido: $response"
        exit 1
        ;;
esac

# Testar inserção de um operador de teste
echo
echo "3. Testando inserção de operador..."

operador_teste='{
    "nome": "Operador Teste",
    "nivel_acesso": "operador",
    "ativo": true,
    "observacoes": "Operador de teste criado via script"
}'

insert_response=$(curl -s -w "%{http_code}" \
    -X POST \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    -H "Content-Type: application/json" \
    -d "$operador_teste" \
    "${SUPABASE_URL}/rest/v1/operadores" \
    -o /tmp/insert_result.json)

if [ "$insert_response" = "201" ]; then
    echo "✅ Operador de teste inserido com sucesso"
    cat /tmp/insert_result.json | jq . 2>/dev/null || cat /tmp/insert_result.json
else
    echo "❌ Erro ao inserir operador de teste (Status: $insert_response)"
    cat /tmp/insert_result.json 2>/dev/null || echo "Sem detalhes do erro"
fi

echo
echo "4. Listando operadores existentes..."

curl -s -H "apikey: $SUPABASE_ANON_KEY" \
     -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
     "${SUPABASE_URL}/rest/v1/operadores?select=id,nome,nivel_acesso,ativo" | \
     jq -r '.[] | "ID: \(.id) | Nome: \(.nome) | Nível: \(.nivel_acesso) | Ativo: \(.ativo)"' 2>/dev/null || \
     echo "Erro ao listar operadores"

echo
echo "CONCLUÍDO!"