-- =====================================================
-- VERIFICAÇÃO COMPLETA DO SISTEMA PIT STOP PIZZARIA
-- =====================================================

-- 1. VERIFICAR ESTRUTURA DAS TABELAS
-- =====================================================

-- Listar todas as tabelas criadas
SELECT 
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as colunas
FROM information_schema.tables t
WHERE table_schema = 'public'
ORDER BY table_name;

-- 2. VERIFICAR CATEGORIAS
-- =====================================================
SELECT '=== CATEGORIAS ===' as info;
SELECT id, nome, descricao, ordem, ativo, created_at
FROM categorias
ORDER BY ordem, nome;

-- 3. VERIFICAR TAMANHOS
-- =====================================================
SELECT '=== TAMANHOS ===' as info;
SELECT id, nome, descricao, preco_padrao, ordem, ativo
FROM tamanhos
ORDER BY ordem;

-- 4. VERIFICAR PRODUTOS (PIZZAS)
-- =====================================================
SELECT '=== PRODUTOS - PIZZAS ===' as info;
SELECT 
    p.id,
    p.nome,
    c.nome as categoria,
    p.descricao,
    p.tipo_produto,
    p.ativo,
    p.created_at
FROM produtos p
JOIN categorias c ON p.categoria_id = c.id
ORDER BY c.ordem, p.nome;

-- 5. VERIFICAR BORDAS RECHEADAS
-- =====================================================
SELECT '=== BORDAS RECHEADAS ===' as info;
SELECT 
    id,
    nome,
    descricao,
    preco,
    tipo,
    ativo,
    created_at
FROM bordas_recheadas
ORDER BY tipo, nome;

-- 6. VERIFICAR CLIENTES
-- =====================================================
SELECT '=== CLIENTES ===' as info;
SELECT 
    id,
    nome,
    telefone,
    email,
    endereco,
    bairro,
    cidade,
    cep,
    ativo,
    created_at
FROM clientes
ORDER BY nome;

-- 7. VERIFICAR PEDIDOS
-- =====================================================
SELECT '=== PEDIDOS ===' as info;
SELECT 
    p.id,
    p.numero,
    c.nome as cliente,
    p.tipo_pedido,
    p.status,
    p.subtotal,
    p.taxa_entrega,
    p.desconto,
    p.total,
    p.forma_pagamento,
    p.tempo_estimado_minutos,
    p.data_hora_criacao,
    p.data_hora_entrega
FROM pedidos p
JOIN clientes c ON p.cliente_id = c.id
ORDER BY p.data_hora_criacao DESC;

-- 8. VERIFICAR ITENS DOS PEDIDOS
-- =====================================================
SELECT '=== ITENS DOS PEDIDOS ===' as info;
SELECT 
    ip.id,
    p.numero as numero_pedido,
    ip.nome_item,
    ip.quantidade,
    ip.preco_unitario,
    ip.subtotal,
    br.nome as borda_recheada,
    ip.observacoes
FROM itens_pedido ip
JOIN pedidos p ON ip.pedido_id = p.id
LEFT JOIN bordas_recheadas br ON ip.borda_recheada_id = br.id
ORDER BY p.numero, ip.id;

-- 9. RESUMO ESTATÍSTICO
-- =====================================================
SELECT '=== RESUMO ESTATÍSTICO ===' as info;

-- Contagem por categoria
SELECT 
    'Produtos por Categoria' as tipo,
    c.nome as categoria,
    COUNT(p.id) as total
FROM categorias c
LEFT JOIN produtos p ON c.id = p.categoria_id
GROUP BY c.id, c.nome
ORDER BY c.ordem;

-- Contagem de bordas por tipo
SELECT 
    'Bordas por Tipo' as tipo,
    tipo as categoria,
    COUNT(*) as total
FROM bordas_recheadas
GROUP BY tipo
ORDER BY tipo;

-- 10. VERIFICAR RELACIONAMENTOS
-- =====================================================
SELECT '=== RELACIONAMENTOS ===' as info;

-- Verificar chaves estrangeiras
SELECT 
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.column_name;

-- 11. VERIFICAR ÍNDICES
-- =====================================================
SELECT '=== ÍNDICES ===' as info;
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- 12. VERIFICAR TAMANHO DAS TABELAS
-- =====================================================
SELECT '=== TAMANHO DAS TABELAS ===' as info;
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as tamanho,
    pg_total_relation_size(schemaname||'.'||tablename) as tamanho_bytes
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- 13. TESTE DE FUNCIONALIDADE
-- =====================================================
SELECT '=== TESTE DE FUNCIONALIDADE ===' as info;

-- Simular cálculo de preço de uma pizza com borda
SELECT 
    'Simulação de Preço' as teste,
    p.nome as pizza,
    t.preco_padrao as preco_pizza,
    br.nome as borda,
    br.preco as preco_borda,
    (t.preco_padrao + br.preco) as total
FROM produtos p
CROSS JOIN tamanhos t
CROSS JOIN bordas_recheadas br
WHERE p.nome = 'Marguerita' 
    AND br.nome = 'Catupiry'
LIMIT 1;

-- 14. VERIFICAR DADOS DE EXEMPLO
-- =====================================================
SELECT '=== DADOS DE EXEMPLO ===' as info;

-- Primeira pizza de cada categoria
SELECT 
    'Primeira Pizza por Categoria' as tipo,
    c.nome as categoria,
    p.nome as pizza,
    p.descricao
FROM categorias c
JOIN produtos p ON c.id = p.categoria_id
WHERE p.id IN (
    SELECT MIN(id) 
    FROM produtos 
    GROUP BY categoria_id
)
ORDER BY c.ordem;

-- Bordas mais caras e mais baratas
SELECT 
    'Bordas por Preço' as tipo,
    nome,
    preco,
    tipo as categoria_borda
FROM bordas_recheadas
WHERE preco = (SELECT MAX(preco) FROM bordas_recheadas)
   OR preco = (SELECT MIN(preco) FROM bordas_recheadas)
ORDER BY preco DESC;
