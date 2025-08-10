-- VERIFICAÇÃO COMPLETA DAS PIZZAS DOCES

-- 1. Verificar todas as categorias
SELECT id, nome, ativo 
FROM categorias 
ORDER BY nome;

-- 2. Verificar produtos que parecem ser pizzas doces
SELECT 
    p.id,
    p.nome,
    p.categoria_id,
    c.nome as categoria_nome,
    p.tipo_produto,
    p.preco_unitario,
    p.ativo
FROM produtos p
LEFT JOIN categorias c ON p.categoria_id = c.id
WHERE 
    p.nome ILIKE '%chocolate%' OR
    p.nome ILIKE '%nutella%' OR
    p.nome ILIKE '%brigadeiro%' OR
    p.nome ILIKE '%romeu%' OR
    p.nome ILIKE '%banana%' OR
    p.nome ILIKE '%doce%' OR
    p.nome ILIKE '%morango%' OR
    c.nome ILIKE '%doce%'
ORDER BY p.nome;

-- 3. Verificar TODOS os produtos com "pizza" no nome
SELECT 
    p.id,
    p.nome,
    p.categoria_id,
    c.nome as categoria_nome,
    p.tipo_produto,
    p.ativo
FROM produtos p
LEFT JOIN categorias c ON p.categoria_id = c.id
WHERE p.nome ILIKE '%pizza%'
ORDER BY p.nome;

-- 4. Contar produtos por categoria
SELECT 
    c.nome as categoria,
    COUNT(p.id) as total_produtos,
    COUNT(CASE WHEN p.ativo = true THEN 1 END) as produtos_ativos
FROM categorias c
LEFT JOIN produtos p ON p.categoria_id = c.id
GROUP BY c.id, c.nome
ORDER BY c.nome;

-- 5. Verificar se existem preços para pizzas doces
SELECT 
    p.nome as produto,
    t.nome as tamanho,
    pp.preco
FROM produtos p
LEFT JOIN produtos_precos pp ON pp.produto_id = p.id
LEFT JOIN tamanhos t ON pp.tamanho_id = t.id
WHERE 
    p.nome ILIKE '%chocolate%' OR
    p.nome ILIKE '%nutella%' OR
    p.nome ILIKE '%brigadeiro%' OR
    p.nome ILIKE '%doce%'
ORDER BY p.nome, t.id;

-- 6. Verificar estrutura da tabela produtos_precos
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'produtos_precos'
ORDER BY ordinal_position;