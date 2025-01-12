DELETE FROM servico WHERE id_servico = 10;

DELETE FROM profissional WHERE id_profissional = 3;

UPDATE servico SET preco_servico = 130.00 WHERE id_servico = 5;

UPDATE profissional SET nm_profissional = 'Maria Silva' WHERE id_profissional = 2;

INSERT INTO servico (id_servico, nm_servico, preco_servico)
VALUES (97, 'Corte de Unhas', 40.00);

INSERT INTO profissional (id_profissional, nm_profissional)
VALUES (6, 'Ana Costa');

INSERT INTO servico_profissional (id_servico, id_profissional)
VALUES (10, 6);

DELETE FROM servico_profissional WHERE id_servico = 15 AND id_profissional = 3;

UPDATE servico SET preco_servico = preco_servico * 0.9 WHERE preco_servico > 100;

DELETE FROM servico WHERE preco_servico < 50;

-- Buscas Simples:

SELECT * FROM servico WHERE preco_servico > 100;

SELECT * FROM profissional;

SELECT * FROM servico WHERE id_servico = 8;

SELECT s.nm_servico, s.preco_servico
FROM servico s
JOIN servico_profissional sp ON s.id_servico = sp.id_servico
WHERE sp.id_profissional = 3;

-- Buscas Intermediárias:

SELECT p.nm_profissional, s.nm_servico
FROM profissional p
JOIN servico_profissional sp ON p.id_profissional = sp.id_profissional
JOIN servico s ON s.id_servico = sp.id_servico
ORDER BY p.nm_profissional;

SELECT AVG(preco_servico) AS preco_medio
FROM servico;

SELECT s.nm_servico, COUNT(sp.id_profissional) AS qtd_profissionais
FROM servico s
LEFT JOIN servico_profissional sp ON s.id_servico = sp.id_servico
WHERE s.preco_servico > 100
GROUP BY s.nm_servico;

-- Buscas Avançadas:

SELECT p.nm_profissional, s.nm_servico, s.preco_servico
FROM profissional p
JOIN servico_profissional sp ON p.id_profissional = sp.id_profissional
JOIN servico s ON s.id_servico = sp.id_servico
WHERE s.preco_servico > 100
ORDER BY s.nm_servico;

SELECT p.nm_profissional, SUM(s.preco_servico) AS soma_precos
FROM profissional p
JOIN servico_profissional sp ON p.id_profissional = sp.id_profissional
JOIN servico s ON s.id_servico = sp.id_servico
GROUP BY p.nm_profissional;

SELECT p.nm_profissional, s.nm_servico
FROM profissional p
JOIN servico_profissional sp ON p.id_profissional = sp.id_profissional
JOIN servico s ON sp.id_servico = s.id_servico
WHERE s.id_servico NOT IN (
    SELECT sp1.id_servico
    FROM servico_profissional sp1
    WHERE sp1.id_profissional != p.id_profissional
);
