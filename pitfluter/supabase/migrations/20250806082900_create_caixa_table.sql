-- Criar tabela de caixa
CREATE TABLE IF NOT EXISTS caixa (
  id SERIAL PRIMARY KEY,
  data_abertura TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  data_fechamento TIMESTAMP WITH TIME ZONE,
  saldo_inicial DECIMAL(10, 2) NOT NULL DEFAULT 0,
  saldo_final DECIMAL(10, 2),
  total_vendas DECIMAL(10, 2),
  total_dinheiro DECIMAL(10, 2),
  total_cartao DECIMAL(10, 2),
  total_pix DECIMAL(10, 2),
  usuario_id INTEGER,
  observacoes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Adicionar índice para buscar caixas abertos rapidamente
CREATE INDEX idx_caixa_aberto ON caixa(data_fechamento) WHERE data_fechamento IS NULL;

-- Adicionar índice para ordenação por data de abertura
CREATE INDEX idx_caixa_data_abertura ON caixa(data_abertura DESC);

-- Comentário na tabela
COMMENT ON TABLE caixa IS 'Tabela para controle de abertura e fechamento de caixa';

-- Comentários nas colunas
COMMENT ON COLUMN caixa.data_abertura IS 'Data e hora de abertura do caixa';
COMMENT ON COLUMN caixa.data_fechamento IS 'Data e hora de fechamento do caixa (NULL = caixa aberto)';
COMMENT ON COLUMN caixa.saldo_inicial IS 'Valor inicial do caixa';
COMMENT ON COLUMN caixa.saldo_final IS 'Valor final do caixa no fechamento';
COMMENT ON COLUMN caixa.total_vendas IS 'Total de vendas no período';
COMMENT ON COLUMN caixa.total_dinheiro IS 'Total recebido em dinheiro';
COMMENT ON COLUMN caixa.total_cartao IS 'Total recebido em cartão';
COMMENT ON COLUMN caixa.total_pix IS 'Total recebido via PIX';
COMMENT ON COLUMN caixa.usuario_id IS 'ID do usuário que abriu o caixa';
COMMENT ON COLUMN caixa.observacoes IS 'Observações sobre o caixa';