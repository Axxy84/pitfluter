-- Verificar estrutura de tabelas de caixa
-- Execute no Supabase SQL Editor

-- 1. Verificar tabelas relacionadas a caixa
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND (table_name LIKE '%caixa%' 
       OR table_name LIKE '%movimento%'
       OR table_name LIKE '%sangria%')
ORDER BY table_name;

-- 2. Se a tabela de caixa não existir, criar estrutura básica
CREATE TABLE IF NOT EXISTS caixa (
    id SERIAL PRIMARY KEY,
    data_abertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_fechamento TIMESTAMP,
    saldo_inicial DECIMAL(10,2) NOT NULL DEFAULT 0,
    saldo_final DECIMAL(10,2),
    total_vendas DECIMAL(10,2) DEFAULT 0,
    total_dinheiro DECIMAL(10,2) DEFAULT 0,
    total_cartao DECIMAL(10,2) DEFAULT 0,
    total_pix DECIMAL(10,2) DEFAULT 0,
    total_sangrias DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'aberto',
    observacoes TEXT,
    usuario_abertura VARCHAR(100),
    usuario_fechamento VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Criar tabela de movimentos se não existir
CREATE TABLE IF NOT EXISTS movimentos_caixa (
    id SERIAL PRIMARY KEY,
    caixa_id INTEGER REFERENCES caixa(id),
    tipo VARCHAR(50) NOT NULL, -- entrada, saida, sangria, suprimento
    forma_pagamento VARCHAR(50), -- dinheiro, cartao, pix
    valor DECIMAL(10,2) NOT NULL,
    descricao TEXT,
    pedido_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Verificar se existe caixa aberto (data_fechamento NULL significa caixa aberto)
SELECT * FROM caixa 
WHERE data_fechamento IS NULL 
ORDER BY data_abertura DESC 
LIMIT 1;

-- 5. Verificar últimos movimentos
SELECT * FROM movimentos_caixa 
ORDER BY created_at DESC 
LIMIT 10;