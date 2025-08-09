-- Primeiro, verificar se a categoria existe
SELECT * FROM produtos_categoria WHERE nome = 'Pizzas Doces';

-- Se não retornar nada, execute este INSERT:
INSERT INTO produtos_categoria (nome, descricao, ativo)
VALUES ('Pizzas Doces', 'Pizzas doces especiais', true);

-- Verificar novamente
SELECT * FROM produtos_categoria ORDER BY nome;