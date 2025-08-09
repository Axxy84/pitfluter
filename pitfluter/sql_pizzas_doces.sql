-- 1. Criar categoria Pizzas Doces se não existir
INSERT INTO produtos_categoria (nome, descricao, ativo)
SELECT 'Pizzas Doces', 'Pizzas doces especiais', true
WHERE NOT EXISTS (
    SELECT 1 FROM produtos_categoria WHERE nome = 'Pizzas Doces'
);

-- 2. Inserir as pizzas doces
DO $$
DECLARE
    categoria_id INTEGER;
    produto_id INTEGER;
    tamanho_p_id INTEGER;
    tamanho_m_id INTEGER;
    tamanho_g_id INTEGER;
    tamanho_gg_id INTEGER;
BEGIN
    -- Buscar ID da categoria
    SELECT id INTO categoria_id FROM produtos_categoria WHERE nome = 'Pizzas Doces';
    
    -- Buscar IDs dos tamanhos
    SELECT id INTO tamanho_p_id FROM produtos_tamanho WHERE nome IN ('P', 'Pequena') LIMIT 1;
    SELECT id INTO tamanho_m_id FROM produtos_tamanho WHERE nome IN ('M', 'Média') LIMIT 1;
    SELECT id INTO tamanho_g_id FROM produtos_tamanho WHERE nome IN ('G', 'Grande') LIMIT 1;
    SELECT id INTO tamanho_gg_id FROM produtos_tamanho WHERE nome IN ('GG', 'Família', 'Familia') LIMIT 1;
    
    -- Pizza 1: Abacaxi Gratinado
    IF NOT EXISTS (SELECT 1 FROM produtos_produto WHERE nome = 'Abacaxi Gratinado' AND categoria_id = categoria_id) THEN
        INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
        VALUES ('Abacaxi Gratinado', 'Leite condensado, mussarela, abacaxi em cubos gratinado e canela em pó', categoria_id, 'pizza', true)
        RETURNING id INTO produto_id;
        
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, ativo) VALUES 
        (produto_id, tamanho_p_id, 31.00, true),
        (produto_id, tamanho_m_id, 35.00, true),
        (produto_id, tamanho_g_id, 39.00, true),
        (produto_id, tamanho_gg_id, 45.00, true);
    END IF;
    
    -- Pizza 2: Abacaxi ao Chocolate
    IF NOT EXISTS (SELECT 1 FROM produtos_produto WHERE nome = 'Abacaxi ao Chocolate' AND categoria_id = categoria_id) THEN
        INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
        VALUES ('Abacaxi ao Chocolate', 'Leite condensado, abacaxi e chocolate branco', categoria_id, 'pizza', true)
        RETURNING id INTO produto_id;
        
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, ativo) VALUES 
        (produto_id, tamanho_p_id, 34.00, true),
        (produto_id, tamanho_m_id, 38.00, true),
        (produto_id, tamanho_g_id, 42.00, true),
        (produto_id, tamanho_gg_id, 48.00, true);
    END IF;
    
    -- Pizza 3: Banana Caramelizada
    IF NOT EXISTS (SELECT 1 FROM produtos_produto WHERE nome = 'Banana Caramelizada' AND categoria_id = categoria_id) THEN
        INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
        VALUES ('Banana Caramelizada', 'Leite condensado, mussarela, banana caramelizada e canela em pó', categoria_id, 'pizza', true)
        RETURNING id INTO produto_id;
        
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, ativo) VALUES 
        (produto_id, tamanho_p_id, 28.00, true),
        (produto_id, tamanho_m_id, 34.00, true),
        (produto_id, tamanho_g_id, 37.00, true),
        (produto_id, tamanho_gg_id, 41.00, true);
    END IF;
    
    -- Pizza 4: Charge Branco
    IF NOT EXISTS (SELECT 1 FROM produtos_produto WHERE nome = 'Charge Branco' AND categoria_id = categoria_id) THEN
        INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
        VALUES ('Charge Branco', 'Leite condensado, chocolate branco e amendoim triturado', categoria_id, 'pizza', true)
        RETURNING id INTO produto_id;
        
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, ativo) VALUES 
        (produto_id, tamanho_p_id, 34.00, true),
        (produto_id, tamanho_m_id, 36.00, true),
        (produto_id, tamanho_g_id, 40.00, true),
        (produto_id, tamanho_gg_id, 45.00, true);
    END IF;
    
    -- Pizza 5: Nevada
    IF NOT EXISTS (SELECT 1 FROM produtos_produto WHERE nome = 'Nevada' AND categoria_id = categoria_id) THEN
        INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
        VALUES ('Nevada', 'Leite condensado, banana, chocolate branco e canela', categoria_id, 'pizza', true)
        RETURNING id INTO produto_id;
        
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, ativo) VALUES 
        (produto_id, tamanho_p_id, 30.00, true),
        (produto_id, tamanho_m_id, 33.00, true),
        (produto_id, tamanho_g_id, 38.00, true),
        (produto_id, tamanho_gg_id, 43.00, true);
    END IF;
    
    -- Pizza 6: Nutella com Morangos
    IF NOT EXISTS (SELECT 1 FROM produtos_produto WHERE nome = 'Nutella com Morangos' AND categoria_id = categoria_id) THEN
        INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
        VALUES ('Nutella com Morangos', 'Creme de leite, Nutella e morangos', categoria_id, 'pizza', true)
        RETURNING id INTO produto_id;
        
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, ativo) VALUES 
        (produto_id, tamanho_p_id, 30.00, true),
        (produto_id, tamanho_m_id, 33.00, true),
        (produto_id, tamanho_g_id, 38.00, true),
        (produto_id, tamanho_gg_id, 43.00, true);
    END IF;
    
    -- Pizza 7: Romeu e Julieta
    IF NOT EXISTS (SELECT 1 FROM produtos_produto WHERE nome = 'Romeu e Julieta' AND categoria_id = categoria_id) THEN
        INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
        VALUES ('Romeu e Julieta', 'Leite condensado, mussarela e goiabada', categoria_id, 'pizza', true)
        RETURNING id INTO produto_id;
        
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, ativo) VALUES 
        (produto_id, tamanho_p_id, 29.00, true),
        (produto_id, tamanho_m_id, 35.00, true),
        (produto_id, tamanho_g_id, 43.00, true),
        (produto_id, tamanho_gg_id, 45.00, true);
    END IF;
    
    -- Pizza 8: Romeu e Julieta com Gorgonzola
    IF NOT EXISTS (SELECT 1 FROM produtos_produto WHERE nome = 'Romeu e Julieta com Gorgonzola' AND categoria_id = categoria_id) THEN
        INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo)
        VALUES ('Romeu e Julieta com Gorgonzola', 'Leite condensado, mussarela, goiabada e gorgonzola', categoria_id, 'pizza', true)
        RETURNING id INTO produto_id;
        
        INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, ativo) VALUES 
        (produto_id, tamanho_p_id, 34.00, true),
        (produto_id, tamanho_m_id, 37.00, true),
        (produto_id, tamanho_g_id, 40.00, true),
        (produto_id, tamanho_gg_id, 48.00, true);
    END IF;
    
END $$;