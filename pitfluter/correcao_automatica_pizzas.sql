-- =====================================================
-- SCRIPT DE CORREÇÃO AUTOMÁTICA - PIZZAS DOCES
-- =====================================================
-- Execute este script no Supabase para corrigir todos os problemas

BEGIN;

-- 1. CRIAR TAMANHOS SE NÃO EXISTIREM
-- =====================================================
INSERT INTO tamanhos (nome) 
VALUES ('P'), ('M'), ('G'), ('GG')
ON CONFLICT (nome) DO NOTHING;

-- Verificar resultado
DO $$
BEGIN
    RAISE NOTICE 'Tamanhos cadastrados: %', 
        (SELECT STRING_AGG(nome, ', ' ORDER BY id) FROM tamanhos WHERE nome IN ('P', 'M', 'G', 'GG'));
END $$;

-- 2. CRIAR/ATUALIZAR CATEGORIA PIZZAS DOCES
-- =====================================================
-- Primeiro, verificar se já existe
DO $$
DECLARE
    categoria_id INTEGER;
BEGIN
    -- Buscar categoria existente
    SELECT id INTO categoria_id 
    FROM categorias 
    WHERE nome = 'Pizzas Doces';
    
    IF categoria_id IS NULL THEN
        -- Criar nova categoria
        INSERT INTO categorias (nome, ativo) 
        VALUES ('Pizzas Doces', true)
        RETURNING id INTO categoria_id;
        RAISE NOTICE 'Categoria "Pizzas Doces" criada com ID: %', categoria_id;
    ELSE
        -- Ativar se estiver inativa
        UPDATE categorias 
        SET ativo = true 
        WHERE id = categoria_id AND ativo = false;
        RAISE NOTICE 'Categoria "Pizzas Doces" já existe com ID: %', categoria_id;
    END IF;
END $$;

-- 3. INSERIR PIZZAS DOCES SE NÃO EXISTIREM
-- =====================================================
WITH categoria_doce AS (
    SELECT id FROM categorias WHERE nome = 'Pizzas Doces' LIMIT 1
)
INSERT INTO produtos (nome, descricao, categoria_id, tipo_produto, preco_unitario, ativo)
SELECT 
    nome,
    descricao,
    (SELECT id FROM categoria_doce),
    'pizza',
    preco_unitario,
    true
FROM (VALUES
    ('Pizza de Chocolate', 'Pizza doce com chocolate ao leite, granulado e morangos', 35.00),
    ('Pizza de Morango com Nutella', 'Pizza doce com Nutella e morangos frescos', 35.00),
    ('Pizza Romeu e Julieta', 'Pizza doce com goiabada e queijo', 35.00),
    ('Pizza de Banana com Canela', 'Pizza doce com banana, açúcar e canela', 35.00),
    ('Pizza de Brigadeiro', 'Pizza doce com brigadeiro e granulado', 35.00),
    ('Pizza de Prestígio', 'Pizza doce com chocolate e coco ralado', 35.00),
    ('Pizza de Doce de Leite', 'Pizza doce com doce de leite e coco', 35.00),
    ('Pizza de Beijinho', 'Pizza doce com beijinho e coco ralado', 35.00)
) AS pizzas_doces(nome, descricao, preco_unitario)
WHERE NOT EXISTS (
    SELECT 1 FROM produtos WHERE produtos.nome = pizzas_doces.nome
);

-- 4. ATUALIZAR PRODUTOS EXISTENTES
-- =====================================================
-- Garantir que todas as pizzas tenham tipo_produto = 'pizza'
UPDATE produtos 
SET tipo_produto = 'pizza'
WHERE nome ILIKE '%pizza%' 
  AND tipo_produto IS DISTINCT FROM 'pizza';

