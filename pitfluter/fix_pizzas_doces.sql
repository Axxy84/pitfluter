-- SCRIPT PARA CORRIGIR PIZZAS DOCES

-- 1. Verificar se existe categoria para pizzas (qualquer tipo)
DO $$
DECLARE
    categoria_pizza_id INTEGER;
    categoria_doce_id INTEGER;
BEGIN
    -- Buscar categoria de pizza existente
    SELECT id INTO categoria_pizza_id 
    FROM categorias 
    WHERE nome ILIKE '%pizza%' 
    AND ativo = true
    LIMIT 1;
    
    -- Se não existe, criar categoria "Pizzas Salgadas"
    IF categoria_pizza_id IS NULL THEN
        INSERT INTO categorias (nome, ativo) 
        VALUES ('Pizzas Salgadas', true)
        RETURNING id INTO categoria_pizza_id;
        RAISE NOTICE 'Categoria Pizzas Salgadas criada com ID: %', categoria_pizza_id;
    ELSE
        RAISE NOTICE 'Categoria Pizza encontrada com ID: %', categoria_pizza_id;
    END IF;
    
    -- Criar categoria específica para pizzas doces se não existir
    SELECT id INTO categoria_doce_id 
    FROM categorias 
    WHERE nome = 'Pizzas Doces';
    
    IF categoria_doce_id IS NULL THEN
        INSERT INTO categorias (nome, ativo) 
        VALUES ('Pizzas Doces', true)
        RETURNING id INTO categoria_doce_id;
        RAISE NOTICE 'Categoria Pizzas Doces criada com ID: %', categoria_doce_id;
    ELSE
        RAISE NOTICE 'Categoria Pizzas Doces já existe com ID: %', categoria_doce_id;
    END IF;
    
    -- Inserir pizzas doces se não existirem
    -- Pizza de Chocolate
    IF NOT EXISTS (SELECT 1 FROM produtos WHERE nome = 'Pizza de Chocolate') THEN
        INSERT INTO produtos (nome, descricao, categoria_id, tipo_produto, preco_unitario, ativo)
        VALUES ('Pizza de Chocolate', 'Pizza doce com chocolate ao leite e morangos', categoria_doce_id, 'pizza', 35.00, true);
        RAISE NOTICE 'Pizza de Chocolate criada';
    END IF;
    
    -- Pizza de Morango com Nutella
    IF NOT EXISTS (SELECT 1 FROM produtos WHERE nome = 'Pizza de Morango com Nutella') THEN
        INSERT INTO produtos (nome, descricao, categoria_id, tipo_produto, preco_unitario, ativo)
        VALUES ('Pizza de Morango com Nutella', 'Pizza doce com Nutella e morangos frescos', categoria_doce_id, 'pizza', 35.00, true);
        RAISE NOTICE 'Pizza de Morango com Nutella criada';
    END IF;
    
    -- Pizza Romeu e Julieta
    IF NOT EXISTS (SELECT 1 FROM produtos WHERE nome = 'Pizza Romeu e Julieta') THEN
        INSERT INTO produtos (nome, descricao, categoria_id, tipo_produto, preco_unitario, ativo)
        VALUES ('Pizza Romeu e Julieta', 'Pizza doce com goiabada e queijo', categoria_doce_id, 'pizza', 35.00, true);
        RAISE NOTICE 'Pizza Romeu e Julieta criada';
    END IF;
    
    -- Pizza de Banana com Canela
    IF NOT EXISTS (SELECT 1 FROM produtos WHERE nome = 'Pizza de Banana com Canela') THEN
        INSERT INTO produtos (nome, descricao, categoria_id, tipo_produto, preco_unitario, ativo)
        VALUES ('Pizza de Banana com Canela', 'Pizza doce com banana, açúcar e canela', categoria_doce_id, 'pizza', 35.00, true);
        RAISE NOTICE 'Pizza de Banana com Canela criada';
    END IF;
    
    -- Pizza de Brigadeiro
    IF NOT EXISTS (SELECT 1 FROM produtos WHERE nome = 'Pizza de Brigadeiro') THEN
        INSERT INTO produtos (nome, descricao, categoria_id, tipo_produto, preco_unitario, ativo)
        VALUES ('Pizza de Brigadeiro', 'Pizza doce com brigadeiro e granulado', categoria_doce_id, 'pizza', 35.00, true);
        RAISE NOTICE 'Pizza de Brigadeiro criada';
    END IF;
    
    -- Atualizar tipo_produto para garantir que todas as pizzas doces estejam marcadas corretamente
    UPDATE produtos 
    SET tipo_produto = 'pizza',
        categoria_id = categoria_doce_id
    WHERE (nome ILIKE '%chocolate%' 
       OR nome ILIKE '%nutella%' 
       OR nome ILIKE '%brigadeiro%' 
       OR nome ILIKE '%romeu%'
       OR nome ILIKE '%banana%' AND nome ILIKE '%canela%')
    AND nome ILIKE '%pizza%';
    
    RAISE NOTICE 'Pizzas doces atualizadas';
    
END $$;

-- Verificar resultado
SELECT 
    p.id,
    p.nome,
    c.nome as categoria,
    p.tipo_produto,
    p.ativo
FROM produtos p
LEFT JOIN categorias c ON p.categoria_id = c.id
WHERE c.nome = 'Pizzas Doces'
ORDER BY p.nome;