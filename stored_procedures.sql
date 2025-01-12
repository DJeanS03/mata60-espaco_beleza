-- Exemplo 1: Atualizar Status de Agendamento
CREATE OR REPLACE PROCEDURE atualizar_status_agendamento(p_id_agendamento INT, p_novo_status VARCHAR)
AS $$
BEGIN
    UPDATE agendamento
    SET status_agendamento = p_novo_status
    WHERE id_agendamento = p_id_agendamento;
END;
$$ LANGUAGE plpgsql;

-- Uso:
CALL atualizar_status_agendamento(101, 'Concluído');


-- Exemplo 2: Inserir Novo Cliente
CREATE OR REPLACE PROCEDURE inserir_cliente(
    p_id_cliente INT,
    p_nm_cliente VARCHAR,
    p_telefone_cliente VARCHAR,
    p_email_cliente VARCHAR
)
AS $$
BEGIN
    INSERT INTO cliente (id_cliente, nm_cliente, telefone_cliente, email_cliente)
    VALUES (p_id_cliente, p_nm_cliente, p_telefone_cliente, p_email_cliente);
END;
$$ LANGUAGE plpgsql;

-- Uso:
CALL inserir_cliente(999, 'João Silva', '123456789', 'joao@email.com');


-- Exemplo 3: Calcular Total Pago por Cliente
CREATE OR REPLACE PROCEDURE calcular_total_pago(p_id_cliente INT, OUT total_pago DECIMAL)
AS $$
BEGIN
    SELECT SUM(valor_pago)
    INTO total_pago
    FROM pagamento
    WHERE id_cliente = p_id_cliente;
END;
$$ LANGUAGE plpgsql;

-- Uso:
DO $$
DECLARE
    total DECIMAL;
BEGIN
    CALL calcular_total_pago(1, total);
    RAISE NOTICE 'Total Pago: %', total;
END;
$$;

-- Exemplo 4: Deletar Agendamentos Antigos
CREATE OR REPLACE PROCEDURE deletar_agendamentos_antigos(p_data_limite DATE)
AS $$
BEGIN
    DELETE FROM agendamento
    WHERE data_agendamento < p_data_limite;
END;
$$ LANGUAGE plpgsql;

-- Uso:
CALL deletar_agendamentos_antigos('2024-01-01');
