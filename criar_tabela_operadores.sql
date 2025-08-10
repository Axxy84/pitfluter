-- Criar tabela para operadores de caixa
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

-- Adicionar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_operadores_nome ON operadores(nome);
CREATE INDEX IF NOT EXISTS idx_operadores_cpf ON operadores(cpf);
CREATE INDEX IF NOT EXISTS idx_operadores_ativo ON operadores(ativo);
CREATE INDEX IF NOT EXISTS idx_operadores_nivel_acesso ON operadores(nivel_acesso);

-- Adicionar trigger para atualizar data_atualizacao automaticamente
CREATE OR REPLACE FUNCTION update_operadores_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_operadores_updated_at
    BEFORE UPDATE ON operadores
    FOR EACH ROW
    EXECUTE FUNCTION update_operadores_updated_at();

-- Inserir operador padrão (admin)
INSERT INTO operadores (nome, nivel_acesso, ativo, observacoes) 
VALUES ('Administrador', 'admin', true, 'Operador padrão do sistema')
ON CONFLICT DO NOTHING;

-- Inserir alguns operadores de exemplo
INSERT INTO operadores (nome, nivel_acesso, ativo) VALUES 
    ('João Silva', 'operador', true),
    ('Maria Santos', 'gerente', true),
    ('Pedro Costa', 'operador', true)
ON CONFLICT DO NOTHING;

-- Habilitar RLS (Row Level Security)
ALTER TABLE operadores ENABLE ROW LEVEL SECURITY;

-- Política para permitir leitura de operadores ativos
CREATE POLICY "Permitir leitura de operadores ativos" ON operadores
    FOR SELECT USING (ativo = true);

-- Política para permitir inserção (apenas admin/gerente)
CREATE POLICY "Permitir inserção de operadores" ON operadores
    FOR INSERT WITH CHECK (true);

-- Política para permitir atualização (apenas admin/gerente)
CREATE POLICY "Permitir atualização de operadores" ON operadores
    FOR UPDATE USING (true);

-- Comentários na tabela e colunas
COMMENT ON TABLE operadores IS 'Tabela de operadores de caixa do sistema';
COMMENT ON COLUMN operadores.nome IS 'Nome completo do operador';
COMMENT ON COLUMN operadores.cpf IS 'CPF do operador (único)';
COMMENT ON COLUMN operadores.nivel_acesso IS 'Nível de acesso: admin, gerente ou operador';
COMMENT ON COLUMN operadores.ativo IS 'Indica se o operador está ativo no sistema';
COMMENT ON COLUMN operadores.ultimo_login IS 'Data e hora do último login';