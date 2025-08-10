-- Verificar e corrigir pizzas doces

-- 1. Verificar se existe a categoria Pizzas Doces
SELECT id, nome FROM categorias WHERE nome ILIKE '%pizza%doce%';

-- 2. Verificar produtos de pizza doce
SELECT p.id, p.nome, p.categoria_id, c.nome as categoria_nome, p.preco_unitario
FROM produtos p
LEFT JOIN categorias c ON p.categoria_id = c.id
WHERE p.nome ILIKE '%chocolate%' 
   OR p.nome ILIKE '%nutella%'
   OR p.nome ILIKE '%brigadeiro%'
   OR p.nome ILIKE '%romeu%'
   OR p.nome ILIKE '%doce%'
   OR c.nome ILIKE '%doce%';

-- 3. Verificar tamanhos disponíveis
SELECT * FROM tamanhos ORDER BY id;

-- 4. Verificar preços das pizzas doces
SELECT 
    p.nome as produto,
    t.nome as tamanho,
    pp.preco,
    pp.preco_promocional
FROM produtos_precos pp
JOIN produtos p ON pp.produto_id = p.id
JOIN tamanhos t ON pp.tamanho_id = t.id
WHERE p.nome ILIKE '%chocolate%' 
   OR p.nome ILIKE '%nutella%'
   OR p.nome ILIKE '%brigadeiro%'
   OR p.nome ILIKE '%romeu%'
   OR p.nome ILIKE '%doce%'
ORDER BY p.nome, t.id;

-- 5. Inserir preços para pizzas doces que não têm
-- Primeiro, criar uma função para adicionar preços
DO $$
DECLARE
    pizza_record RECORD;
    tamanho_record RECORD;
    preco_base NUMERIC;
BEGIN
    -- Para cada pizza doce
    FOR pizza_record IN 
        SELECT p.id, p.nome 
        FROM produtos p
        LEFT JOIN categorias c ON p.categoria_id = c.id
        WHERE p.nome ILIKE '%chocolate%' 
           OR p.nome ILIKE '%nutella%'
           OR p.nome ILIKE '%brigadeiro%'
           OR p.nome ILIKE '%romeu%'
           OR p.nome ILIKE '%banana%'
           OR p.nome ILIKE '%doce%'
           OR c.nome ILIKE '%doce%'
    LOOP
        -- Para cada tamanho
        FOR tamanho_record IN SELECT id, nome FROM tamanhos ORDER BY id
        LOOP
            -- Definir preço base conforme tamanho
            preco_base := CASE tamanho_record.nome
                WHEN 'P' THEN 30.00
                WHEN 'M' THEN 40.00
                WHEN 'G' THEN 50.00
                WHEN 'GG' THEN 60.00
                WHEN 'Família' THEN 60.00
                ELSE 45.00
            END;
            
            -- Inserir se não existe
            INSERT INTO produtos_precos (produto_id, tamanho_id, preco, preco_promocional)
            VALUES (pizza_record.id, tamanho_record.id, preco_base, preco_base)
            ON CONFLICT (produto_id, tamanho_id) DO NOTHING;
        END LOOP;
    END LOOP;
END $$;

-- 6. Verificar resultado
SELECT 
    p.nome as produto,
    COUNT(pp.id) as qtd_precos
FROM produtos p
LEFT JOIN produtos_precos pp ON pp.produto_id = p.id
LEFT JOIN categorias c ON p.categoria_id = c.id
WHERE p.nome ILIKE '%chocolate%' 
   OR p.nome ILIKE '%nutella%'
   OR p.nome ILIKE '%brigadeiro%'
   OR p.nome ILIKE '%romeu%'
   OR p.nome ILIKE '%doce%'
   OR c.nome ILIKE '%doce%'
GROUP BY p.id, p.nome
ORDER BY p.nome;