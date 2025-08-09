-- Script para adicionar as pizzas doces com todos os tamanhos e preços

-- Primeiro, pegar o ID da categoria Pizzas Doces
DO $$
DECLARE
    categoria_id INTEGER;
    produto_id INTEGER;
BEGIN
    -- Buscar ID da categoria
    SELECT id INTO categoria_id FROM produtos_categoria WHERE nome = 'Pizzas Doces';
    
    IF categoria_id IS NULL THEN
        RAISE EXCEPTION 'Categoria Pizzas Doces não encontrada!';
    END IF;
    
    -- 1. Abacaxi Gratinado
    INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
    VALUES ('Abacaxi Gratinado', 'Leite condensado, mussarela, abacaxi em cubos gratinado e canela em pó', categoria_id, 'pizza', true)
    ON CONFLICT DO NOTHING
    RETURNING id INTO produto_id;
    
    IF produto_id IS NOT NULL THEN
        -- Inserir preços para cada tamanho
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, ativo) 
        SELECT produto_id, id, 
            CASE nome
                WHEN 'P' THEN 31.00
                WHEN 'M' THEN 35.00
                WHEN 'G' THEN 39.00
                WHEN 'GG' THEN 45.00
            END,
            true
        FROM produtos_tamanho
        WHERE nome IN ('P', 'M', 'G', 'GG');
    END IF;
    
    -- 2. Abacaxi ao Chocolate
    INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
    VALUES ('Abacaxi ao Chocolate', 'Leite condensado, abacaxi e chocolate branco', categoria_id, 'pizza', true)
    ON CONFLICT DO NOTHING
    RETURNING id INTO produto_id;
    
    IF produto_id IS NOT NULL THEN
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, ativo) 
        SELECT produto_id, id, 
            CASE nome
                WHEN 'P' THEN 34.00
                WHEN 'M' THEN 38.00
                WHEN 'G' THEN 42.00
                WHEN 'GG' THEN 48.00
            END,
            true
        FROM produtos_tamanho
        WHERE nome IN ('P', 'M', 'G', 'GG');
    END IF;
    
    -- 3. Banana Caramelizada
    INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
    VALUES ('Banana Caramelizada', 'Leite condensado, mussarela, banana caramelizada e canela em pó', categoria_id, 'pizza', true)
    ON CONFLICT DO NOTHING
    RETURNING id INTO produto_id;
    
    IF produto_id IS NOT NULL THEN
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, ativo) 
        SELECT produto_id, id, 
            CASE nome
                WHEN 'P' THEN 28.00
                WHEN 'M' THEN 34.00
                WHEN 'G' THEN 37.00
                WHEN 'GG' THEN 41.00
            END,
            true
        FROM produtos_tamanho
        WHERE nome IN ('P', 'M', 'G', 'GG');
    END IF;
    
    -- 4. Charge Branco
    INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
    VALUES ('Charge Branco', 'Leite condensado, chocolate branco e amendoim triturado', categoria_id, 'pizza', true)
    ON CONFLICT DO NOTHING
    RETURNING id INTO produto_id;
    
    IF produto_id IS NOT NULL THEN
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, ativo) 
        SELECT produto_id, id, 
            CASE nome
                WHEN 'P' THEN 34.00
                WHEN 'M' THEN 36.00
                WHEN 'G' THEN 40.00
                WHEN 'GG' THEN 45.00
            END,
            true
        FROM produtos_tamanho
        WHERE nome IN ('P', 'M', 'G', 'GG');
    END IF;
    
    -- 5. Nevada
    INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
    VALUES ('Nevada', 'Leite condensado, banana, chocolate branco e canela', categoria_id, 'pizza', true)
    ON CONFLICT DO NOTHING
    RETURNING id INTO produto_id;
    
    IF produto_id IS NOT NULL THEN
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, ativo) 
        SELECT produto_id, id, 
            CASE nome
                WHEN 'P' THEN 30.00
                WHEN 'M' THEN 33.00
                WHEN 'G' THEN 38.00
                WHEN 'GG' THEN 43.00
            END,
            true
        FROM produtos_tamanho
        WHERE nome IN ('P', 'M', 'G', 'GG');
    END IF;
    
    -- 6. Nutella com Morangos
    INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
    VALUES ('Nutella com Morangos', 'Creme de leite, Nutella e morangos', categoria_id, 'pizza', true)
    ON CONFLICT DO NOTHING
    RETURNING id INTO produto_id;
    
    IF produto_id IS NOT NULL THEN
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, ativo) 
        SELECT produto_id, id, 
            CASE nome
                WHEN 'P' THEN 30.00
                WHEN 'M' THEN 33.00
                WHEN 'G' THEN 38.00
                WHEN 'GG' THEN 43.00
            END,
            true
        FROM produtos_tamanho
        WHERE nome IN ('P', 'M', 'G', 'GG');
    END IF;
    
    -- 7. Romeu e Julieta
    INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
    VALUES ('Romeu e Julieta', 'Leite condensado, mussarela e goiabada', categoria_id, 'pizza', true)
    ON CONFLICT DO NOTHING
    RETURNING id INTO produto_id;
    
    IF produto_id IS NOT NULL THEN
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, ativo) 
        SELECT produto_id, id, 
            CASE nome
                WHEN 'P' THEN 29.00
                WHEN 'M' THEN 35.00
                WHEN 'G' THEN 43.00
                WHEN 'GG' THEN 45.00
            END,
            true
        FROM produtos_tamanho
        WHERE nome IN ('P', 'M', 'G', 'GG');
    END IF;
    
    -- 8. Romeu e Julieta com Gorgonzola
    INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
    VALUES ('Romeu e Julieta com Gorgonzola', 'Leite condensado, mussarela, goiabada e gorgonzola', categoria_id, 'pizza', true)
    ON CONFLICT DO NOTHING
    RETURNING id INTO produto_id;
    
    IF produto_id IS NOT NULL THEN
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, ativo) 
        SELECT produto_id, id, 
            CASE nome
                WHEN 'P' THEN 34.00
                WHEN 'M' THEN 37.00
                WHEN 'G' THEN 40.00
                WHEN 'GG' THEN 48.00
            END,
            true
        FROM produtos_tamanho
        WHERE nome IN ('P', 'M', 'G', 'GG');
    END IF;
    
    RAISE NOTICE 'Pizzas doces adicionadas com sucesso!';
END $$;

-- Verificar o resultado
SELECT 
    p.nome,
    COUNT(pp.id) as total_precos
FROM produtos_produto p
LEFT JOIN produtos_produtopreco pp ON p.id = pp.produto_id
WHERE p.categoria_id = (SELECT id FROM produtos_categoria WHERE nome = 'Pizzas Doces')
GROUP BY p.nome
ORDER BY p.nome;