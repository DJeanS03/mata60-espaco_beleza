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
