-- =====================================================
-- ANÁLISE DETALHADA DA TABELA PRODUTOS_PRECOS
-- =====================================================

-- 1. ESTRUTURA DA TABELA PRODUTOS_PRECOS
-- =====================================================
\echo '========== ESTRUTURA DA TABELA PRODUTOS_PRECOS =========='
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'produtos_precos'
ORDER BY ordinal_position;

-- 2. CONTAGEM DE PRODUTOS ÚNICOS EM PRODUTOS_PRECOS
-- =====================================================
\echo '\n========== ANÁLISE 1: PRODUTOS ÚNICOS EM PRODUTOS_PRECOS =========='
SELECT 
    'Produtos únicos em produtos_precos' as metrica,
    COUNT(DISTINCT produto_id) as quantidade
FROM produtos_precos;

-- 3. CONTAGEM DE TAMANHOS ÚNICOS EM PRODUTOS_PRECOS
-- =====================================================
\echo '\n========== ANÁLISE 2: TAMANHOS ÚNICOS EM PRODUTOS_PRECOS =========='
SELECT 
    'Tamanhos únicos em produtos_precos' as metrica,
    COUNT(DISTINCT tamanho_id) as quantidade
FROM produtos_precos;

-- 4. TOTAL DE REGISTROS EM PRODUTOS_PRECOS
-- =====================================================
\echo '\n========== ANÁLISE 3: TOTAL DE REGISTROS =========='
SELECT 
    'Total de registros em produtos_precos' as metrica,
    COUNT(*) as quantidade
FROM produtos_precos;

-- 5. DETALHES DOS TAMANHOS UTILIZADOS
-- =====================================================
\echo '\n========== ANÁLISE 4: DETALHES DOS TAMANHOS =========='
SELECT 
    t.id,
    t.nome as tamanho,
    COUNT(pp.id) as qtd_produtos_com_este_tamanho,
    ROUND(AVG(pp.preco), 2) as preco_medio,
    MIN(pp.preco) as preco_minimo,
    MAX(pp.preco) as preco_maximo
FROM tamanhos t
LEFT JOIN produtos_precos pp ON t.id = pp.tamanho_id
GROUP BY t.id, t.nome
ORDER BY t.id;

-- 6. SAMPLE DE REGISTROS DA TABELA PRODUTOS_PRECOS
-- =====================================================
\echo '\n========== ANÁLISE 5: SAMPLE DE REGISTROS (primeiros 10) =========='
SELECT 
    pp.id,
    pp.produto_id,
    p.nome as produto_nome,
    pp.tamanho_id,
    t.nome as tamanho_nome,
    pp.preco,
    pp.preco_promocional,
    pp.ativo
FROM produtos_precos pp
LEFT JOIN produtos p ON pp.produto_id = p.id
LEFT JOIN tamanhos t ON pp.tamanho_id = t.id
ORDER BY pp.id
LIMIT 10;

-- 7. VERIFICAÇÃO DE DUPLICATAS
-- =====================================================
\echo '\n========== ANÁLISE 6: VERIFICAÇÃO DE DUPLICATAS =========='
SELECT 
    produto_id,
    tamanho_id,
    COUNT(*) as qtd_registros_duplicados
FROM produtos_precos
GROUP BY produto_id, tamanho_id
HAVING COUNT(*) > 1
ORDER BY qtd_registros_duplicados DESC;

-- 8. PRODUTOS COM MAIS/MENOS TAMANHOS
-- =====================================================
\echo '\n========== ANÁLISE 7: PRODUTOS COM MAIS/MENOS TAMANHOS =========='
SELECT 
    p.id,
    p.nome as produto_nome,
    p.tipo_produto,
    COUNT(pp.id) as qtd_tamanhos,
    STRING_AGG(t.nome, ', ' ORDER BY t.nome) as tamanhos_disponiveis
FROM produtos p
LEFT JOIN produtos_precos pp ON p.id = pp.produto_id
LEFT JOIN tamanhos t ON pp.tamanho_id = t.id
GROUP BY p.id, p.nome, p.tipo_produto
ORDER BY COUNT(pp.id) DESC, p.nome
LIMIT 20;

-- 9. PRODUTOS SEM NENHUM PREÇO CONFIGURADO
-- =====================================================
\echo '\n========== ANÁLISE 8: PRODUTOS SEM PREÇOS CONFIGURADOS =========='
SELECT 
    p.id,
    p.nome,
    p.tipo_produto,
    c.nome as categoria,
    p.preco_unitario,
    p.ativo
FROM produtos p
LEFT JOIN produtos_precos pp ON p.id = pp.produto_id
LEFT JOIN categorias c ON p.categoria_id = c.id
WHERE pp.id IS NULL
ORDER BY p.nome;

