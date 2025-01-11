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


-- Criar procedimento armazenado para backup completo
CREATE PROCEDURE sp_BackupDatabase 
    @BackupPath nvarchar(260),
    @DatabaseName nvarchar(128)
AS
BEGIN
    DECLARE @DeviceName nvarchar(260);
    SET @DeviceName = @BackupPath + @DatabaseName + '.bak';

    -- Criar backup completo da base de dados
    BACKUP DATABASE @DatabaseName TO DISK = @DeviceName;
END

-- Criar procedimento armazenado para restauração
CREATE PROCEDURE sp_RestoreDatabase 
    @BackupPath nvarchar(260),
    @DatabaseName nvarchar(128)
AS
BEGIN
    DECLARE @DeviceName nvarchar(260);
    SET @DeviceName = @BackupPath + @DatabaseName + '.bak';

    -- Restaurar base de dados do backup
    RESTORE DATABASE @DatabaseName 
    FROM DISK = @DeviceName;
END

-- Criar política de backup com diferentes frequências
CREATE POLICY sp_BackupPolicy
FOR DATABASE [SeuNomeDaBase]
WITH (
    BACKUP_FREQUENCY = 'DAILY' FOR 
        ['agendamento', 'pagamento', 'insumos'],
    BACKUP_FREQUENCY = 'MONTHLY' FOR 
        ['cliente', 'profissional', 'servico', 'feedback']
);

-- Configurar tarefas de backup programadas
EXEC msdb.dbo.sp_add_schedule 
    @schedule_name='BackupSchedule',
    @freq_type=4,
    @freq_interval=1,
    @active_start_time='08:00';

EXEC msdb.dbo.sp_attach_schedule 
    @schedule_name='BackupSchedule',
    @job_name='BackupJob';

-- Criar tarefa de backup para bancos diários
EXEC msdb.dbo.sp_add_jobstep 
    @job_name='BackupJob',
    @step_name='DailyBackupStep',
    @subsystem='TSQL',
    @command=N'
BEGIN
    EXEC sp_BackupDatabase ''C:\Path\To\Backup\Folder\', ''agendamento'';
    EXEC sp_BackupDatabase ''C:\Path\To\Backup\Folder\', ''pagamento'';  
    EXEC sp_BackupDatabase ''C:\Path\To\Backup\Folder\', ''insumos'';  
END
';

-- Criar tarefa de backup para bancos mensais
EXEC msdb.dbo.sp_add_jobstep 
    @job_name='BackupJob',
    @step_name='MonthlyBackupStep',
    @subsystem='TSQL',
    @command=N'
BEGIN
    EXEC sp_BackupDatabase ''C:\Path\To\Backup\Folder\', ''cliente'';  
    EXEC sp_BackupDatabase ''C:\Path\To\Backup\Folder\', ''profissional'';  
    EXEC sp_BackupDatabase ''C:\Path\To\Backup\Folder\', ''servico'';  
    EXEC sp_BackupDatabase ''C:\Path\To\Backup\Folder\', ''feedback'';  
END
';

-- Configurar retentativa
EXEC msdb.dbo.sp_add_retries @job_name='BackupJob', @retries=3;

-- Configurar alertas de backup
EXEC msdb.dbo.sp_add_alert 
    @name=N'Remote Backup Alert',
    @message_id=-1,
    @severity=16,
    @enabled=true,
    @delay_between_responses=300,
    @include_eventid=FALSE,
    @operators=N'SQLServer:SQLServerOperatorRole',
    @alert_category_name=N'REMOTEBACKUP',
    @alert_description=N'Remote backup failed',
    @alert_message_source=N'DATABASEMail',
    @email_address=N'databasealerts@yourdomain.com';

-- Criar teste de recuperação
CREATE PROCEDURE sp_TestRecovery
    @DatabaseName nvarchar(128),
    @BackupPath nvarchar(260)
AS
BEGIN
    DECLARE @DeviceName nvarchar(260);
    SET @DeviceName = @BackupPath + @DatabaseName + '.bak';

    -- Executar teste de recuperação
    EXEC sp_RestoreDatabase @BackupPath, @DatabaseName;
END
