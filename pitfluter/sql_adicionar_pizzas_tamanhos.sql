-- Script para adicionar as pizzas doces com todos os tamanhos
-- Execute este script no Supabase SQL Editor

DO $$
DECLARE
    v_categoria_id INTEGER;
    v_produto_id INTEGER;
    v_tamanho_p INTEGER;
    v_tamanho_m INTEGER;
    v_tamanho_g INTEGER;
    v_tamanho_gg INTEGER;
BEGIN
    -- Buscar ID da categoria Pizzas Doces
    SELECT id INTO v_categoria_id 
    FROM produtos_categoria 
    WHERE nome = 'Pizzas Doces';
    
    IF v_categoria_id IS NULL THEN
        RAISE NOTICE 'Categoria Pizzas Doces não encontrada! Criando...';
        INSERT INTO produtos_categoria (nome, descricao, ativo)
        VALUES ('Pizzas Doces', 'Pizzas doces especiais', true)
        RETURNING id INTO v_categoria_id;
    END IF;
    
    RAISE NOTICE 'Usando categoria ID: %', v_categoria_id;
    
    -- Buscar IDs dos tamanhos
    SELECT id INTO v_tamanho_p FROM produtos_tamanho WHERE nome = 'P';
    SELECT id INTO v_tamanho_m FROM produtos_tamanho WHERE nome = 'M';
    SELECT id INTO v_tamanho_g FROM produtos_tamanho WHERE nome = 'G';
    SELECT id INTO v_tamanho_gg FROM produtos_tamanho WHERE nome = 'GG';
    
    RAISE NOTICE 'Tamanhos: P=%, M=%, G=%, GG=%', v_tamanho_p, v_tamanho_m, v_tamanho_g, v_tamanho_gg;
    
    -- 1. Abacaxi Gratinado
    SELECT id INTO v_produto_id FROM produtos_produto 
    WHERE nome = 'Abacaxi Gratinado' AND categoria_id = v_categoria_id;
    
    IF v_produto_id IS NULL THEN
        INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
        VALUES ('Abacaxi Gratinado', 'Leite condensado, mussarela, abacaxi em cubos gratinado e canela em pó', v_categoria_id, 'pizza', true)
        RETURNING id INTO v_produto_id;
        
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco) VALUES
        (v_produto_id, v_tamanho_p, 31.00),
        (v_produto_id, v_tamanho_m, 35.00),
        (v_produto_id, v_tamanho_g, 39.00),
        (v_produto_id, v_tamanho_gg, 45.00);
        RAISE NOTICE 'Adicionada: Abacaxi Gratinado';
    ELSE
        RAISE NOTICE 'Pizza já existe: Abacaxi Gratinado';
    END IF;
    
    -- 2. Abacaxi ao Chocolate
    v_produto_id := NULL;
    SELECT id INTO v_produto_id FROM produtos_produto 
    WHERE nome = 'Abacaxi ao Chocolate' AND categoria_id = v_categoria_id;
    
    IF v_produto_id IS NULL THEN
        INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
        VALUES ('Abacaxi ao Chocolate', 'Leite condensado, abacaxi e chocolate branco', v_categoria_id, 'pizza', true)
        RETURNING id INTO v_produto_id;
        
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco) VALUES
        (v_produto_id, v_tamanho_p, 34.00),
        (v_produto_id, v_tamanho_m, 38.00),
        (v_produto_id, v_tamanho_g, 42.00),
        (v_produto_id, v_tamanho_gg, 48.00);
        RAISE NOTICE 'Adicionada: Abacaxi ao Chocolate';
    ELSE
        RAISE NOTICE 'Pizza já existe: Abacaxi ao Chocolate';
    END IF;
    
    -- 3. Banana Caramelizada
    v_produto_id := NULL;
    SELECT id INTO v_produto_id FROM produtos_produto 
    WHERE nome = 'Banana Caramelizada' AND categoria_id = v_categoria_id;
    
    IF v_produto_id IS NULL THEN
        INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
        VALUES ('Banana Caramelizada', 'Leite condensado, mussarela, banana caramelizada e canela em pó', v_categoria_id, 'pizza', true)
        RETURNING id INTO v_produto_id;
        
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco) VALUES
        (v_produto_id, v_tamanho_p, 28.00),
        (v_produto_id, v_tamanho_m, 34.00),
        (v_produto_id, v_tamanho_g, 37.00),
        (v_produto_id, v_tamanho_gg, 41.00);
        RAISE NOTICE 'Adicionada: Banana Caramelizada';
    ELSE
        RAISE NOTICE 'Pizza já existe: Banana Caramelizada';
    END IF;
    
    -- 4. Charge Branco
    v_produto_id := NULL;
    SELECT id INTO v_produto_id FROM produtos_produto 
    WHERE nome = 'Charge Branco' AND categoria_id = v_categoria_id;
    
    IF v_produto_id IS NULL THEN
        INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
        VALUES ('Charge Branco', 'Leite condensado, chocolate branco e amendoim triturado', v_categoria_id, 'pizza', true)
        RETURNING id INTO v_produto_id;
        
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco) VALUES
        (v_produto_id, v_tamanho_p, 34.00),
        (v_produto_id, v_tamanho_m, 36.00),
        (v_produto_id, v_tamanho_g, 40.00),
        (v_produto_id, v_tamanho_gg, 45.00);
        RAISE NOTICE 'Adicionada: Charge Branco';
    ELSE
        RAISE NOTICE 'Pizza já existe: Charge Branco';
    END IF;
    
    -- 5. Nevada
    v_produto_id := NULL;
    SELECT id INTO v_produto_id FROM produtos_produto 
    WHERE nome = 'Nevada' AND categoria_id = v_categoria_id;
    
    IF v_produto_id IS NULL THEN
        INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
        VALUES ('Nevada', 'Leite condensado, banana, chocolate branco e canela', v_categoria_id, 'pizza', true)
        RETURNING id INTO v_produto_id;
        
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco) VALUES
        (v_produto_id, v_tamanho_p, 30.00),
        (v_produto_id, v_tamanho_m, 33.00),
        (v_produto_id, v_tamanho_g, 38.00),
        (v_produto_id, v_tamanho_gg, 43.00);
        RAISE NOTICE 'Adicionada: Nevada';
    ELSE
        RAISE NOTICE 'Pizza já existe: Nevada';
    END IF;
    
    -- 6. Nutella com Morangos
    v_produto_id := NULL;
    SELECT id INTO v_produto_id FROM produtos_produto 
    WHERE nome = 'Nutella com Morangos' AND categoria_id = v_categoria_id;
    
    IF v_produto_id IS NULL THEN
        INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
        VALUES ('Nutella com Morangos', 'Creme de leite, Nutella e morangos', v_categoria_id, 'pizza', true)
        RETURNING id INTO v_produto_id;
        
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco) VALUES
        (v_produto_id, v_tamanho_p, 30.00),
        (v_produto_id, v_tamanho_m, 33.00),
        (v_produto_id, v_tamanho_g, 38.00),
        (v_produto_id, v_tamanho_gg, 43.00);
        RAISE NOTICE 'Adicionada: Nutella com Morangos';
    ELSE
        RAISE NOTICE 'Pizza já existe: Nutella com Morangos';
    END IF;
    
    -- 7. Romeu e Julieta
    v_produto_id := NULL;
    SELECT id INTO v_produto_id FROM produtos_produto 
    WHERE nome = 'Romeu e Julieta' AND categoria_id = v_categoria_id;
    
    IF v_produto_id IS NULL THEN
        INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
        VALUES ('Romeu e Julieta', 'Leite condensado, mussarela e goiabada', v_categoria_id, 'pizza', true)
        RETURNING id INTO v_produto_id;
        
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco) VALUES
        (v_produto_id, v_tamanho_p, 29.00),
        (v_produto_id, v_tamanho_m, 35.00),
        (v_produto_id, v_tamanho_g, 43.00),
        (v_produto_id, v_tamanho_gg, 45.00);
        RAISE NOTICE 'Adicionada: Romeu e Julieta';
    ELSE
        RAISE NOTICE 'Pizza já existe: Romeu e Julieta';
    END IF;
    
    -- 8. Romeu e Julieta com Gorgonzola
    v_produto_id := NULL;
    SELECT id INTO v_produto_id FROM produtos_produto 
    WHERE nome = 'Romeu e Julieta com Gorgonzola' AND categoria_id = v_categoria_id;
    
    IF v_produto_id IS NULL THEN
        INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
        VALUES ('Romeu e Julieta com Gorgonzola', 'Leite condensado, mussarela, goiabada e gorgonzola', v_categoria_id, 'pizza', true)
        RETURNING id INTO v_produto_id;
        
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco) VALUES
        (v_produto_id, v_tamanho_p, 34.00),
        (v_produto_id, v_tamanho_m, 37.00),
        (v_produto_id, v_tamanho_g, 40.00),
        (v_produto_id, v_tamanho_gg, 48.00);
        RAISE NOTICE 'Adicionada: Romeu e Julieta com Gorgonzola';
    ELSE
        RAISE NOTICE 'Pizza já existe: Romeu e Julieta com Gorgonzola';
    END IF;
    
    RAISE NOTICE 'Script concluído!';
END $$;

-- Verificar resultado
SELECT 
    p.nome as pizza,
    t.nome as tamanho,
    pp.preco
FROM produtos_produto p
JOIN produtos_produtopreco pp ON p.id = pp.produto_id
JOIN produtos_tamanho t ON pp.tamanho_id = t.id
WHERE p.categoria_id = (SELECT id FROM produtos_categoria WHERE nome = 'Pizzas Doces')
ORDER BY p.nome, t.id;