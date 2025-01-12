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

-- Agendar backup diário para tabelas críticas
0 20 * * * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_agendamento');"
0 20 * * * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_cliente');"
0 20 * * * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_profissional');"
0 20 * * * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_servico');"
0 20 * * * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_pagamento');"

-- Agendar backup mensal para tabelas não críticas
0 20 1 * * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_logs');"
0 20 1 * * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_feedback');"

-- Agendar backup anual completo
0 0 1 1 * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_agendamento');"
0 0 1 1 * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_cliente');"
0 0 1 1 * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_profissional');"
0 0 1 1 * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_servico');"
0 0 1 1 * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_pagamento');"
0 0 1 1 * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_logs');"
0 0 1 1 * psql -U postgres -d nome_do_banco -c "SELECT backup_database('/path/to/backup/', 'tbl_feedback');"
