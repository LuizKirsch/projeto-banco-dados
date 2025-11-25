# Sistema de Gestão de Banco de Órgãos

> **Data:** 28 de outubro de 2025  
> **Local:** Novo Hamburgo  
> **Status:** Versão 2.2

## 📖 Introdução

Bem-vindo(a) ao sistema de gestão de órgãos\! Este documento foi criado para documentar a estrutura e a dinâmica do nosso sistema de banco de dados. Nosso foco principal é rastrear o órgão desde a "doação" até a transação final de compra, garantindo transparência, integridade e eficiência no processo.

-----

## 👨‍💻 Autores e Equipe

  * **Luiz Henrique da Cruz Kirsch**
  * **Manuela Knobeloch**
  * **Maurício Kauã Soares**
  * **Vinícius Gausmann**
  * **Jeferson Pierre da Silva**

-----

## 📅 Histórico de Revisão

| Nome | Data | Motivo da Alteração | Versão |
| :--- | :--- | :--- | :--- |
| Jeferson Pierre / Luiz Kirsch | 17/10/2025 | Criação da base do banco apresentada em aula | 1.0 |
| Luiz Kirsch | 27/10/2025 | Início da documentação | 1.0 |
| Manuela Knobeloch | 27/10/2025 | Criação da introdução | 1.1 |
| Luiz Kirsch | 31/10/2025 | Adição de SQL (DDL) e exemplos de uso | 1.2 |
| Manuela Knobeloch | 31/10/2025 | Adição de explicação das Triggers | 1.3 |
| Manuela Knobeloch | 11/11/2025 | Funções e Procedures | 2.0 |
| Vinícius Gausmann | 11/11/2025 | Criação de procedures | 2.1 |
| Manuela Knobeloch | 21/11/2025 | Explicação detalhada de Funções e Procedures | 2.2 |

-----

## 🛠️ Estrutura SQL Completa (DDL)

Abaixo encontra-se o script completo para criação do banco de dados, tabelas e relacionamentos.

