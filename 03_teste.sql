-- -----------------------------------------------------
-- 03_teste.sql
-- Ensaio Completo: Inserts, Updates, Deletes, Selects
-- -----------------------------------------------------

-- =============================================
-- PARTE 1: INSERÇÃO DE DADOS (INSERTS)
-- =============================================

-- 1. Cadastrar Doadores usando Procedure
CALL cadastrar_doador('Doador Teste 1', '1985-03-10', 82.00, 'masculino');
CALL cadastrar_doador('Maria Doadora', '1978-07-15', 65.50, 'feminino');
CALL cadastrar_doador('Carlos Santos', '1990-11-22', 78.30, 'masculino');

-- 2. Cadastrar Fornecedores
INSERT INTO fornecedor (nome, data_cadastro, status, email, telefone)
VALUES ('Hospital Santa Casa', CURDATE(), 'ativo', 'contato@santacasa.com', '(51) 3333-4444');

INSERT INTO fornecedor (nome, data_cadastro, status, email, telefone)
VALUES ('Hospital Moinhos de Vento', CURDATE(), 'ativo', 'orgaos@moinhos.com.br', '(51) 3314-3000');

-- 3. Cadastrar Compradores usando Procedure
CALL cadastro_comprador(NULL, 'João Silva', 'masculino', CURDATE(), '1980-01-01');
CALL cadastro_comprador(NULL, 'Maria Souza', 'feminino', CURDATE(), '1990-05-15');
CALL cadastro_comprador(NULL, 'Pedro Costa', 'masculino', CURDATE(), '1975-08-30');

-- 4. Inserir Órgãos
INSERT INTO orgaos (id_fornecedor, id_doador, nome_orgao, data_entrada, tipo_sanguineo, condicao_do_orgao, data_validade, valor)
VALUES 
(1, 1, 'Rim Esquerdo', CURDATE(), 'O+', 'Excelente', DATE_ADD(CURDATE(), INTERVAL 10 DAY), 50000.00),
(1, 2, 'Fígado', CURDATE(), 'A+', 'Bom', DATE_ADD(CURDATE(), INTERVAL 5 DAY), 120000.00),
(2, 3, 'Coração', CURDATE(), 'B-', 'Excelente', DATE_ADD(CURDATE(), INTERVAL 8 DAY), 200000.00),
(1, 1, 'Rim Direito', CURDATE(), 'O+', 'Bom', DATE_ADD(CURDATE(), INTERVAL 12 DAY), 48000.00);

-- 5. Criar Cotações (Lances)
INSERT INTO cotacao (id_orgao, id_comprador, valor) VALUES 
(1, 1, 52000.00),
(1, 2, 55000.00),
(2, 2, 125000.00),
(2, 3, 130000.00),
(3, 1, 210000.00),
(4, 3, 49000.00);

-- =============================================
-- PARTE 2: TESTES DE FUNÇÕES
-- =============================================

-- Testar função de cálculo de idade
SELECT 
    id_comprador,
    nome,
    CalcularIdadeComprador(id_comprador) AS idade
FROM comprador;

-- Testar função de tempo sem circulação (se existir)
-- SELECT tempo_sem_circulacao(1) AS horas_sem_circulacao;

-- =============================================
-- PARTE 3: ALTERAÇÕES (UPDATES)
-- =============================================

-- Alterar status de cotações para testar trigger
UPDATE cotacao SET status = 'cancelada' WHERE id_cotacao = 1;
UPDATE cotacao SET status = 'finalizada' WHERE id_cotacao = 2;
UPDATE cotacao SET valor = 56000.00 WHERE id_cotacao = 6;

-- Alterar dados de comprador
UPDATE comprador 
SET nome = 'João Silva Santos' 
WHERE id_comprador = 1;

-- Alterar condição de órgão
UPDATE orgaos 
SET condicao_do_orgao = 'Regular', valor = 45000.00 
WHERE id_orgao = 4;

-- =============================================
-- PARTE 4: TRANSAÇÕES
-- =============================================

-- Fechar vendas (Transações)
INSERT INTO transacao (id_cotacao, id_comprador, status) VALUES 
(2, 2, 'concluida'),
(4, 3, 'concluida'),
(5, 1, 'aguardando');

