-- =====================================================
-- SCRIPT COMPLETO DE VERIFICAÇÃO DO BANCO DE DADOS
-- =====================================================

-- 1. ESTRUTURA DAS TABELAS
-- =====================================================
\echo '========== ESTRUTURA DAS TABELAS =========='

-- 1.1 Estrutura da tabela categorias
\echo '\n>>> Tabela CATEGORIAS:'
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'categorias'
ORDER BY ordinal_position;

-- 1.2 Estrutura da tabela produtos
\echo '\n>>> Tabela PRODUTOS:'
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'produtos'
ORDER BY ordinal_position;

-- 1.3 Estrutura da tabela tamanhos
\echo '\n>>> Tabela TAMANHOS:'
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'tamanhos'
ORDER BY ordinal_position;

-- 1.4 Estrutura da tabela produtos_precos
\echo '\n>>> Tabela PRODUTOS_PRECOS:'
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'produtos_precos'
ORDER BY ordinal_position;

-- 2. DADOS DAS CATEGORIAS
-- =====================================================
\echo '\n========== CATEGORIAS EXISTENTES =========='
SELECT 
    id,
    nome,
    ativo,
    CASE 
        WHEN nome ILIKE '%pizza%' THEN '🍕 PIZZA'
        WHEN nome ILIKE '%doce%' THEN '🍰 DOCE'
        WHEN nome ILIKE '%bebida%' THEN '🥤 BEBIDA'
        WHEN nome ILIKE '%borda%' THEN '🔄 BORDA'
        ELSE '❓ OUTRO'
    END as tipo_detectado
FROM categorias
ORDER BY nome;

-- 3. TAMANHOS DISPONÍVEIS
-- =====================================================
\echo '\n========== TAMANHOS CADASTRADOS =========='
SELECT 
    id,
    nome,
    CASE 
        WHEN nome IN ('P', 'M', 'G', 'GG', 'Família') THEN '✅ PADRÃO'
        ELSE '⚠️ CUSTOM'
    END as status
FROM tamanhos
ORDER BY id;

-- 4. ANÁLISE DE PRODUTOS - TODAS AS PIZZAS
-- =====================================================
\echo '\n========== TODAS AS PIZZAS (por nome) =========='
SELECT 
    p.id,
    p.nome,
    p.tipo_produto,
    c.nome as categoria,
    p.preco_unitario,
    p.ativo,
    CASE 
        WHEN p.nome ILIKE '%chocolate%' OR 
             p.nome ILIKE '%nutella%' OR 
             p.nome ILIKE '%brigadeiro%' OR
             p.nome ILIKE '%romeu%' OR
             p.nome ILIKE '%morango%' OR
             p.nome ILIKE '%banana%' OR
             p.nome ILIKE '%doce%' 
        THEN '🍫 DOCE'
        ELSE '🧄 SALGADA'
    END as tipo_pizza
FROM produtos p
LEFT JOIN categorias c ON p.categoria_id = c.id
WHERE p.nome ILIKE '%pizza%'
ORDER BY tipo_pizza DESC, p.nome;

-- 5. PRODUTOS QUE PARECEM PIZZAS DOCES (mas podem não estar marcados)
-- =====================================================
\echo '\n========== POSSÍVEIS PIZZAS DOCES =========='
SELECT 
    p.id,
    p.nome,
    p.tipo_produto,
    c.nome as categoria,
    p.preco_unitario,
    p.ativo,
    CASE 
        WHEN p.tipo_produto = 'pizza' THEN '✅'
        ELSE '❌'
    END as tipo_correto,
    CASE 
        WHEN p.nome ILIKE '%pizza%' THEN '✅'
        ELSE '❌'
    END as tem_pizza_nome
FROM produtos p
LEFT JOIN categorias c ON p.categoria_id = c.id
WHERE 
    p.nome ILIKE '%chocolate%' OR
    p.nome ILIKE '%nutella%' OR
    p.nome ILIKE '%brigadeiro%' OR
    p.nome ILIKE '%romeu%' OR
    p.nome ILIKE '%morango%' OR
    p.nome ILIKE '%banana%' OR
    p.nome ILIKE '%prestígio%' OR
    p.nome ILIKE '%doce%'
ORDER BY p.nome;

-- 6. ANÁLISE DE PREÇOS POR TAMANHO
-- =====================================================
\echo '\n========== PREÇOS DAS PIZZAS DOCES =========='
SELECT 
    p.nome as pizza,
    t.nome as tamanho,
    pp.preco,
    pp.preco_promocional,
    CASE 
        WHEN pp.id IS NULL THEN '❌ SEM PREÇO'
        ELSE '✅ OK'
    END as status