```sql
-- CONFIGURAÇÕES INICIAIS
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- 1. Tabela COMPRADOR
CREATE TABLE comprador (
  id_comprador int NOT NULL,
  nome varchar(45) NOT NULL,
  sexo enum('masculino','feminino') NOT NULL,
  data_cadastro date NOT NULL,
  data_nascimento date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 2. Tabela DOADOR
CREATE TABLE doador (
  id_doador int NOT NULL,
  nome varchar(75) NOT NULL,
  data_nascimento date DEFAULT NULL,
  peso decimal(5,2) DEFAULT NULL,
  sexo enum('masculino','feminino') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3. Tabela FORNECEDOR
CREATE TABLE fornecedor (
  id_fornecedor int NOT NULL,
  nome varchar(70) NOT NULL,
  data_cadastro date NOT NULL,
  status enum('ativo','inativo') DEFAULT 'ativo',
  telefone varchar(20) DEFAULT NULL,
  email varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 4. Tabela ORGAOS
CREATE TABLE orgaos (
  id_orgao int NOT NULL,
  id_fornecedor int DEFAULT NULL,
  id_doador int DEFAULT NULL,
  data_hora_obito datetime DEFAULT NULL,
  data_hora_retirada datetime DEFAULT NULL,
  nome_orgao varchar(100) NOT NULL,
  data_entrada date NOT NULL,
  tipo_sanguineo varchar(5) DEFAULT NULL,
  condicao_do_orgao varchar(50) DEFAULT NULL,
  data_validade date NOT NULL,
  valor decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 5. Tabela COTACAO
CREATE TABLE cotacao (
  id_cotacao int NOT NULL,
  id_orgao int NOT NULL,
  id_comprador int NOT NULL,
  valor decimal(10,2) NOT NULL,
  status enum('em_andamento','finalizada','cancelada') DEFAULT 'em_andamento',
  data_cotacao date NOT NULL DEFAULT (curdate())
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 6. Tabela TRANSACAO
CREATE TABLE transacao (
  id_transacao int NOT NULL,
  id_cotacao int NOT NULL,
  id_comprador int NOT NULL,
  status enum('concluida','aguardando','cancelada') NOT NULL DEFAULT 'aguardando',
  data_transacao date NOT NULL DEFAULT (curdate())
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 7. Tabela LOG_COTACAO
CREATE TABLE log_cotacao (
  id_log int NOT NULL,
  id_cotacao int NOT NULL,
  status_anterior enum('em_andamento','finalizada','cancelada') NOT NULL,
  novo_status enum('em_andamento','finalizada','cancelada') NOT NULL,
  data_alteracao datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 8. Tabela ORGAOS_DELETADOS (Backup)
CREATE TABLE orgaos_deletados (
  id_log int NOT NULL,
  data_exclusao datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  dados_orgao_json json NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- DEFINIÇÃO DAS CHAVES PRIMÁRIAS E ÍNDICES
ALTER TABLE comprador ADD PRIMARY KEY (id_comprador);
ALTER TABLE doador ADD PRIMARY KEY (id_doador);
ALTER TABLE fornecedor ADD PRIMARY KEY (id_fornecedor);
ALTER TABLE orgaos ADD PRIMARY KEY (id_orgao), ADD KEY id_fornecedor (id_fornecedor), ADD KEY id_doador (id_doador);
ALTER TABLE cotacao ADD PRIMARY KEY (id_cotacao), ADD KEY id_orgao (id_orgao), ADD KEY id_comprador (id_comprador);
ALTER TABLE transacao ADD PRIMARY KEY (id_transacao), ADD KEY id_cotacao (id_cotacao), ADD KEY id_comprador (id_comprador);
ALTER TABLE log_cotacao ADD PRIMARY KEY (id_log), ADD KEY fk_log_cotacao_cotacao (id_cotacao);
ALTER TABLE orgaos_deletados ADD PRIMARY KEY (id_log);

-- CONFIGURAÇÃO DE AUTO_INCREMENT
ALTER TABLE comprador MODIFY id_comprador int NOT NULL AUTO_INCREMENT;
ALTER TABLE cotacao MODIFY id_cotacao int NOT NULL AUTO_INCREMENT;
ALTER TABLE doador MODIFY id_doador int NOT NULL AUTO_INCREMENT;
ALTER TABLE fornecedor MODIFY id_fornecedor int NOT NULL AUTO_INCREMENT;
ALTER TABLE log_cotacao MODIFY id_log int NOT NULL AUTO_INCREMENT;
ALTER TABLE orgaos MODIFY id_orgao int NOT NULL AUTO_INCREMENT;
ALTER TABLE orgaos_deletados MODIFY id_log int NOT NULL AUTO_INCREMENT;
ALTER TABLE transacao MODIFY id_transacao int NOT NULL AUTO_INCREMENT;

-- DEFINIÇÃO DAS CHAVES ESTRANGEIRAS (FK)
ALTER TABLE cotacao
  ADD CONSTRAINT cotacao_ibfk_1 FOREIGN KEY (id_orgao) REFERENCES orgaos (id_orgao),
  ADD CONSTRAINT cotacao_ibfk_2 FOREIGN KEY (id_comprador) REFERENCES comprador (id_comprador);

ALTER TABLE log_cotacao
  ADD CONSTRAINT fk_log_cotacao_cotacao FOREIGN KEY (id_cotacao) REFERENCES cotacao (id_cotacao);

ALTER TABLE orgaos
  ADD CONSTRAINT orgaos_ibfk_1 FOREIGN KEY (id_fornecedor) REFERENCES fornecedor (id_fornecedor),
  ADD CONSTRAINT orgaos_ibfk_2 FOREIGN KEY (id_doador) REFERENCES doador (id_doador);

ALTER TABLE transacao
  ADD CONSTRAINT transacao_ibfk_1 FOREIGN KEY (id_cotacao) REFERENCES cotacao (id_cotacao),
  ADD CONSTRAINT transacao_ibfk_2 FOREIGN KEY (id_comprador) REFERENCES comprador (id_comprador);

COMMIT;
```

-----

## ⚡ Triggers

Automações configuradas para garantir a integridade dos dados e logs de auditoria.

### 1\. Log de Cotação (`trg_after_update_cotacao`)

Registra alterações de status na tabela `log_cotacao`.

```sql
DELIMITER $$
CREATE TRIGGER trg_after_update_cotacao AFTER UPDATE ON cotacao FOR EACH ROW BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO log_cotacao (id_cotacao, status_anterior, novo_status)
        VALUES (OLD.id_cotacao, OLD.status, NEW.status);
    END IF;
END
$$
DELIMITER ;
```

### 2\. Backup de Exclusão (`trg_before_delete_orgao`)

Salva um backup JSON do órgão antes que ele seja deletado da tabela principal.

```sql
DELIMITER $$
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
END
$$
DELIMITER ;
```

### 3\. Finalização de Venda (`trg_after_insert_transacao`)

