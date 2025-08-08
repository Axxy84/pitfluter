-- Criar tabela mesas
CREATE TABLE IF NOT EXISTS mesas (
    id SERIAL PRIMARY KEY,
    numero INTEGER NOT NULL UNIQUE,
    capacidade INTEGER DEFAULT 4,
    ocupada BOOLEAN DEFAULT false,
    observacoes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Criar índice para busca rápida
CREATE INDEX IF NOT EXISTS idx_mesas_ocupada ON mesas(ocupada);
CREATE INDEX IF NOT EXISTS idx_mesas_numero ON mesas(numero);

-- Inserir algumas mesas de exemplo (1 a 20)
INSERT INTO mesas (numero, capacidade, ocupada) VALUES
    (1, 4, false),
    (2, 4, false),
    (3, 4, false),
    (4, 4, false),
    (5, 6, false),
    (6, 6, false),
    (7, 4, false),
    (8, 4, false),
    (9, 4, false),
    (10, 8, false),
    (11, 4, false),
    (12, 4, false),
    (13, 4, false),
    (14, 4, false),
    (15, 6, false),
    (16, 6, false),
    (17, 4, false),
    (18, 4, false),
    (19, 4, false),
    (20, 8, false)
ON CONFLICT (numero) DO NOTHING;

-- Criar trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_mesas_updated_at BEFORE UPDATE
    ON mesas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();