FROM produtos p
CROSS JOIN tamanhos t
LEFT JOIN produtos_precos pp ON pp.produto_id = p.id AND pp.tamanho_id = t.id
WHERE 
    p.nome ILIKE '%pizza%' AND
    (p.nome ILIKE '%chocolate%' OR
     p.nome ILIKE '%nutella%' OR
     p.nome ILIKE '%brigadeiro%' OR
     p.nome ILIKE '%romeu%' OR
     p.nome ILIKE '%morango%' OR
     p.nome ILIKE '%doce%')
    AND t.nome IN ('P', 'M', 'G', 'GG')
ORDER BY p.nome, t.id;

-- 7. CONTAGEM E ESTATÍSTICAS
-- =====================================================
\echo '\n========== ESTATÍSTICAS =========='
SELECT 
    'Total de Categorias' as metrica,
    COUNT(*) as quantidade
FROM categorias
WHERE ativo = true

UNION ALL

SELECT 
    'Categorias de Pizza' as metrica,
    COUNT(*) as quantidade
FROM categorias
WHERE nome ILIKE '%pizza%' AND ativo = true

UNION ALL

SELECT 
    'Total de Produtos' as metrica,
    COUNT(*) as quantidade
FROM produtos
WHERE ativo = true

UNION ALL

SELECT 
    'Produtos tipo "pizza"' as metrica,
    COUNT(*) as quantidade
FROM produtos
WHERE tipo_produto = 'pizza' AND ativo = true

UNION ALL

SELECT 
    'Produtos com "pizza" no nome' as metrica,
    COUNT(*) as quantidade
FROM produtos
WHERE nome ILIKE '%pizza%' AND ativo = true

UNION ALL

SELECT 
    'Pizzas Doces (por nome)' as metrica,
    COUNT(*) as quantidade
FROM produtos
WHERE nome ILIKE '%pizza%' 
  AND (nome ILIKE '%chocolate%' OR
       nome ILIKE '%nutella%' OR
       nome ILIKE '%brigadeiro%' OR
       nome ILIKE '%doce%')
  AND ativo = true

UNION ALL

SELECT 
    'Tamanhos cadastrados' as metrica,
    COUNT(*) as quantidade
FROM tamanhos

UNION ALL

SELECT 
    'Registros em produtos_precos' as metrica,
    COUNT(*) as quantidade
FROM produtos_precos;

-- 8. PRODUTOS SEM CATEGORIA
-- =====================================================
\echo '\n========== PRODUTOS SEM CATEGORIA =========='
SELECT 
    id,
    nome,
    tipo_produto,
    preco_unitario,
    ativo
FROM produtos
WHERE categoria_id IS NULL
ORDER BY nome;

-- 9. PRODUTOS SEM PREÇOS POR TAMANHO
-- =====================================================
\echo '\n========== PIZZAS SEM PREÇOS COMPLETOS =========='
SELECT 
    p.id,
    p.nome,
    COUNT(pp.id) as qtd_precos,
    4 - COUNT(pp.id) as faltando,
    STRING_AGG(t.nome, ', ' ORDER BY t.nome) as tamanhos_com_preco
FROM produtos p
LEFT JOIN produtos_precos pp ON pp.produto_id = p.id
LEFT JOIN tamanhos t ON pp.tamanho_id = t.id
WHERE p.tipo_produto = 'pizza' OR p.nome ILIKE '%pizza%'
GROUP BY p.id, p.nome
HAVING COUNT(pp.id) < 4
ORDER BY COUNT(pp.id), p.nome;

-- 10. DIAGNÓSTICO FINAL
-- =====================================================
\echo '\n========== DIAGNÓSTICO FINAL =========='
\echo 'Execute os comandos de correção abaixo se necessário:'
\echo ''

-- Sugestões de correção
SELECT 
    'UPDATE produtos SET tipo_produto = ''pizza'' WHERE nome ILIKE ''%pizza%'' AND tipo_produto != ''pizza'';' as comando_correcao
WHERE EXISTS (
    SELECT 1 FROM produtos 
    WHERE nome ILIKE '%pizza%' AND tipo_produto != 'pizza'
)

UNION ALL

SELECT 
    'INSERT INTO categorias (nome, ativo) VALUES (''Pizzas Doces'', true);' as comando_correcao
WHERE NOT EXISTS (
    SELECT 1 FROM categorias 
    WHERE nome = 'Pizzas Doces'
)

UNION ALL

SELECT 
    'INSERT INTO tamanhos (nome) VALUES (''P''), (''M''), (''G''), (''GG'');' as comando_correcao
WHERE (SELECT COUNT(*) FROM tamanhos WHERE nome IN ('P', 'M', 'G', 'GG')) < 4;