-- Atualizar categoria das pizzas doces
UPDATE produtos 
SET categoria_id = (SELECT id FROM categorias WHERE nome = 'Pizzas Doces' LIMIT 1)
WHERE (nome ILIKE '%chocolate%' 
    OR nome ILIKE '%nutella%' 
    OR nome ILIKE '%brigadeiro%' 
    OR nome ILIKE '%romeu%'
    OR nome ILIKE '%morango%'
    OR nome ILIKE '%banana%'
    OR nome ILIKE '%prestígio%'
    OR nome ILIKE '%beijinho%'
    OR nome ILIKE '%doce%')
  AND nome ILIKE '%pizza%';

-- 5. CRIAR PREÇOS POR TAMANHO PARA TODAS AS PIZZAS
-- =====================================================
DO $$
DECLARE
    pizza RECORD;
    tamanho RECORD;
    preco_base NUMERIC;
    preco_tamanho NUMERIC;
    contador INTEGER := 0;
BEGIN
    -- Para cada pizza
    FOR pizza IN 
        SELECT id, nome, preco_unitario 
        FROM produtos 
        WHERE (tipo_produto = 'pizza' OR nome ILIKE '%pizza%')
          AND ativo = true
    LOOP
        -- Definir preço base
        preco_base := COALESCE(pizza.preco_unitario, 35.00);
        
        -- Para cada tamanho
        FOR tamanho IN 
            SELECT id, nome FROM tamanhos WHERE nome IN ('P', 'M', 'G', 'GG')
        LOOP
            -- Calcular preço por tamanho
            preco_tamanho := CASE tamanho.nome
                WHEN 'P' THEN preco_base - 5
                WHEN 'M' THEN preco_base
                WHEN 'G' THEN preco_base + 10
                WHEN 'GG' THEN preco_base + 20
                ELSE preco_base
            END;
            
            -- Inserir se não existir
            INSERT INTO produtos_precos (produto_id, tamanho_id, preco, preco_promocional)
            VALUES (pizza.id, tamanho.id, preco_tamanho, preco_tamanho)
            ON CONFLICT (produto_id, tamanho_id) 
            DO UPDATE SET 
                preco = EXCLUDED.preco,
                preco_promocional = EXCLUDED.preco_promocional
            WHERE produtos_precos.preco IS NULL OR produtos_precos.preco = 0;
            
            contador := contador + 1;
        END LOOP;
    END LOOP;
    
    RAISE NOTICE 'Preços processados: %', contador;
END $$;

-- 6. VERIFICAÇÃO FINAL
-- =====================================================
\echo '\n========== RESULTADO DA CORREÇÃO =========='

-- Pizzas doces cadastradas
SELECT 
    'Pizzas Doces Cadastradas:' as info,
    COUNT(*) as quantidade
FROM produtos p
JOIN categorias c ON p.categoria_id = c.id
WHERE c.nome = 'Pizzas Doces';

-- Pizzas com preços completos
SELECT 
    'Pizzas com 4 tamanhos de preço:' as info,
    COUNT(*) as quantidade
FROM (
    SELECT produto_id
    FROM produtos_precos pp
    JOIN produtos p ON pp.produto_id = p.id
    WHERE p.tipo_produto = 'pizza'
    GROUP BY produto_id
    HAVING COUNT(*) >= 4
) t;

-- Lista final de pizzas doces
\echo '\n>>> PIZZAS DOCES FINAIS:'
SELECT 
    p.nome,
    c.nome as categoria,
    p.tipo_produto,
    p.ativo,
    COUNT(pp.id) as qtd_precos
FROM produtos p
LEFT JOIN categorias c ON p.categoria_id = c.id
LEFT JOIN produtos_precos pp ON pp.produto_id = p.id
WHERE c.nome = 'Pizzas Doces' OR (
    p.nome ILIKE '%pizza%' AND (
        p.nome ILIKE '%chocolate%' OR
        p.nome ILIKE '%nutella%' OR
        p.nome ILIKE '%brigadeiro%' OR
        p.nome ILIKE '%doce%'
    )
)
GROUP BY p.id, p.nome, c.nome, p.tipo_produto, p.ativo
ORDER BY p.nome;

COMMIT;

\echo '\n✅ CORREÇÃO CONCLUÍDA COM SUCESSO!'
\echo 'As pizzas doces agora devem aparecer corretamente na aplicação.'