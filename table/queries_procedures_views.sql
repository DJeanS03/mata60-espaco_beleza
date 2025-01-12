-- 1. Faturamento mensal por serviço
CREATE OR REPLACE VIEW vw_faturamento_mensal AS
SELECT 
    s.nm_servico,
    DATE_TRUNC('month', p.data_pagamento) AS mes,
    SUM(p.valor_pago) AS total_faturamento
FROM pagamento p
JOIN agendamento a ON p.id_agendamento = a.id_agendamento
JOIN servico s ON a.id_servico = s.id_servico
GROUP BY s.nm_servico, DATE_TRUNC('month', p.data_pagamento)
ORDER BY mes, total_faturamento DESC;

-- 2. Profissionais mais solicitados no mês
CREATE OR REPLACE VIEW vw_profissionais_solicitados AS
SELECT 
    p.nm_profissional,
    DATE_TRUNC('month', a.data_agendamento) AS mes,
    COUNT(*) AS total_atendimentos
FROM agendamento a
JOIN profissional p ON a.id_profissional = p.id_profissional
GROUP BY p.nm_profissional, DATE_TRUNC('month', a.data_agendamento)
ORDER BY mes, total_atendimentos DESC;

--3. Média de avaliação por serviço
CREATE OR REPLACE VIEW vw_media_avaliacao_servicos AS
SELECT 
    s.nm_servico,
    AVG(f.avaliacao) AS media_avaliacao
FROM feedback f
JOIN agendamento a ON f.id_agendamento = a.id_agendamento
JOIN servico s ON a.id_servico = s.id_servico
GROUP BY s.nm_servico
ORDER BY media_avaliacao DESC;

--4. Serviços que geram maior receita
CREATE OR REPLACE VIEW vw_servicos_maior_receita AS
SELECT 
    s.nm_servico,
    SUM(p.valor_pago) AS total_receita
FROM pagamento p
JOIN agendamento a ON p.id_agendamento = a.id_agendamento
JOIN servico s ON a.id_servico = s.id_servico
GROUP BY s.nm_servico
ORDER BY total_receita DESC;

-- 5. Agendamentos cancelados por mês
CREATE OR REPLACE VIEW vw_agendamentos_cancelados AS
SELECT 
    DATE_TRUNC('month', a.data_agendamento) AS mes,
    COUNT(*) AS total_cancelados
FROM agendamento a
WHERE a.status_agendamento = 'Cancelado'
GROUP BY DATE_TRUNC('month', a.data_agendamento)
ORDER BY mes;

-- 6. Insumos consumidos por serviço
CREATE OR REPLACE VIEW vw_insumos_consumidos AS
SELECT 
    s.nm_servico,
    i.nm_insumo,
    SUM(i.quantidade_estoque) AS total_consumido
FROM servico_insumos si
JOIN servico s ON si.id_servico = s.id_servico
JOIN insumos i ON si.id_insumo = i.id_insumo
GROUP BY s.nm_servico, i.nm_insumo
ORDER BY total_consumido DESC;

-- 7. Cliente que mais gera receita
CREATE OR REPLACE VIEW vw_cliente_receita AS
SELECT 
    c.nm_cliente,
    SUM(p.valor_pago) AS receita_total
FROM pagamento p
JOIN cliente c ON p.id_cliente = c.id_cliente
GROUP BY c.nm_cliente
ORDER BY receita_total DESC
LIMIT 1;

--8. Número de serviços realizados por profissional
CREATE OR REPLACE VIEW vw_servicos_por_profissional AS
SELECT 
    p.nm_profissional,
    COUNT(a.id_servico) AS total_servicos
FROM agendamento a
JOIN profissional p ON a.id_profissional = p.id_profissional
GROUP BY p.nm_profissional
ORDER BY total_servicos DESC;

-- 9. Formas de pagamento mais utilizadas
CREATE OR REPLACE VIEW vw_formas_pagamento AS
SELECT 
    p.forma_pagamento,
    COUNT(*) AS total_uso
FROM pagamento p
GROUP BY p.forma_pagamento
ORDER BY total_uso DESC;

--10. Estoque de insumos abaixo do limite mínimo
CREATE OR REPLACE VIEW vw_insumos_criticos AS
SELECT 
    i.nm_insumo,
    i.quantidade_estoque,
    i.quantidade_minima
FROM insumos i
WHERE i.quantidade_estoque < i.quantidade_minima
ORDER BY i.quantidade_estoque ASC;

