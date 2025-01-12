-- Exemplo 1: Pagamentos por Cliente
CREATE MATERIALIZED VIEW mv_pagamentos_por_cliente AS
SELECT
    c.nm_cliente AS nm_cliente,
    p.data_pagamento AS data_pagamento,
    p.valor_pago AS valor
FROM
    pagamento p
JOIN
    cliente c ON p.id_cliente = c.id_cliente;

-- Uso: Para consultar pagamentos sem precisar fazer o JOIN repetidamente:
SELECT * FROM mv_pagamentos_por_cliente;

-- Para atualizar os dados armazenados:
REFRESH MATERIALIZED VIEW mv_pagamentos_por_cliente;


-- Exemplo 2: Agendamentos com Status
CREATE MATERIALIZED VIEW mv_agendamentos_status_data AS
SELECT
    a.id_agendamento AS agendamento_id,
    a.status_agendamento AS status,
    a.data_agendamento AS data,
    c.nm_cliente AS nm_cliente
FROM
    agendamento a
JOIN
    cliente c ON a.id_cliente = c.id_cliente;

-- Uso: Facilita a consulta a informações de agendamentos diretamente:
SELECT * FROM mv_agendamentos_status_data WHERE status = 'Concluído';


-- Exemplo 3: Serviços Mais Agendados
CREATE MATERIALIZED VIEW mv_servicos_mais_agendados AS
SELECT
    s.nm_servico AS servico,
    COUNT(a.id_agendamento) AS total_agendamentos
FROM
    agendamento a
JOIN
    servico s ON a.id_servico = s.id_servico
GROUP BY s.nm_servico
ORDER BY total_agendamentos DESC;

-- Uso: Para verificar quais serviços são mais demandados:
SELECT * FROM mv_servicos_mais_agendados LIMIT 5;


