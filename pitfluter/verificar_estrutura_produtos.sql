-- Verificar a estrutura da tabela produtos_produto
-- Execute no Supabase SQL Editor para diagnóstico

-- 1. Ver estrutura da tabela
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'produtos_produto'
ORDER BY ordinal_position;

-- 2. Verificar se existem campos de preço diferentes
SELECT 
    COUNT(*) as total_produtos,
    COUNT(preco_unitario) as produtos_com_preco_unitario,
    COUNT(preco) as produtos_com_preco,
    COUNT(valor) as produtos_com_valor,
    COUNT(price) as produtos_com_price
FROM produtos_produto;

-- 3. Ver amostra de produtos com seus campos
SELECT 
    id,
    nome,
    tipo_produto,
    preco_unitario,
    -- Descomentar se existirem estes campos:
    -- preco,
    -- valor,
    categoria_id,
    criado_em,
    atualizado_em
FROM produtos_produto
LIMIT 10;

-- 4. Verificar se houve alterações recentes na tabela
SELECT 
    id,
    nome,
    preco_unitario,
    atualizado_em
FROM produtos_produto
WHERE atualizado_em > (CURRENT_TIMESTAMP - INTERVAL '7 days')
ORDER BY atualizado_em DESC;

-- 5. Verificar produtos por categoria com preços
SELECT 
    pc.nome as categoria,
    COUNT(pp.id) as total_produtos,
    COUNT(pp.preco_unitario) as produtos_com_preco,
    AVG(pp.preco_unitario) as preco_medio,
    MIN(pp.preco_unitario) as preco_minimo,
    MAX(pp.preco_unitario) as preco_maximo
FROM produtos_categoria pc
LEFT JOIN produtos_produto pp ON pp.categoria_id = pc.id
GROUP BY pc.id, pc.nome
ORDER BY pc.nome;

-- 6. Verificar se existe histórico de auditoria ou backup
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND (table_name LIKE '%audit%' 
       OR table_name LIKE '%backup%' 
       OR table_name LIKE '%historico%'
       OR table_name LIKE '%log%');

-- 7. Verificar triggers na tabela
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE event_object_table = 'produtos_produto';