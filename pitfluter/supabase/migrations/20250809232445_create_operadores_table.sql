CREATE TABLE IF NOT EXISTS operadores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE,
    email VARCHAR(255),
    senha_hash VARCHAR(255),
    nivel_acesso VARCHAR(20) DEFAULT 'operador' CHECK (nivel_acesso IN ('admin', 'gerente', 'operador')),
    ativo BOOLEAN DEFAULT true,
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ultimo_login TIMESTAMP WITH TIME ZONE,
    created_by INTEGER,
    observacoes TEXT
);

-- Adicionar índices
CREATE INDEX IF NOT EXISTS idx_operadores_nome ON operadores(nome);
CREATE INDEX IF NOT EXISTS idx_operadores_cpf ON operadores(cpf);
CREATE INDEX IF NOT EXISTS idx_operadores_ativo ON operadores(ativo);

-- Inserir operadores padrão
INSERT INTO operadores (nome, nivel_acesso, ativo, observacoes) 
VALUES ('Administrador', 'admin', true, 'Operador padrão do sistema')
ON CONFLICT DO NOTHING;

INSERT INTO operadores (nome, nivel_acesso, ativo) VALUES 
    ('João Silva', 'operador', true),
    ('Maria Santos', 'gerente', true)
ON CONFLICT DO NOTHING;

-- Configurar RLS
ALTER TABLE operadores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir leitura de operadores" ON operadores FOR SELECT USING (true);
CREATE POLICY "Permitir inserção de operadores" ON operadores FOR INSERT WITH CHECK (true);
CREATE POLICY "Permitir atualização de operadores" ON operadores FOR UPDATE USING (true);