-- -----------------------------------------------------
-- 01_estrutura.sql
-- Criação das Tabelas e Relacionamentos
-- -----------------------------------------------------

-- CONFIGURAÇÕES INICIAIS
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- 1. Tabela COMPRADOR
CREATE TABLE IF NOT EXISTS comprador (
  id_comprador int NOT NULL AUTO_INCREMENT,
  nome varchar(45) NOT NULL,
  sexo enum('masculino','feminino') NOT NULL,
  data_cadastro date NOT NULL,
  data_nascimento date NOT NULL,
  PRIMARY KEY (id_comprador)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 2. Tabela DOADOR
CREATE TABLE IF NOT EXISTS doador (
  id_doador int NOT NULL AUTO_INCREMENT,
  nome varchar(75) NOT NULL,
  data_nascimento date DEFAULT NULL,
  peso decimal(5,2) DEFAULT NULL,
  sexo enum('masculino','feminino') DEFAULT NULL,
  PRIMARY KEY (id_doador)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3. Tabela FORNECEDOR
CREATE TABLE IF NOT EXISTS fornecedor (
  id_fornecedor int NOT NULL AUTO_INCREMENT,
  nome varchar(70) NOT NULL,
  data_cadastro date NOT NULL,
  status enum('ativo','inativo') DEFAULT 'ativo',
  telefone varchar(20) DEFAULT NULL,
  email varchar(100) DEFAULT NULL,
  PRIMARY KEY (id_fornecedor)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 4. Tabela ORGAOS
CREATE TABLE IF NOT EXISTS orgaos (
  id_orgao int NOT NULL AUTO_INCREMENT,
  id_fornecedor int DEFAULT NULL,
  id_doador int DEFAULT NULL,
  data_hora_obito datetime DEFAULT NULL,
  data_hora_retirada datetime DEFAULT NULL,
  nome_orgao varchar(100) NOT NULL,
  data_entrada date NOT NULL,
  tipo_sanguineo varchar(5) DEFAULT NULL,
  condicao_do_orgao varchar(50) DEFAULT NULL,
  data_validade date NOT NULL,
  valor decimal(10,2) NOT NULL,
  PRIMARY KEY (id_orgao),
  KEY id_fornecedor (id_fornecedor),
  KEY id_doador (id_doador),
  CONSTRAINT orgaos_ibfk_1 FOREIGN KEY (id_fornecedor) REFERENCES fornecedor (id_fornecedor),
  CONSTRAINT orgaos_ibfk_2 FOREIGN KEY (id_doador) REFERENCES doador (id_doador)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 5. Tabela COTACAO
CREATE TABLE IF NOT EXISTS cotacao (
  id_cotacao int NOT NULL AUTO_INCREMENT,
  id_orgao int NOT NULL,
  id_comprador int NOT NULL,
  valor decimal(10,2) NOT NULL,
  status enum('em_andamento','finalizada','cancelada') DEFAULT 'em_andamento',
  data_cotacao date NOT NULL DEFAULT (curdate()),
  PRIMARY KEY (id_cotacao),
  KEY id_orgao (id_orgao),
  KEY id_comprador (id_comprador),
  CONSTRAINT cotacao_ibfk_1 FOREIGN KEY (id_orgao) REFERENCES orgaos (id_orgao),
  CONSTRAINT cotacao_ibfk_2 FOREIGN KEY (id_comprador) REFERENCES comprador (id_comprador)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 6. Tabela TRANSACAO
CREATE TABLE IF NOT EXISTS transacao (
  id_transacao int NOT NULL AUTO_INCREMENT,
  id_cotacao int NOT NULL,
  id_comprador int NOT NULL,
  status enum('concluida','aguardando','cancelada') NOT NULL DEFAULT 'aguardando',
  data_transacao date NOT NULL DEFAULT (curdate()),
  PRIMARY KEY (id_transacao),
  KEY id_cotacao (id_cotacao),
  KEY id_comprador (id_comprador),
  CONSTRAINT transacao_ibfk_1 FOREIGN KEY (id_cotacao) REFERENCES cotacao (id_cotacao),
  CONSTRAINT transacao_ibfk_2 FOREIGN KEY (id_comprador) REFERENCES comprador (id_comprador)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 7. Tabela LOG_COTACAO
CREATE TABLE IF NOT EXISTS log_cotacao (
  id_log int NOT NULL AUTO_INCREMENT,
  id_cotacao int NOT NULL,
  status_anterior enum('em_andamento','finalizada','cancelada') NOT NULL,
  novo_status enum('em_andamento','finalizada','cancelada') NOT NULL,
  data_alteracao datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_log),
  KEY fk_log_cotacao_cotacao (id_cotacao),
  CONSTRAINT fk_log_cotacao_cotacao FOREIGN KEY (id_cotacao) REFERENCES cotacao (id_cotacao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 8. Tabela ORGAOS_DELETADOS (Backup)
CREATE TABLE IF NOT EXISTS orgaos_deletados (
  id_log int NOT NULL AUTO_INCREMENT,
  data_exclusao datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dados_orgao_json json NOT NULL,
  PRIMARY KEY (id_log)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

COMMIT;