Ao criar uma transação, finaliza a cotação vencedora e cancela as demais concorrentes para o mesmo órgão.

```sql
DELIMITER $$
CREATE TRIGGER trg_after_insert_transacao AFTER INSERT ON transacao FOR EACH ROW BEGIN
  DECLARE v_orgao INT;

  -- 1. Finaliza a cotação vinculada
  UPDATE cotacao SET status = 'finalizada' WHERE id_cotacao = NEW.id_cotacao;

  -- 2. Descobre o órgão da cotação
  SELECT id_orgao INTO v_orgao FROM cotacao WHERE id_cotacao = NEW.id_cotacao;

  -- 3. Cancela outras cotações "em_andamento" do mesmo órgão
  UPDATE cotacao
  SET status = 'cancelada'
  WHERE id_orgao = v_orgao
    AND id_cotacao <> NEW.id_cotacao
    AND status = 'em_andamento';
END
$$
DELIMITER ;
```

-----

## ⚙️ Procedures

Procedimentos para padronizar inserções e manutenções no banco.

### `cadastrar_doador`

Padroniza a inserção de novos doadores.

```sql
DELIMITER $$
CREATE PROCEDURE cadastrar_doador (
    IN nome_doador VARCHAR(75),
    IN data_nascimento DATE,
    IN peso DECIMAL (5,2),
    IN sexo ENUM('masculino','feminino')
)
BEGIN
    INSERT INTO doador (nome, data_nascimento, peso, sexo)
    VALUES (nome_doador, data_nascimento, peso, sexo);
END
$$
DELIMITER ;
```

### `cadastro_comprador`

Centraliza o registro de novos compradores/receptores.

```sql
DELIMITER $$
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
DELIMITER ;
```

### `Atualiza_Orgaos_Expirados`

Cancela automaticamente cotações de órgãos cuja data de validade expirou.

```sql
DELIMITER $$
CREATE PROCEDURE Atualiza_Orgaos_Expirados ()
BEGIN    
    UPDATE cotacao
    JOIN orgaos ON cotacao.id_orgao = orgaos.id_orgao
    SET cotacao.status = 'cancelada'
    WHERE orgaos.data_validade < CURDATE() 
      AND cotacao.status = 'em_andamento';
END$$
DELIMITER ;
```

-----

## 🧮 Funções

### `tempo_sem_circulacao`

Calcula horas entre o óbito e a retirada do órgão.

```sql
DELIMITER $$
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
DELIMITER ;
```

### `calcular_cotacao`

Calcula o valor total com base em quantidade e valor unitário.

```sql
DELIMITER $$
CREATE FUNCTION calcular_cotacao(quantidade DECIMAL(10,2), valor DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SET total = quantidade * valor;
    RETURN total;
END $$
DELIMITER ;
```

### `CalcularIdadeComprador`

Retorna a idade atual de um comprador com base no ID.

```sql
DELIMITER $$ 
CREATE FUNCTION CalcularIdadeComprador(id_comprador_param INT) 
RETURNS INT 
DETERMINISTIC 
BEGIN 
    DECLARE data_nascimento_comprador DATE;
    
    SELECT data_nascimento INTO data_nascimento_comprador 
    FROM comprador WHERE id_comprador = id_comprador_param; 
    
    IF data_nascimento_comprador IS NULL THEN 
        RETURN NULL; 
    END IF;  
    
    RETURN TIMESTAMPDIFF(YEAR, data_nascimento_comprador, CURDATE()); 
END$$
DELIMITER ;
```

-----

## 🚀 Guia de Uso (Exemplos de INSERT)

Siga este fluxo para simular uma venda completa de órgão no sistema.

**Etapa 1: Cadastro das Entidades**

```sql
-- 1. Cadastrar um Doador
INSERT INTO doador (nome, data_nascimento, peso, sexo)
VALUES ('Doador Recente', '1965-03-10', 82.00, 'masculino');

-- 2. Cadastrar um Fornecedor
INSERT INTO fornecedor (nome, data_cadastro, status, email)
VALUES ('Hospital Central de Pesquisa', CURDATE(), 'ativo', 'pesquisa@central.com');

-- 3. Cadastrar um Comprador
INSERT INTO comprador (nome, sexo, data_cadastro, data_nascimento)
VALUES ('Fernanda Lima', 'feminino', CURDATE(), '1970-07-25');
```

**Etapa 2: Disponibilizar o Órgão**

