-- -----------------------------------------------------
-- 03_teste.sql
-- Inserts de Exemplo para Teste
-- -----------------------------------------------------

-- 1. Cadastrar um Doador (ID automático)
INSERT INTO doador (nome, data_nascimento, peso, sexo)
VALUES ('Doador Teste', '1985-03-10', 82.00, 'masculino');

-- 2. Cadastrar um Fornecedor
INSERT INTO fornecedor (nome, data_cadastro, status, email)
VALUES ('Hospital Santa Casa', CURDATE(), 'ativo', 'contato@santacasa.com');

-- 3. Cadastrar dois Compradores
INSERT INTO comprador (nome, sexo, data_cadastro, data_nascimento)
VALUES ('João Silva', 'masculino', CURDATE(), '1980-01-01');

INSERT INTO comprador (nome, sexo, data_cadastro, data_nascimento)
VALUES ('Maria Souza', 'feminino', CURDATE(), '1990-05-15');

-- 4. Inserir um Órgão (Rim)
-- Ajuste os IDs (fornecedor, doador) conforme gerado acima.
-- Assumindo aqui que são os primeiros registros (ID 1)
INSERT INTO orgaos (id_fornecedor, id_doador, nome_orgao, data_entrada, tipo_sanguineo, condicao_do_orgao, data_validade, valor)
VALUES (1, 1, 'Rim Esquerdo', CURDATE(), 'O+', 'Excelente', DATE_ADD(CURDATE(), INTERVAL 10 DAY), 50000.00);

-- 5. Criar Cotações (Lances)
-- Comprador 1 oferece
INSERT INTO cotacao (id_orgao, id_comprador, valor)
VALUES (1, 1, 52000.00);

-- Comprador 2 oferece mais
INSERT INTO cotacao (id_orgao, id_comprador, valor)
VALUES (1, 2, 55000.00);

-- 6. Fechar Venda (Transação)
-- Vamos fechar a venda para a cotação 2 (Comprador 2)
-- Isso deve disparar a trigger que cancela a cotação 1
INSERT INTO transacao (id_cotacao, id_comprador, status)
VALUES (2, 2, 'concluida');

-- 7. Verificar Resultados
SELECT * FROM cotacao; -- A cotação 1 deve estar 'cancelada' e a 2 'finalizada'
SELECT * FROM log_cotacao; -- Deve ter o histórico das mudanças