

-- ================================================================================================================================================================================================
-- 1. Anonimização de Dados Sensíveis
-- Criar função para anonimizar dados sensíveis
CREATE OR REPLACE FUNCTION anonimizar_dados(valor TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN '****' || RIGHT(valor, 4); 
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW vw_cliente_restrito AS
SELECT 
    id_cliente,
    nm_cliente,
    anonimizar_dados(telefone_cliente) AS telefone_cliente,
    anonimizar_dados(email_cliente) AS email_cliente
FROM cliente;

CREATE OR REPLACE VIEW vw_profissional_restrito AS
SELECT 
    id_profissional,
    nm_profissional,
    especializacao,
    anonimizar_dados(telefone_profissional) AS telefone_profissional,
    anonimizar_dados(email_profissional) AS email_profissional
FROM profissional;

CREATE OR REPLACE VIEW vw_pagamento_restrito AS
SELECT 
    id_pagamento,
    anonimizar_dados(CAST(id_cliente AS TEXT)) AS id_cliente,
    anonimizar_dados(CAST(valor_pago AS TEXT)) AS valor_pago,
    data_pagamento,
    forma_pagamento,
    parcelas_cartao
FROM pagamento;

--================================================================

--2. Controle de Acesso
-- Criar roles, se ainda não existirem
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'assistentes') THEN
        CREATE ROLE assistentes;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'administradores') THEN
        CREATE ROLE administradores;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'gerentes') THEN
        CREATE ROLE gerentes;
    END IF;
END;
$$;

-- Revogar permissões padrão
REVOKE ALL ON cliente FROM PUBLIC;
REVOKE ALL ON profissional FROM PUBLIC;
REVOKE ALL ON pagamento FROM PUBLIC;

-- Conceder permissões específicas para assistentes
GRANT SELECT ON vw_cliente_restrito TO assistentes;
GRANT SELECT ON vw_profissional_restrito TO assistentes;
GRANT SELECT ON vw_pagamento_restrito TO assistentes;

-- Conceder permissões totais para administradores e gerentes
GRANT ALL ON ALL TABLES IN SCHEMA public TO administradores;
GRANT ALL ON ALL TABLES IN SCHEMA public TO gerentes;

-- Conceder permiss
GRANT SELECT ON vw_cliente_restrito TO assistentes;
GRANT SELECT ON vw_profissional_restrito TO assistentes;
GRANT SELECT ON vw_pagamento_restrito TO assistentes;

--================================================================

-- Conceder permissões específicas para assistentes
REVOKE ALL ON cliente FROM PUBLIC;
REVOKE ALL ON profissional FROM PUBLIC;
REVOKE ALL ON pagamento FROM PUBLIC;

GRANT SELECT ON vw_cliente_restrito TO assistentes;
GRANT SELECT ON vw_profissional_restrito TO assistentes;
GRANT SELECT ON vw_pagamento_restrito TO assistentes;

-- Conceder permissões totais para administradores e gerentes
GRANT ALL ON ALL TABLES IN SCHEMA public TO administradores;
GRANT ALL ON ALL TABLES IN SCHEMA public TO gerentes;