```sql
-- 4. Inserir o novo Órgão (Fígado)
-- Assumindo id_fornecedor=4 e id_doador=5 gerados acima
INSERT INTO orgaos (id_fornecedor, id_doador, nome_orgao, data_entrada, tipo_sanguineo, condicao_do_orgao, data_validade, valor)
VALUES (4, 5, 'Fígado', CURDATE(), 'A-', 'Ótima', '2025-11-05', 150000.00);
```

**Etapa 3: Cotações (Lances)**

```sql
-- 5. Primeira oferta
INSERT INTO cotacao (id_orgao, id_comprador, valor)
VALUES (6, 3, 155000.00);

-- 6. Segunda oferta (Vencedora)
INSERT INTO cotacao (id_orgao, id_comprador, valor)
VALUES (6, 4, 160000.00);
```

**Etapa 4: Fechamento da Venda**

```sql
-- 7. Registrar a Transação
-- Isso dispara a Trigger que finaliza a cotação 8 e cancela a 7.
INSERT INTO transacao (id_cotacao, id_comprador, status)
VALUES (8, 4, 'concluida');
```

-----

## 📚 Dicionário de Dados

### Tabela: `doador`

| Coluna | Tipo | PK/FK | Descrição |
| :--- | :--- | :--- | :--- |
| `id_doador` | INT | PK | Identificador único. |
| `nome` | VARCHAR(75) | - | Nome completo. |
| `data_nascimento` | DATE | - | Data para cálculo de idade. |
| `peso` | DECIMAL | - | Peso em kg. |
| `sexo` | ENUM | - | Sexo biológico. |

### Tabela: `fornecedor`

| Coluna | Tipo | PK/FK | Descrição |
| :--- | :--- | :--- | :--- |
| `id_fornecedor` | INT | PK | Identificador único do hospital/banco. |
| `nome` | VARCHAR(70) | - | Nome da instituição. |
| `data_cadastro` | DATE | - | Data de registro. |
| `status` | ENUM | - | 'ativo' ou 'inativo'. |
| `telefone` | VARCHAR(20) | - | Contato telefônico. |
| `email` | VARCHAR(100) | - | E-mail de contato. |

### Tabela: `comprador`

| Coluna | Tipo | PK/FK | Descrição |
| :--- | :--- | :--- | :--- |
| `id_comprador` | INT | PK | Identificador único do receptor. |
| `nome` | VARCHAR(45) | - | Nome completo. |
| `sexo` | ENUM | - | Sexo biológico. |
| `data_cadastro` | DATE | - | Data de registro. |
| `data_nascimento` | DATE | - | Data de nascimento. |

### Tabela: `orgaos`

| Coluna | Tipo | PK/FK | Descrição |
| :--- | :--- | :--- | :--- |
| `id_orgao` | INT | PK | Identificador único. |
| `id_fornecedor` | INT | FK | Instituição fornecedora. |
| `id_doador` | INT | FK | Doador original. |
| `data_hora_obito` | DATETIME | - | Horário da morte. |
| `data_hora_retirada` | DATETIME | - | Horário da cirurgia. |
| `nome_orgao` | VARCHAR(100)| - | Ex: Coração, Rim. |
| `data_entrada` | DATE | - | Registro no sistema. |
| `tipo_sanguineo` | VARCHAR(5) | - | Compatibilidade. |
| `condicao` | VARCHAR(50) | - | Estado clínico. |
| `data_validade` | DATE | - | Limite de viabilidade. |
| `valor` | DECIMAL | - | Preço base. |

### Tabela: `cotacao`

| Coluna | Tipo | PK/FK | Descrição |
| :--- | :--- | :--- | :--- |
| `id_cotacao` | INT | PK | Identificador da oferta. |
| `id_orgao` | INT | FK | Órgão ofertado. |
| `id_comprador` | INT | FK | Autor da oferta. |
| `valor` | DECIMAL | - | Preço ofertado. |
| `status` | ENUM | - | 'em\_andamento', 'finalizada', 'cancelada'. |
| `data_cotacao` | DATE | - | Data do lance. |

### Tabela: `transacao`

| Coluna | Tipo | PK/FK | Descrição |
| :--- | :--- | :--- | :--- |
| `id_transacao` | INT | PK | Identificador da venda. |
| `id_cotacao` | INT | FK | Cotação vencedora. |
| `id_comprador` | INT | FK | Comprador final. |
| `status` | ENUM | - | 'concluida', 'aguardando'. |
| `data_transacao` | DATE | - | Data de fechamento. |