-- =============================================
-- PARTE 5: CONSULTAS DAS VIEWS (SELECTS)
-- =============================================

-- Consultar órgãos disponíveis
SELECT 'ÓRGÃOS DISPONÍVEIS' AS consulta;
SELECT * FROM vw_orgaos_disponiveis;

-- Consultar cotações ativas
SELECT 'COTAÇÕES ATIVAS' AS consulta;
SELECT * FROM vw_cotacoes_ativas;

-- Consultar transações concluídas
SELECT 'TRANSAÇÕES CONCLUÍDAS' AS consulta;
SELECT * FROM vw_transacoes_concluidas;

-- Consultar ranking de compradores
SELECT 'RANKING DE COMPRADORES' AS consulta;
SELECT * FROM vw_ranking_compradores;

-- Consultar órgãos próximos ao vencimento
SELECT 'ÓRGÃOS PRÓXIMOS AO VENCIMENTO' AS consulta;
SELECT * FROM vw_orgaos_proximos_vencimento;

-- Consultar auditoria de cotações
SELECT 'AUDITORIA DE COTAÇÕES' AS consulta;
SELECT * FROM vw_auditoria_cotacoes;

-- =============================================
-- PARTE 6: TESTE DE PROCEDURES
-- =============================================

-- Executar procedure de atualização de órgãos expirados
CALL Atualiza_Orgaos_Expirados();

-- Verificar se a procedure funcionou
SELECT 'VERIFICAÇÃO PÓS-PROCEDURE' AS consulta;
SELECT * FROM cotacao WHERE status = 'cancelada';

-- =============================================
-- PARTE 7: EXCLUSÕES (DELETES) 
-- =============================================

-- Deletar um órgão para testar trigger de backup
DELETE FROM orgaos WHERE id_orgao = 4;

-- Verificar se o backup foi criado
SELECT 'BACKUP DE ÓRGÃOS DELETADOS' AS consulta;
SELECT * FROM orgaos_deletados;

-- Deletar cotação cancelada
DELETE FROM cotacao WHERE status = 'cancelada' AND id_cotacao = 1;

-- =============================================
-- PARTE 8: VERIFICAÇÕES FINAIS
-- =============================================

-- Verificar logs de alterações
SELECT 'LOGS DE COTAÇÃO' AS consulta;
SELECT * FROM log_cotacao ORDER BY data_alteracao DESC;

-- Verificar estado final das tabelas principais
SELECT 'ESTADO FINAL - DOADORES' AS consulta;
SELECT * FROM doador;

SELECT 'ESTADO FINAL - ÓRGÃOS' AS consulta;
SELECT * FROM orgaos;

SELECT 'ESTADO FINAL - COTAÇÕES' AS consulta;
SELECT * FROM cotacao ORDER BY id_cotacao;

SELECT 'ESTADO FINAL - TRANSAÇÕES' AS consulta;
SELECT * FROM transacao;

-- Verificar events ativos
SELECT 'EVENTS ATIVOS' AS consulta;
SHOW EVENTS;

-- =============================================
-- PARTE 9: RELATÓRIOS AVANÇADOS
-- =============================================

-- Relatório de faturamento por fornecedor
SELECT 
    f.nome AS fornecedor,
    COUNT(t.id_transacao) AS vendas_realizadas,
    SUM(c.valor) AS faturamento_total,
    AVG(c.valor) AS ticket_medio
FROM fornecedor f
LEFT JOIN orgaos o ON f.id_fornecedor = o.id_fornecedor
LEFT JOIN cotacao c ON o.id_orgao = c.id_orgao
LEFT JOIN transacao t ON c.id_cotacao = t.id_cotacao AND t.status = 'concluida'
GROUP BY f.id_fornecedor, f.nome;

-- Relatório de tipos sanguíneos mais demandados
SELECT 
    o.tipo_sanguineo,
    COUNT(c.id_cotacao) AS total_cotacoes,
    AVG(c.valor) AS valor_medio_ofertas
FROM orgaos o
LEFT JOIN cotacao c ON o.id_orgao = c.id_orgao
GROUP BY o.tipo_sanguineo
ORDER BY total_cotacoes DESC;