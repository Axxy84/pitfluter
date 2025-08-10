#!/bin/bash

echo "===================================================="
echo "     CRIANDO PIZZAS DOCES VIA API SUPABASE"
echo "===================================================="
echo ""

SUPABASE_URL="https://dcdcgzdjlkbbqkcdpxwa.supabase.co"
SUPABASE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRjZGNnemRqbGtiYnFrY2RweHdhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgxNzgxNDcsImV4cCI6MjA0Mzc1NDE0N30.8CglvLj0cs4Fls-K5JCvP4-JkGJ5sv79dOnYfAcY7rs"

# Testar conexão
echo "1. Testando conexão com Supabase..."
curl -s -o /dev/null -w "%{http_code}" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  "$SUPABASE_URL/rest/v1/produtos?limit=1"

if [ $? -eq 0 ]; then
  echo "   ✅ Conexão OK"
else
  echo "   ❌ Erro de conexão"
  exit 1
fi

echo ""
echo "2. Verificando pizzas doces existentes..."
echo ""

# Buscar pizzas doces
PIZZAS=$(curl -s \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  "$SUPABASE_URL/rest/v1/produtos?or=(nome.ilike.*doce*,nome.ilike.*chocolate*,nome.ilike.*brigadeiro*)")

echo "Resposta da API:"
echo "$PIZZAS" | head -c 500
echo ""
echo ""

# Verificar categoria
echo "3. Verificando categoria 'Pizzas Doces'..."
CATEGORIA=$(curl -s \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  "$SUPABASE_URL/rest/v1/categorias?nome=eq.Pizzas%20Doces")

echo "Resposta: $CATEGORIA"
echo ""

# Se categoria não existe, criar
if [ "$CATEGORIA" = "[]" ]; then
  echo "4. Criando categoria 'Pizzas Doces'..."
  NOVA_CATEGORIA=$(curl -s -X POST \
    -H "apikey: $SUPABASE_KEY" \
    -H "Authorization: Bearer $SUPABASE_KEY" \
    -H "Content-Type: application/json" \
    -H "Prefer: return=representation" \
    -d '{"nome": "Pizzas Doces", "ativo": true}' \
    "$SUPABASE_URL/rest/v1/categorias")
  
  echo "Categoria criada: $NOVA_CATEGORIA"
else
  echo "   ✅ Categoria já existe"
fi

echo ""
echo "===================================================="
echo "Para criar uma pizza doce manualmente, use:"
echo ""
echo 'curl -X POST \'
echo '  -H "apikey: SEU_KEY" \'
echo '  -H "Authorization: Bearer SEU_KEY" \'
echo '  -H "Content-Type: application/json" \'
echo '  -H "Prefer: return=representation" \'
echo '  -d '"'"'{"nome": "Pizza de Chocolate", "tipo_produto": "pizza", "preco_unitario": 35}'"'"' \'
echo '  https://SEU_URL.supabase.co/rest/v1/produtos'
echo "====================================================="