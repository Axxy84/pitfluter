-- Script SQL para adicionar campo nome_operador na tabela caixa
-- Execute este script no Supabase SQL Editor

-- 1. Adicionar coluna nome_operador na tabela caixa
ALTER TABLE caixa
ADD COLUMN IF NOT EXISTS nome_operador VARCHAR(100);

-- 2. Adicionar comentário descritivo na coluna
COMMENT ON COLUMN caixa.nome_operador IS 'Nome do operador que abriu o caixa';

-- 3. Atualizar registros existentes com um valor padrão (opcional)
UPDATE caixa
SET nome_operador = 'Operador Padrão'
WHERE nome_operador IS NULL AND data_abertura IS NOT NULL;

-- 4. Criar índice para melhorar performance de buscas por operador (opcional)
CREATE INDEX IF NOT EXISTS idx_caixa_nome_operador 
ON caixa(nome_operador);

-- 5. Adicionar coluna para registrar quem fechou o caixa também (opcional mas recomendado)
ALTER TABLE caixa
ADD COLUMN IF NOT EXISTS nome_operador_fechamento VARCHAR(100);

COMMENT ON COLUMN caixa.nome_operador_fechamento IS 'Nome do operador que fechou o caixa';

-- 6. Visualizar estrutura atualizada da tabela (para conferência)
-- SELECT 
--     column_name,
--     data_type,
--     character_maximum_length,
--     is_nullable,
--     column_default
-- FROM information_schema.columns
-- WHERE table_name = 'caixa'
-- ORDER BY ordinal_position;

-- 7. Exemplo de como ficaria uma inserção com o novo campo:
-- INSERT INTO caixa (
--     data_abertura, 
--     saldo_inicial, 
--     observacoes_abertura,
--     nome_operador
-- ) VALUES (
--     NOW(), 
--     100.00, 
--     'Abertura de caixa do dia',
--     'João Silva'
-- );

-- NOTA: Este script corrige o nome da tabela para 'caixa' (singular)
-- Após executar este script, o código Flutter já está preparado para:
-- 1. Salvar o nome_operador ao abrir o caixa
-- 2. Exibir o nome do operador nas telas de caixa
-- 3. Registrar quem fechou o caixa (campo nome_operador_fechamento)