-- 10. COMPARAÇÃO: PRODUTOS vs PRODUTOS_PRECOS
-- =====================================================
\echo '\n========== ANÁLISE 9: COMPARAÇÃO PRODUTOS vs PRODUTOS_PRECOS =========='
SELECT 
    'Total de produtos ativos' as metrica,
    COUNT(*) as quantidade
FROM produtos
WHERE ativo = true

UNION ALL

SELECT 
    'Total de produtos em produtos_precos' as metrica,
    COUNT(DISTINCT produto_id) as quantidade
FROM produtos_precos

UNION ALL

SELECT 
    'Produtos que NÃO estão em produtos_precos' as metrica,
    COUNT(*) as quantidade
FROM produtos p
LEFT JOIN produtos_precos pp ON p.id = pp.produto_id
WHERE pp.id IS NULL AND p.ativo = true

UNION ALL

SELECT 
    'Total de tamanhos cadastrados' as metrica,
    COUNT(*) as quantidade
FROM tamanhos

UNION ALL

SELECT 
    'Total de tamanhos usados em produtos_precos' as metrica,
    COUNT(DISTINCT tamanho_id) as quantidade
FROM produtos_precos;

-- 11. CÁLCULO TEÓRICO vs REAL
-- =====================================================
\echo '\n========== ANÁLISE 10: CÁLCULO TEÓRICO vs REAL =========='
WITH stats AS (
    SELECT 
        (SELECT COUNT(DISTINCT produto_id) FROM produtos_precos) as produtos_com_preco,
        (SELECT COUNT(DISTINCT tamanho_id) FROM produtos_precos) as tamanhos_usados,
        (SELECT COUNT(*) FROM produtos_precos) as total_registros
)
SELECT 
    produtos_com_preco,
    tamanhos_usados,
    produtos_com_preco * tamanhos_usados as teorico_maximo,
    total_registros as real_atual,
    total_registros - (produtos_com_preco * tamanhos_usados) as diferenca,
    ROUND((total_registros::decimal / (produtos_com_preco * tamanhos_usados) * 100), 2) as percentual_preenchimento
FROM stats;

-- 12. PRODUTOS POR TIPO COM CONTAGEM DE PREÇOS
-- =====================================================
\echo '\n========== ANÁLISE 11: PRODUTOS POR TIPO COM PREÇOS =========='
SELECT 
    COALESCE(p.tipo_produto, 'SEM_TIPO') as tipo_produto,
    COUNT(DISTINCT p.id) as qtd_produtos_tipo,
    COUNT(pp.id) as qtd_precos_configurados,
    ROUND(AVG(COUNT(pp.id)) OVER (PARTITION BY p.tipo_produto), 2) as media_precos_por_produto
FROM produtos p
LEFT JOIN produtos_precos pp ON p.id = pp.produto_id
WHERE p.ativo = true
GROUP BY p.tipo_produto
ORDER BY qtd_precos_configurados DESC;

-- 13. ANÁLISE DE PREÇOS POR FAIXA
-- =====================================================
\echo '\n========== ANÁLISE 12: DISTRIBUIÇÃO DE PREÇOS =========='
SELECT 
    CASE 
        WHEN preco < 10 THEN '0-10'
        WHEN preco < 20 THEN '10-20'
        WHEN preco < 30 THEN '20-30'
        WHEN preco < 40 THEN '30-40'
        WHEN preco < 50 THEN '40-50'
        ELSE '50+'
    END as faixa_preco,
    COUNT(*) as quantidade_registros,
    ROUND(AVG(preco), 2) as preco_medio_faixa
FROM produtos_precos
GROUP BY 
    CASE 
        WHEN preco < 10 THEN '0-10'
        WHEN preco < 20 THEN '10-20'
        WHEN preco < 30 THEN '20-30'
        WHEN preco < 40 THEN '30-40'
        WHEN preco < 50 THEN '40-50'
        ELSE '50+'
    END
ORDER BY 
    CASE 
        WHEN preco < 10 THEN 1
        WHEN preco < 20 THEN 2
        WHEN preco < 30 THEN 3
        WHEN preco < 40 THEN 4
        WHEN preco < 50 THEN 5
        ELSE 6
    END;

\echo '\n========== RESUMO FINAL =========='
\echo 'Esta análise mostra:'
\echo '1. Quantos produtos únicos têm preços configurados'
\echo '2. Quantos tamanhos diferentes são utilizados'
\echo '3. Se existem duplicatas na tabela'
\echo '4. Como o total de 524 registros se relaciona com produtos × tamanhos'
\echo '5. Quais produtos não têm preços configurados'
\echo '6. A distribuição dos preços'