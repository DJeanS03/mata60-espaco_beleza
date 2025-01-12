CREATE TABLE cliente (
    id_cliente INT,
    nm_cliente VARCHAR(255),
    telefone_cliente VARCHAR(20),
    email_cliente VARCHAR(255)
);

CREATE TABLE profissional (
    id_profissional INT,
    especializacao VARCHAR(255),
    nm_profissional VARCHAR(255),
    telefone_profissional VARCHAR(20),
    email_profissional VARCHAR(255)
);

CREATE TABLE servico (
    id_servico INT,
    nm_servico VARCHAR(255),
    preco_servico DECIMAL(10, 2)
);

CREATE TABLE insumos (
    id_insumo INT,
    nm_insumo VARCHAR(255),
    quantidade_estoque INT,
    quantidade_minima INT,
    id_fornecedor INT
);

CREATE TABLE agendamento (
    id_agendamento INT,
    status_agendamento VARCHAR(50),
    data_agendamento DATE,
    id_servico INT,
    id_profissional INT,
    id_cliente INT
);

CREATE TABLE pagamento (
    id_pagamento INT,
    id_agendamento INT,
    id_cliente INT,
    valor_pago DECIMAL(10, 2),
    data_pagamento DATE,
    forma_pagamento VARCHAR(50),
    parcelas_cartao INT
);

CREATE TABLE feedback (
    id_feedback INT,
    id_agendamento INT,
    avaliacao INT,
    comentario TEXT
);

CREATE TABLE servico_insumos (
    id_servico INT,
    id_insumo INT,
    preco DECIMAL(10, 2),
    data_compra DATE
);

CREATE TABLE servico_profissional (
    id_servico INT,
    id_profissional INT
);

ALTER TABLE cliente ADD CONSTRAINT PK_cliente PRIMARY KEY (id_cliente);
ALTER TABLE profissional ADD CONSTRAINT PK_profissional PRIMARY KEY (id_profissional);
ALTER TABLE servico ADD CONSTRAINT PK_servico PRIMARY KEY (id_servico);
ALTER TABLE agendamento ADD CONSTRAINT PK_agendamento PRIMARY KEY (id_agendamento);
ALTER TABLE pagamento ADD CONSTRAINT PK_pagamento PRIMARY KEY (id_pagamento);
ALTER TABLE feedback ADD CONSTRAINT PK_feedback PRIMARY KEY (id_feedback);

ALTER TABLE agendamento ADD CONSTRAINT FK_agendamento_servico FOREIGN KEY (id_servico) REFERENCES servico(id_servico);
ALTER TABLE agendamento ADD CONSTRAINT FK_agendamento_profissional FOREIGN KEY (id_profissional) REFERENCES profissional(id_profissional);
ALTER TABLE agendamento ADD CONSTRAINT FK_agendamento_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);
ALTER TABLE pagamento ADD CONSTRAINT FK_pagamento_agendamento FOREIGN KEY (id_agendamento) REFERENCES agendamento(id_agendamento);
ALTER TABLE pagamento ADD CONSTRAINT FK_pagamento_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente);

CREATE INDEX idx_cliente_telefone ON cliente(telefone_cliente);
CREATE INDEX idx_cliente_email ON cliente(email_cliente);
CREATE INDEX idx_agendamento_data ON agendamento(data_agendamento);
CREATE INDEX idx_agendamento_status ON agendamento(status_agendamento);
CREATE INDEX idx_pagamento_data ON pagamento(data_pagamento);
CREATE INDEX idx_pagamento_forma ON pagamento(forma_pagamento);


--================================================Backup==========================================================

-- Criar uma função para executar o backup
CREATE OR REPLACE FUNCTION backup_database(backup_path TEXT, database_name TEXT)
RETURNS VOID AS $$
DECLARE
    command TEXT;
BEGIN
    command := 'pg_dump -Fc -U postgres -d ' || database_name || ' -f ' || backup_path || database_name || '.backup';

    PERFORM dblink_exec('dbname=' || current_database(), command);
END;
$$ LANGUAGE plpgsql;

-- Criar uma função para restaurar um banco de dados
CREATE OR REPLACE FUNCTION restore_database(backup_path TEXT, database_name TEXT)
RETURNS VOID AS $$
DECLARE
    command TEXT;
BEGIN
    PERFORM pg_terminate_backend(pid)
    FROM pg_stat_activity
    WHERE datname = database_name AND pid <> pg_backend_pid();

    command := 'pg_restore -U postgres -d ' || database_name || ' -c -v ' || backup_path || database_name || '.backup';

    -- Executar o comando
    PERFORM dblink_exec('dbname=' || current_database(), command);
END;
$$ LANGUAGE plpgsql;

# Agendar backup diário para tabelas críticas
0 20 * * * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_agendamento');"
0 20 * * * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_cliente');"
0 20 * * * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_profissional');"
0 20 * * * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_servico');"
0 20 * * * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_pagamento');"

# Agendar backup mensal para tabelas não críticas
0 20 1 * * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_logs');"
0 20 1 * * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_feedback');"

# Agendar backup anual completo
0 0 1 1 * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_agendamento');"
0 0 1 1 * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_cliente');"
0 0 1 1 * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_profissional');"
0 0 1 1 * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_servico');"
0 0 1 1 * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_pagamento');"
0 0 1 1 * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_logs');"
0 0 1 1 * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_feedback');"
