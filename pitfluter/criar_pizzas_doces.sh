#!/bin/bash

# Configuração do Supabase
SUPABASE_URL="https://dcdcgzdjlkbbqkcdpxwa.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRjZGNnemRqbGtiYnFrY2RweHdhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgxNzgxNDcsImV4cCI6MjA0Mzc1NDE0N30.8CglvLj0cs4Fls-K5JCvP4-JkGJ5sv79dOnYfAcY7rs"

echo "=========================================="
echo "🍕 VERIFICANDO PIZZAS DOCES NO SUPABASE"
echo "=========================================="

# 1. Verificar pizzas doces existentes
echo -e "\n📊 Buscando pizzas doces..."
curl -s -X GET \
  "${SUPABASE_URL}/rest/v1/produtos?or=(nome.ilike.*doce*,nome.ilike.*chocolate*,nome.ilike.*nutella*,nome.ilike.*brigadeiro*)" \
  -H "apikey: ${SUPABASE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_KEY}" | python3 -m json.tool

# 2. Verificar tamanhos
echo -e "\n📏 Verificando tamanhos..."
curl -s -X GET \
  "${SUPABASE_URL}/rest/v1/produtos_tamanho" \
  -H "apikey: ${SUPABASE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_KEY}" | python3 -m json.tool

# 3. Verificar categoria Pizzas Doces
echo -e "\n📁 Verificando categoria Pizzas Doces..."
curl -s -X GET \
  "${SUPABASE_URL}/rest/v1/categorias?nome=ilike.*doce*" \
  -H "apikey: ${SUPABASE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_KEY}" | python3 -m json.tool

# 4. Criar categoria se não existir
echo -e "\n📁 Criando categoria Pizzas Doces (se não existir)..."
curl -X POST \
  "${SUPABASE_URL}/rest/v1/categorias" \
  -H "apikey: ${SUPABASE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_KEY}" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "nome": "Pizzas Doces",
    "ativo": true
  }'

echo -e "\n\nPara criar pizzas doces manualmente, use os seguintes comandos:"
echo "=========================================="

# Exemplo de comando para criar uma pizza doce
cat << 'EOF'

# Criar Pizza de Chocolate:
curl -X POST \
  "${SUPABASE_URL}/rest/v1/produtos" \
  -H "apikey: ${SUPABASE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_KEY}" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "nome": "Pizza de Chocolate",
    "descricao": "Pizza doce com chocolate ao leite e morangos",
    "categoria_id": [ID_DA_CATEGORIA],
    "tipo_produto": "pizza",
    "preco_unitario": 35.00,
    "ativo": true
  }'

# Criar preços por tamanho (substitua os IDs):
curl -X POST \
  "${SUPABASE_URL}/rest/v1/produtos_precos" \
  -H "apikey: ${SUPABASE_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_KEY}" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "produto_id": [ID_DO_PRODUTO],
    "tamanho_id": [ID_DO_TAMANHO],
    "preco": 30.00,
    "preco_promocional": 30.00
  }'
EOF