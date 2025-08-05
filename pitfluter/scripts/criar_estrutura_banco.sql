-- 1. Criar tabela de categorias
CREATE TABLE IF NOT EXISTS produtos_categoria (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) UNIQUE NOT NULL,
    descricao TEXT,
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Criar tabela de tamanhos
CREATE TABLE IF NOT EXISTS produtos_tamanho (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL,
    ordem INTEGER DEFAULT 0,
    ativo BOOLEAN DEFAULT true
);

-- 3. Criar tabela de produtos
CREATE TABLE IF NOT EXISTS produtos_produto (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    descricao TEXT,
    categoria_id INTEGER REFERENCES produtos_categoria(id),
    tipo_produto VARCHAR(50) DEFAULT 'pizza',
    preco_unitario DECIMAL(10,2),
    ingredientes TEXT,
    estoque_disponivel INTEGER DEFAULT 0,
    imagem VARCHAR(255),
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Criar tabela de preços por tamanho
CREATE TABLE IF NOT EXISTS produtos_produtopreco (
    id SERIAL PRIMARY KEY,
    produto_id INTEGER REFERENCES produtos_produto(id) ON DELETE CASCADE,
    tamanho_id INTEGER REFERENCES produtos_tamanho(id),
    preco DECIMAL(10,2) NOT NULL,
    preco_promocional DECIMAL(10,2),
    UNIQUE(produto_id, tamanho_id)
);

-- 5. Criar índices para performance
CREATE INDEX idx_produto_categoria ON produtos_produto(categoria_id);
CREATE INDEX idx_produto_ativo ON produtos_produto(ativo);
CREATE INDEX idx_produtopreco_produto ON produtos_produtopreco(produto_id);

-- 6. Agora sim, inserir os dados
-- Categorias
INSERT INTO produtos_categoria (nome, descricao, ativo) VALUES 
('Pizzas Promocionais', 'Pizzas com preço especial - R$ 40,00', true),
('Pizzas Tradicionais', 'Pizzas clássicas do cardápio', true),
('Bebidas', 'Refrigerantes e sucos', true),
('Sobremesas', 'Doces e sobremesas', true),
('Bordas Recheadas', 'Opções de bordas especiais', true);

-- Tamanhos
INSERT INTO produtos_tamanho (nome, ordem, ativo) VALUES
('Broto', 1, true),
('Média', 2, true),
('Grande', 3, true),
('Família', 4, true),
('8 Pedaços', 5, true);

-- Pizzas Promocionais
INSERT INTO produtos_produto (nome, descricao, categoria_id, tipo_produto, ativo, ingredientes) 
SELECT 
    nome,
    descricao,
    (SELECT id FROM produtos_categoria WHERE nome = 'Pizzas Promocionais'),
    'pizza',
    true,
    descricao
FROM (VALUES
    ('Alho Frito', 'Molho, mussarela, alho frito e orégano'),
    ('Atum', 'Molho, mussarela, atum, cebola e orégano'),
    ('Bacon', 'Molho, mussarela, bacon e orégano'),
    ('Baiana', 'Molho, mussarela, calabresa moída, pimenta calabresa, tomate em rodela e orégano'),
    ('Banana Caramelizada', 'Leite condensado, banana caramelizada e canela em pó'),
    ('Baurú', 'Molho, mussarela, presunto, milho verde e orégano'),
    ('Calabresa', 'Molho, mussarela, calabresa, cebola e orégano'),
    ('Frango ao Catupiry', 'Molho, mussarela, peito de frango e orégano'),
    ('Marguerita', 'Molho, mussarela, tomate, manjericão e orégano'),
    ('Luzitana', 'Molho, mussarela, ervilha, ovo, cebola e orégano'),
    ('Milho Verde', 'Molho, mussarela, milho verde e orégano'),
    ('Mussarela', 'Molho, mussarela, tomate em rodela e orégano'),
    ('Portuguesa sem Palmito', 'Molho, mussarela, presunto, cebola, vinagrete, milho verde, ovos, pimentão e orégano'),
    ('Lombo', 'Molho, mussarela, presunto, lombo canadense e orégano'),
    ('Abacaxi Gratinado', 'Leite condensado, mussarela, abacaxi gratinado e canela'),
    ('Romeu e Julieta', 'Leite condensado, mussarela e goiabada')
) AS pizza(nome, descricao);

-- Preços promocionais
INSERT INTO produtos_produtopreco (produto_id, tamanho_id, preco, preco_promocional)
SELECT 
    p.id,
    t.id,
    40.00,
    40.00
FROM produtos_produto p
CROSS JOIN produtos_tamanho t
WHERE p.categoria_id = (SELECT id FROM produtos_categoria WHERE nome = 'Pizzas Promocionais')
AND t.nome = '8 Pedaços';

-- Verificar
SELECT COUNT(*) as total_pizzas FROM produtos_produto;
SELECT COUNT(*) as total_precos FROM produtos_produtopreco;