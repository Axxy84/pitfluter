-- Verificar se as pizzas doces foram adicionadas com os tamanhos

-- 1. Verificar a categoria
SELECT * FROM produtos_categoria WHERE nome = 'Pizzas Doces';

-- 2. Verificar os tamanhos disponíveis
SELECT * FROM produtos_tamanho ORDER BY id;

-- 3. Verificar as pizzas doces cadastradas
SELECT 
    p.id,
    p.nome,
    p.descricao,
    p.ativo
FROM produtos_produto p
WHERE p.categoria_id = (SELECT id FROM produtos_categoria WHERE nome = 'Pizzas Doces')
ORDER BY p.nome;

-- 4. Verificar os preços com tamanhos para as pizzas doces
SELECT 
    p.nome as pizza,
    t.nome as tamanho,
    pp.preco
FROM produtos_produto p
LEFT JOIN produtos_produtopreco pp ON p.id = pp.produto_id
LEFT JOIN produtos_tamanho t ON pp.tamanho_id = t.id
WHERE p.categoria_id = (SELECT id FROM produtos_categoria WHERE nome = 'Pizzas Doces')
ORDER BY p.nome, t.id;

-- 5. Contar quantos preços cada pizza tem
SELECT 
    p.nome,
    COUNT(pp.id) as qtd_precos
FROM produtos_produto p
LEFT JOIN produtos_produtopreco pp ON p.id = pp.produto_id
WHERE p.categoria_id = (SELECT id FROM produtos_categoria WHERE nome = 'Pizzas Doces')
GROUP BY p.nome
ORDER BY p.nome;