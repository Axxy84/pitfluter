-- Script para inserir preços por tamanho para pizzas doces

-- Criar função para inserir preços automaticamente
DO $$
DECLARE
    pizza RECORD;
    tamanho RECORD;
    preco_base DECIMAL;
BEGIN
    -- Loop através de todas as pizzas doces
    FOR pizza IN 
        SELECT p.id, p.nome, p.preco_unitario
        FROM produtos p
        LEFT JOIN categorias c ON p.categoria_id = c.id
        WHERE 
            p.nome ILIKE '%doce%'
            OR p.nome ILIKE '%chocolate%'
            OR p.nome ILIKE '%nutella%'
            OR p.nome ILIKE '%brigadeiro%'
            OR p.nome ILIKE '%romeu%'
            OR p.nome ILIKE '%banana%'
            OR c.nome ILIKE '%doce%'
    LOOP
        -- Definir preço base
        preco_base := COALESCE(pizza.preco_unitario, 40.00);
        
        -- Para cada tamanho disponível
        FOR tamanho IN 
            SELECT id, nome FROM produtos_tamanho ORDER BY id
        LOOP
            -- Verificar se já existe preço para este produto e tamanho
            IF NOT EXISTS (
                SELECT 1 
                FROM produtos_precos 
                WHERE produto_id = pizza.id 
                AND tamanho_id = tamanho.id
            ) THEN
                -- Inserir preço baseado no tamanho
                INSERT INTO produtos_precos (produto_id, tamanho_id, preco, preco_promocional)
                VALUES (
                    pizza.id,
                    tamanho.id,
                    CASE tamanho.nome
                        WHEN 'P' THEN 30.00
                        WHEN 'M' THEN 40.00
                        WHEN 'G' THEN 50.00
                        WHEN 'GG' THEN 60.00
                        WHEN 'Família' THEN 70.00
                        ELSE preco_base
                    END,
                    CASE tamanho.nome
                        WHEN 'P' THEN 30.00
                        WHEN 'M' THEN 40.00
                        WHEN 'G' THEN 50.00
                        WHEN 'GG' THEN 60.00
                        WHEN 'Família' THEN 70.00
                        ELSE preco_base
                    END
                );
                
                RAISE NOTICE 'Inserido preço para: % - Tamanho: %', pizza.nome, tamanho.nome;
            END IF;
        END LOOP;
    END LOOP;
END $$;

-- Verificar o resultado
SELECT 
    p.nome as pizza,
    pt.nome as tamanho,
    pp.preco,
    pp.preco_promocional
FROM produtos p
JOIN produtos_precos pp ON p.id = pp.produto_id
JOIN produtos_tamanho pt ON pp.tamanho_id = pt.id
WHERE 
    p.nome ILIKE '%doce%'
    OR p.nome ILIKE '%chocolate%'
    OR p.nome ILIKE '%nutella%'
    OR p.nome ILIKE '%brigadeiro%'
ORDER BY p.nome, pt.id;