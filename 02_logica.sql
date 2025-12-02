-- -----------------------------------------------------
-- 02_logica.sql
-- Triggers, Functions e Procedures
-- -----------------------------------------------------

DELIMITER $$

-- =============================================
-- TRIGGERS
-- =============================================

-- 1. Trigger: Log de alteração de status em cotacao
DROP TRIGGER IF EXISTS trg_after_update_cotacao$$
CREATE TRIGGER trg_after_update_cotacao AFTER UPDATE ON cotacao FOR EACH ROW BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO log_cotacao (id_cotacao, status_anterior, novo_status)
        VALUES (OLD.id_cotacao, OLD.status, NEW.status);
    END IF;
END$$

-- 2. Trigger: Backup antes de excluir orgao
DROP TRIGGER IF EXISTS trg_before_delete_orgao$$
CREATE TRIGGER trg_before_delete_orgao BEFORE DELETE ON orgaos FOR EACH ROW BEGIN
    INSERT INTO orgaos_deletados (dados_orgao_json)
    VALUES (
        JSON_OBJECT(
            'id_orgao', OLD.id_orgao,
            'id_fornecedor', OLD.id_fornecedor,
            'id_doador', OLD.id_doador,
            'nome_orgao', OLD.nome_orgao,
            'data_entrada', OLD.data_entrada,
            'tipo_sanguineo', OLD.tipo_sanguineo,
            'condicao_do_orgao', OLD.condicao_do_orgao,
            'data_validade', OLD.data_validade,
            'valor', OLD.valor
        )
    );
END$$

-- 3. Trigger: Automatização após transação (Finaliza e Cancela Cotacoes)
DROP TRIGGER IF EXISTS trg_after_insert_transacao$$
CREATE TRIGGER trg_after_insert_transacao AFTER INSERT ON transacao FOR EACH ROW BEGIN
  DECLARE v_orgao INT;

  -- Finaliza a cotação vinculada
  UPDATE cotacao
  SET status = 'finalizada'
  WHERE id_cotacao = NEW.id_cotacao;

  -- Descobre o órgão da cotação
  SELECT id_orgao INTO v_orgao
  FROM cotacao
  WHERE id_cotacao = NEW.id_cotacao;

  -- Cancela todas as outras cotações "em_andamento" do mesmo órgão
  UPDATE cotacao
  SET status = 'cancelada'
  WHERE id_orgao = v_orgao
    AND id_cotacao <> NEW.id_cotacao
    AND status = 'em_andamento';
END$$


-- =============================================
-- PROCEDURES
-- =============================================

-- 1. Procedure: Cadastrar Doador
DROP PROCEDURE IF EXISTS cadastrar_doador$$
CREATE PROCEDURE cadastrar_doador (
    IN nome_doador VARCHAR(75),
    IN data_nascimento DATE,
    IN peso DECIMAL (5,2),
    IN sexo ENUM('masculino','feminino')
)
BEGIN
    INSERT INTO doador (nome, data_nascimento, peso, sexo)
    VALUES (nome_doador, data_nascimento, peso, sexo);
END$$

-- 2. Procedure: Cadastrar Comprador
DROP PROCEDURE IF EXISTS cadastro_comprador$$
CREATE PROCEDURE cadastro_comprador (
    IN p_id_comprador INT,
    IN p_nome VARCHAR(45),
    IN p_sexo ENUM('masculino', 'feminino'),
    IN p_data_cadastro DATE,
    IN p_data_nascimento DATE
)
BEGIN
    INSERT INTO comprador (id_comprador, nome, sexo, data_cadastro, data_nascimento)
    VALUES (p_id_comprador, p_nome, p_sexo, p_data_cadastro, p_data_nascimento);
END $$

-- 3. Procedure: Atualizar Orgaos Expirados
DROP PROCEDURE IF EXISTS Atualiza_Orgaos_Expirados$$
CREATE PROCEDURE Atualiza_Orgaos_Expirados ()
BEGIN    
    UPDATE cotacao
    JOIN orgaos ON cotacao.id_orgao = orgaos.id_orgao
    SET cotacao.status = 'cancelada'
    WHERE 
        orgaos.data_validade < CURDATE() 
        AND cotacao.status = 'em_andamento';
