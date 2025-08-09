-- Verificar os tamanhos no banco
SELECT * FROM produtos_tamanho ORDER BY id;

-- Verificar como estão os dados de uma pizza doce específica
SELECT 
    p.nome as pizza,
    pp.preco,
    pp.tamanho_id,
    t.id as tamanho_table_id,
    t.nome as tamanho_nome
FROM produtos_produto p
JOIN produtos_produtopreco pp ON p.id = pp.produto_id
LEFT JOIN produtos_tamanho t ON pp.tamanho_id = t.id
WHERE p.categoria_id = (SELECT id FROM produtos_categoria WHERE nome = 'Pizzas Doces')
LIMIT 10;