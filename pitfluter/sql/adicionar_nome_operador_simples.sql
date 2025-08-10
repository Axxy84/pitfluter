-- Script SQL CORRIGIDO para adicionar campo nome_operador na tabela caixa
-- Execute este script no Supabase SQL Editor

-- Adicionar coluna nome_operador na tabela caixa
ALTER TABLE caixa
ADD COLUMN IF NOT EXISTS nome_operador VARCHAR(100);

-- Adicionar coluna para registrar quem fechou o caixa (opcional)
ALTER TABLE caixa
ADD COLUMN IF NOT EXISTS nome_operador_fechamento VARCHAR(100);

-- Verificar se as colunas foram adicionadas
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'caixa' 
AND column_name IN ('nome_operador', 'nome_operador_fechamento');