END$$


-- =============================================
-- FUNÇÕES (FUNCTIONS)
-- =============================================

-- 1. Função: Tempo sem Circulação (Horas)
DROP FUNCTION IF EXISTS tempo_sem_circulacao$$
CREATE FUNCTION tempo_sem_circulacao (orgao_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE horas INT;
    SELECT TIMESTAMPDIFF(HOUR, data_hora_obito, data_hora_retirada)
    INTO horas
    FROM orgaos
    WHERE id_orgao = orgao_id;
    RETURN horas;
END$$

-- 2. Função: Calcular Cotação
DROP FUNCTION IF EXISTS calcular_cotacao$$
CREATE FUNCTION calcular_cotacao(quantidade DECIMAL(10,2), valor DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SET total = quantidade * valor;
    RETURN total;
END $$

-- 3. Função: Calcular Idade do Comprador
DROP FUNCTION IF EXISTS CalcularIdadeComprador$$
CREATE FUNCTION CalcularIdadeComprador(id_comprador_param INT) 
RETURNS INT 
DETERMINISTIC 
BEGIN 
    DECLARE data_nascimento_comprador DATE;
    SELECT data_nascimento
             INTO data_nascimento_comprador 
    FROM comprador WHERE id_comprador = id_comprador_param; 
    
    IF data_nascimento_comprador IS NULL THEN 
        RETURN NULL; 
    END IF;  
    
    RETURN TIMESTAMPDIFF(YEAR, data_nascimento_comprador, CURDATE()); 
END$$


-- =============================================
-- EVENTS
-- =============================================

-- 1. Event: Limpeza de Logs Antigos
DROP EVENT IF EXISTS evt_limpeza_logs_anuais$$
CREATE EVENT evt_limpeza_logs_anuais
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-01-01 02:00:00'
DO
BEGIN
    DELETE FROM log_cotacao 
    WHERE data_alteracao < DATE_SUB(NOW(), INTERVAL 1 YEAR);
    
    DELETE FROM orgaos_deletados 
    WHERE data_exclusao < DATE_SUB(NOW(), INTERVAL 2 YEAR);
END$$

-- 2. Event: Cancelar Transações Paradas
DROP EVENT IF EXISTS evt_cancelar_transacoes_paradas$$
CREATE EVENT evt_cancelar_transacoes_paradas
ON SCHEDULE EVERY 1 HOUR
STARTS '2025-01-01 00:00:00'
DO
BEGIN
    UPDATE transacao
    SET status = 'cancelada'
    WHERE status = 'aguardando' 
    AND data_transacao < DATE_SUB(CURDATE(), INTERVAL 3 DAY);
END$$

-- 3. Event: Atualização Automática de Órgãos Expirados
DROP EVENT IF EXISTS evt_atualizar_orgaos_expirados$$
CREATE EVENT evt_atualizar_orgaos_expirados
ON SCHEDULE EVERY 6 HOUR
STARTS '2025-01-01 00:00:00'
DO
BEGIN
    CALL Atualiza_Orgaos_Expirados();
END$$

-- 4. Event: Notificação de Órgãos Próximos ao Vencimento
DROP EVENT IF EXISTS evt_verificar_vencimentos$$
CREATE EVENT evt_verificar_vencimentos
ON SCHEDULE EVERY 12 HOUR
STARTS '2025-01-01 08:00:00'
DO
BEGIN
    INSERT INTO log_cotacao (id_cotacao, status_anterior, novo_status)
    SELECT 
        c.id_cotacao,
        'em_andamento' AS status_anterior,
        'cancelada' AS novo_status
    FROM cotacao c
    JOIN orgaos o ON c.id_orgao = o.id_orgao
    WHERE o.data_validade <= DATE_ADD(CURDATE(), INTERVAL 1 DAY)
    AND c.status = 'em_andamento';
    
    UPDATE cotacao c
    JOIN orgaos o ON c.id_orgao = o.id_orgao
    SET c.status = 'cancelada'
    WHERE o.data_validade <= DATE_ADD(CURDATE(), INTERVAL 1 DAY)
    AND c.status = 'em_andamento';
END$$

DELIMITER ;