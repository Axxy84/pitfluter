-- Script para verificar e diagnosticar problema com pizzas doces e seus preços/tamanhos

-- 1. Verificar se existem pizzas doces no banco
SELECT 
    p.id,
    p.nome,
    p.tipo_produto,
    p.preco_unitario,
    c.nome as categoria
FROM produtos p
LEFT JOIN categorias c ON p.categoria_id = c.id
WHERE 
    p.nome ILIKE '%doce%'
    OR p.nome ILIKE '%chocolate%'
    OR p.nome ILIKE '%nutella%'
    OR p.nome ILIKE '%brigadeiro%'
    OR c.nome ILIKE '%doce%'
ORDER BY p.nome;

-- 2. Verificar se existem tamanhos cadastrados
SELECT * FROM produtos_tamanho ORDER BY id;

-- 3. Verificar se as pizzas doces têm preços por tamanho
SELECT 
    p.nome as pizza,
    pt.nome as tamanho,
    pp.preco,
    pp.preco_promocional,
    pp.id as preco_id
FROM produtos p
LEFT JOIN produtos_precos pp ON p.id = pp.produto_id
LEFT JOIN produtos_tamanho pt ON pp.tamanho_id = pt.id
WHERE 
    p.nome ILIKE '%doce%'
    OR p.nome ILIKE '%chocolate%'
    OR p.nome ILIKE '%nutella%'
    OR p.nome ILIKE '%brigadeiro%'
ORDER BY p.nome, pt.id;

-- 4. Contar quantas pizzas doces NÃO têm preços por tamanho
SELECT 
    COUNT(DISTINCT p.id) as pizzas_doces_sem_precos
FROM produtos p
LEFT JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN produtos_precos pp ON p.id = pp.produto_id
WHERE 
    (p.nome ILIKE '%doce%'
    OR p.nome ILIKE '%chocolate%'
    OR p.nome ILIKE '%nutella%'
    OR p.nome ILIKE '%brigadeiro%'
    OR c.nome ILIKE '%doce%')
    AND pp.id IS NULL;

-- 5. Listar pizzas doces SEM preços por tamanho
SELECT 
    p.id,
    p.nome,
    p.preco_unitario,
    c.nome as categoria
FROM produtos p
LEFT JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN produtos_precos pp ON p.id = pp.produto_id
WHERE 
    (p.nome ILIKE '%doce%'
    OR p.nome ILIKE '%chocolate%'
    OR p.nome ILIKE '%nutella%'
    OR p.nome ILIKE '%brigadeiro%'
    OR c.nome ILIKE '%doce%')
    AND pp.id IS NULL
ORDER BY p.nome;

-- 6. Verificar estrutura da tabela produtos_precos
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'produtos_precos'
ORDER BY ordinal_position;