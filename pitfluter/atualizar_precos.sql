-- Atualizar preços dos produtos que estão NULL
-- Execute este SQL no Supabase SQL Editor

-- 1. Pizzas Tradicionais (preço padrão R$ 45,00)
UPDATE produtos_produto 
SET preco_unitario = 45.00 
WHERE preco_unitario IS NULL 
  AND tipo_produto = 'pizza' 
  AND categoria_id IN (
    SELECT id FROM produtos_categoria 
    WHERE nome LIKE '%Tradicional%'
  );

-- 2. Pizzas Promocionais (preço padrão R$ 35,00)
UPDATE produtos_produto 
SET preco_unitario = 35.00 
WHERE preco_unitario IS NULL 
  AND tipo_produto = 'pizza' 
  AND categoria_id IN (
    SELECT id FROM produtos_categoria 
    WHERE nome LIKE '%Promocional%'
  );

-- 3. Pizza Delivery (preço padrão R$ 40,00)
UPDATE produtos_produto 
SET preco_unitario = 40.00 
WHERE preco_unitario IS NULL 
  AND tipo_produto = 'pizza' 
  AND categoria_id IN (
    SELECT id FROM produtos_categoria 
    WHERE nome LIKE '%Delivery%'
  );

-- 4. Bordas Recheadas (preço padrão R$ 15,00)
UPDATE produtos_produto 
SET preco_unitario = 15.00 
WHERE preco_unitario IS NULL 
  AND (tipo_produto = 'borda' OR categoria_id IN (
    SELECT id FROM produtos_categoria 
    WHERE nome LIKE '%Borda%'
  ));

-- 5. Bebidas (preço padrão R$ 8,00)
UPDATE produtos_produto 
SET preco_unitario = 8.00 
WHERE preco_unitario IS NULL 
  AND (tipo_produto IN ('bebida', 'refrigerante', 'suco') 
    OR categoria_id IN (
      SELECT id FROM produtos_categoria 
      WHERE nome LIKE '%Bebida%'
    ));

-- 6. Sobremesas (preço padrão R$ 12,00)
UPDATE produtos_produto 
SET preco_unitario = 12.00 
WHERE preco_unitario IS NULL 
  AND categoria_id IN (
    SELECT id FROM produtos_categoria 
    WHERE nome LIKE '%Sobremesa%'
  );

-- 7. Qualquer pizza sem preço ainda (preço padrão R$ 40,00)
UPDATE produtos_produto 
SET preco_unitario = 40.00 
WHERE preco_unitario IS NULL 
  AND tipo_produto = 'pizza';

-- 8. Qualquer outro produto sem preço (preço padrão R$ 10,00)
UPDATE produtos_produto 
SET preco_unitario = 10.00 
WHERE preco_unitario IS NULL;

-- Verificar resultados
SELECT 
  pp.nome,
  pp.preco_unitario,
  pp.tipo_produto,
  pc.nome as categoria
FROM produtos_produto pp
LEFT JOIN produtos_categoria pc ON pp.categoria_id = pc.id
ORDER BY pc.nome, pp.nome;