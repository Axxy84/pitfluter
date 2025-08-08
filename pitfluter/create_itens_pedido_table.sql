-- Criar tabela itens_pedido
CREATE TABLE IF NOT EXISTS itens_pedido (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL,
    produto_id INTEGER NOT NULL,
    quantidade INTEGER NOT NULL DEFAULT 1,
    preco_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    observacoes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Foreign key apenas para pedidos
    CONSTRAINT fk_pedido FOREIGN KEY (pedido_id) 
        REFERENCES pedidos(id) ON DELETE CASCADE
);

-- Criar índices
CREATE INDEX IF NOT EXISTS idx_itens_pedido_pedido_id ON itens_pedido(pedido_id);
CREATE INDEX IF NOT EXISTS idx_itens_pedido_produto_id ON itens_pedido(produto_id);

-- Trigger para atualizar updated_at
CREATE TRIGGER update_itens_pedido_updated_at BEFORE UPDATE
    ON itens_pedido FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();