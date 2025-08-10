-- Queries úteis para gerenciar a tabela caixa no Supabase
-- A tabela caixa usa data_fechamento para determinar o status:
-- - data_fechamento IS NULL = caixa ABERTO
-- - data_fechamento NOT NULL = caixa FECHADO

-- 1. Verificar se existe caixa aberto
SELECT 
    id,
    data_abertura,
    saldo_inicial,
    nome_operador,
    observacoes,
    'ABERTO' as status
FROM caixa 
WHERE data_fechamento IS NULL 
ORDER BY data_abertura DESC 
LIMIT 1;

-- 2. Ver todos os caixas (com status calculado)
SELECT 
    id,
    data_abertura,
    data_fechamento,
    saldo_inicial,
    saldo_final,
    nome_operador,
    CASE 
        WHEN data_fechamento IS NULL THEN 'ABERTO'
        ELSE 'FECHADO'
    END as status,
    observacoes
FROM caixa 
ORDER BY data_abertura DESC;

-- 3. Ver último caixa (aberto ou fechado)
SELECT 
    *,
    CASE 
        WHEN data_fechamento IS NULL THEN 'ABERTO'
        ELSE 'FECHADO'
    END as status
FROM caixa 
ORDER BY data_abertura DESC 
LIMIT 1;

-- 4. Ver histórico de caixas fechados
SELECT 
    id,
    data_abertura,
    data_fechamento,
    saldo_inicial,
    saldo_final,
    total_vendas,
    total_dinheiro,
    total_cartao,
    total_pix,
    nome_operador,
    nome_operador_fechamento
FROM caixa 
WHERE data_fechamento IS NOT NULL
ORDER BY data_fechamento DESC;

-- 5. Forçar fechamento de caixa aberto (USE COM CUIDADO!)
-- UPDATE caixa 
-- SET 
--     data_fechamento = NOW(),
--     saldo_final = saldo_inicial,
--     nome_operador_fechamento = 'Fechamento Manual'
-- WHERE data_fechamento IS NULL;

-- 6. Ver estrutura completa da tabela caixa
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'caixa'
ORDER BY ordinal_position;

-- 7. Verificar se as colunas nome_operador foram adicionadas
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'caixa'
AND column_name IN ('nome_operador', 'nome_operador_fechamento');

-- 8. Estatísticas do mês atual
SELECT 
    COUNT(*) as total_caixas,
    SUM(total_vendas) as vendas_mes,
    AVG(total_vendas) as media_vendas,
    SUM(total_dinheiro) as total_dinheiro_mes,
    SUM(total_cartao) as total_cartao_mes,
    SUM(total_pix) as total_pix_mes
FROM caixa
WHERE EXTRACT(MONTH FROM data_abertura) = EXTRACT(MONTH FROM CURRENT_DATE)
AND EXTRACT(YEAR FROM data_abertura) = EXTRACT(YEAR FROM CURRENT_DATE)
AND data_fechamento IS NOT NULL;