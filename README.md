# Sistema de Gestão de Banco de Órgãos

> **Data:** 02 de dezembro de 2025  
> **Local:** Novo Hamburgo  
> **Status:** Versão 3.4

## 📖 Introdução

Bem-vindo(a) ao sistema de gestão de órgãos\! Este documento foi criado para documentar a estrutura e a dinâmica do nosso sistema de banco de dados. Nosso foco principal é rastrear o órgão desde a "doação" até a transação final de compra, garantindo transparência, integridade e eficiência no processo.

## 📁 Estrutura do Projeto

```
01_estrutura.sql  - Criação de tabelas e relacionamentos
02_logica.sql     - Triggers, functions, procedures e events  
03_teste.sql      - Ensaio completo: inserts, updates, deletes, selects
04_views.sql      - Views para consultas e relatórios
README.md         - Documentação completa do projeto
```

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
| Mauricio Soares   | 11/11/2025 | Criação de functions | 2.1 |
| Vinícius Gausmann | 11/11/2025 | Criação de procedures | 2.2 |
| Manuela Knobeloch | 21/11/2025 | Explicação detalhada de Funções e Procedures | 2.3 |
| Luiz Kirsch | 25/11/2025 | Documentação no GitHub | 3.0 |
|Vinícius Gausmann | 28/11/2025 | Criação de events | 3.1 |
| Luiz Kirsch | 02/12/2025 | Implementação completa de Views e Events | 3.2 |
| Luiz Kirsch | 02/12/2025 | Ensaio completo expandido | 3.3 |
| Jeferson Pierre | 04/12/2025 | Criando seção de backup/recovery Dump | 3.4 |
| Jeferson Pierre | 05/12/2025 | Criando seção de backup/recovery Binlog | 3.5 |
-----

## 🛠️ Estrutura SQL Completa (DDL)

Abaixo encontra-se o script completo para criação do banco de dados, tabelas e relacionamentos.

```sql
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
```

-----

## 👁️ Views

Views criadas para facilitar consultas e relatórios do sistema.

### 1. `vw_orgaos_disponiveis`
Listagem completa de órgãos ainda válidos com informações do doador e fornecedor.

### 2. `vw_cotacoes_ativas`
Cotações em andamento com cálculo de percentual acima do valor base e dados do comprador.

### 3. `vw_transacoes_concluidas`
Histórico de todas as transações finalizadas com sucesso.

### 4. `vw_ranking_compradores`
Ranking dos compradores mais ativos no sistema.

### 5. `vw_orgaos_proximos_vencimento`
Órgãos que vencem nos próximos 3 dias com suas cotações ativas.

### 6. `vw_auditoria_cotacoes`
Log completo de alterações de status nas cotações para auditoria.

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

## ⏰ Events

Automações agendadas para manutenção e otimização do sistema.

### 1. `evt_limpeza_logs_anuais`
Executa mensalmente para remover:
- Logs de cotação com mais de 1 ano
- Backups de órgãos deletados com mais de 2 anos

### 2. `evt_cancelar_transacoes_paradas`
Executa a cada hora para cancelar transações que estão aguardando há mais de 3 dias.

### 3. `evt_atualizar_orgaos_expirados`
Executa a cada 6 horas para cancelar cotações de órgãos expirados.

### 4. `evt_verificar_vencimentos`
Executa a cada 12 horas para:
- Registrar logs de órgãos próximos ao vencimento
- Cancelar cotações de órgãos que vencerão em 24 horas

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

## Events 

## `evt_limpeza_logs_anuais`

limpa registros muito antigos para poupar espaço.

```sql 
CREATE EVENT evt_limpeza_logs_anuais
ON SCHEDULE EVERY 1 MONTH
DO
    DELETE FROM log_cotacao 
    WHERE data_alteracao < DATE_SUB(NOW(), INTERVAL 1 YEAR);
```

## `evt_cancelar_transacoes_paradas` 

 Se uma transação ficar "aguardando" por muito tempo (por exemplo, 3 dias sem confirmação de pagamento ou logística), ela deveria ser cancelada para não "prender" o órgão indefinidamente.

 ```sql
 CREATE EVENT evt_cancelar_transacoes_paradas
ON SCHEDULE EVERY 1 HOUR
DO
    UPDATE transacao
    SET status = 'cancelada'
    WHERE status = 'aguardando' 
    AND data_transacao < DATE_SUB(CURDATE(), INTERVAL 3 DAY);
    ```

-----

## 🧪 Ensaio Completo (03_teste.sql)

O arquivo de teste contém um ensaio completo que demonstra todas as funcionalidades do sistema:

### Parte 1: Inserção de Dados
- Cadastro de doadores usando procedures
- Inserção de fornecedores e compradores
- Criação de órgãos e cotações

### Parte 2: Testes de Funções
- Verificação do cálculo de idade dos compradores
- Validação das funções personalizadas

### Parte 3: Alterações (Updates)
- Teste de triggers através de alterações de status
- Modificação de dados para verificar logs
- Atualização de valores e condições

### Parte 4: Transações
- Simulação de vendas concluídas e pendentes
- Teste do fluxo completo de negociação

### Parte 5: Consultas das Views
- Demonstração de todas as 6 views criadas
- Relatórios de órgãos, cotações e transações
- Análises de ranking e auditoria

### Parte 6: Teste de Procedures
- Execução de procedures de manutenção
- Verificação de funcionamento automatizado

### Parte 7: Exclusões (Deletes)
- Teste de triggers de backup
- Verificação de integridade referencial

### Parte 8: Verificações Finais
- Análise de logs e estado das tabelas
- Verificação de events ativos
- Relatórios avançados de faturamento

-----
```
-----

## 💾 Plano de Backup e Recovery do Banco de Dados

Esta seção descreve um processo simples de backup e recovery do banco de dados utilizado neste projeto. O objetivo é garantir que os dados e objetos do banco (tabelas, views, índices e demais estruturas) possam ser facilmente salvos e recuperados em caso de falhas, testes ou migrações.

O processo de recuperação seguirá a seguinte ordem:

1. Restaurar um backup completo (dump)

2. Aplicar os eventos do binlog após o backup

3. Restaurar o banco até o momento desejado

### Dump

🔹 1. Backup do Banco de Dados

O backup é feito por meio de um dump, que exporta toda a estrutura e os dados do banco para um arquivo .sql.

Passo a passo:

1. Acesse o terminal e conecte-se ao servidor onde o banco está hospedado.

2. Execute o comando de dump:

```bash
mysqldump -u <usuario> -p <nome_do_banco> > backup_projeto.sql
```

3. Insira a senha quando solicitado.

4. O arquivo backup_projeto.sql será gerado no diretório onde o comando foi executado.

O que está incluído no dump?

O comando acima exporta:

<li>Estrutura das tabelas</li>

<li>Dados inseridos</li>

<li>Índices</li>

<li>Chaves primárias e estrangeiras</li>

<li>Triggers</li>

<li>Views</li>

<li>Stored procedures e functions (se o parâmetro --routines estiver habilitado por padrão)</li>


Caso queira garantir a exportação de tudo:

```bash
mysqldump --routines --triggers --events -u <usuario> -p <nome_do_banco> > backup_completo.sql
```


🔹 2. Recovery do Banco de Dados

O recovery consiste em restaurar um arquivo de dump em um novo banco ou sobrescrever um existente.

Passo a passo:

Crie um novo banco (caso necessário):

```sql
CREATE DATABASE projeto_banco;
```

Execute a restauração:

```bash
mysql -u <usuario> -p projeto_banco < backup_projeto.sql
```

Insira a senha quando solicitado.

O banco será recriado com a mesma estrutura e dados presentes no backup.

### Binlog

As configurações do binlog devem ser inseridas no arquivo de configuração do banco, my.ini (Windows) e my.cnf (Linux.)


🔹 1. Configuração e ativação do binlog

```ini
server_id=1
log-bin="C:/ProgramData/MySQL/MySQL Server 8.0/Data/mysql-bin"
binlog_format=ROW
expire_logs_days=7
max_binlog_size=1024M
sync_binlog=1
```

Serão gerados arquivos neste padrão:

```
mysql-bin.000001
```

🔹 2. Recuperando os dados

Após recuperação do banco via dump, efetuar a recuperação dos dados do log

```bash
mysqlbinlog mysql-bin.000001 | mysql -u root -p
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

## ### 🟦 **Tabela: `doador`**

| Coluna            | Tipo                         | PK/FK | Descrição            |
| ----------------- | ---------------------------- | ----- | -------------------- |
| `id_doador`       | INT(11)                      | PK    | Identificador único. |
| `nome`            | VARCHAR(75)                  | –     | Nome completo.       |
| `data_nascimento` | DATE                         | –     | Data de nascimento.  |
| `peso`            | DECIMAL(5,2)                 | –     | Peso em kg.          |
| `sexo`            | ENUM('masculino','feminino') | –     | Sexo biológico.      |

---

## ### 🟦 **Tabela: `fornecedor`**

| Coluna          | Tipo                    | PK/FK | Descrição                     |
| --------------- | ----------------------- | ----- | ----------------------------- |
| `id_fornecedor` | INT(11)                 | PK    | Identificador da instituição. |
| `nome`          | VARCHAR(70)             | –     | Nome do hospital/banco.       |
| `data_cadastro` | DATE                    | –     | Data de registro.             |
| `status`        | ENUM('ativo','inativo') | –     | Status operacional.           |
| `telefone`      | VARCHAR(20)             | –     | Telefone.                     |
| `email`         | VARCHAR(100)            | –     | E-mail de contato.            |

---

## ### 🟦 **Tabela: `comprador`**

| Coluna            | Tipo                         | PK/FK | Descrição                  |
| ----------------- | ---------------------------- | ----- | -------------------------- |
| `id_comprador`    | INT(11)                      | PK    | Identificador do receptor. |
| `nome`            | VARCHAR(45)                  | –     | Nome completo.             |
| `sexo`            | ENUM('masculino','feminino') | –     | Sexo biológico.            |
| `data_cadastro`   | DATE                         | –     | Data de registro.          |
| `data_nascimento` | DATE                         | –     | Data de nascimento.        |

---

## ### 🟦 **Tabela: `orgaos`**

| Coluna               | Tipo          | PK/FK | Descrição                   |
| -------------------- | ------------- | ----- | --------------------------- |
| `id_orgao`           | INT(11)       | PK    | Identificador do órgão.     |
| `id_fornecedor`      | INT(11)       | FK    | Instituição fornecedora.    |
| `id_doador`          | INT(11)       | FK    | Doador original.            |
| `data_hora_obito`    | DATETIME      | –     | Horário do óbito.           |
| `data_hora_retirada` | DATETIME      | –     | Horário da retirada.        |
| `nome_orgao`         | VARCHAR(100)  | –     | Nome do órgão.              |
| `data_entrada`       | DATE          | –     | Data de entrada no sistema. |
| `tipo_sanguineo`     | VARCHAR(5)    | –     | Tipo sanguíneo.             |
| `condicao_do_orgao`  | VARCHAR(50)   | –     | Qualidade clínica.          |
| `data_validade`      | DATE          | –     | Prazo de viabilidade.       |
| `valor`              | DECIMAL(10,2) | –     | Preço base.                 |

---

## ### 🟦 **Tabela: `cotacao`**

| Coluna         | Tipo                                          | PK/FK | Descrição               |
| -------------- | --------------------------------------------- | ----- | ----------------------- |
| `id_cotacao`   | INT(11)                                       | PK    | Identificador do lance. |
| `id_orgao`     | INT(11)                                       | FK    | Órgão ofertado.         |
| `id_comprador` | INT(11)                                       | FK    | Autor da oferta.        |
| `valor`        | DECIMAL(10,2)                                 | –     | Valor ofertado.         |
| `status`       | ENUM('em_andamento','finalizada','cancelada') | –     | Estado atual.           |
| `data_cotacao` | DATE                                          | –     | Data da oferta.         |

---

## ### 🟦 **Tabela: `transacao`**

| Coluna           | Tipo                                       | PK/FK | Descrição                   |
| ---------------- | ------------------------------------------ | ----- | --------------------------- |
| `id_transacao`   | INT(11)                                    | PK    | Identificador da transação. |
| `id_cotacao`     | INT(11)                                    | FK    | Cotação vencedora.          |
| `id_comprador`   | INT(11)                                    | FK    | Comprador final.            |
| `status`         | ENUM('concluida','aguardando','cancelada') | –     | Status final.               |
| `data_transacao` | DATE                                       | –     | Data da venda.              |

---

## ### 🟦 **Tabela: `log_cotacao`** (Trigger)

| Coluna            | Tipo                                          | PK/FK | Descrição              |
| ----------------- | --------------------------------------------- | ----- | ---------------------- |
| `id_log`          | INT(11)                                       | PK    | Identificador do log.  |
| `id_cotacao`      | INT(11)                                       | FK    | Cotação alterada.      |
| `status_anterior` | ENUM('em_andamento','finalizada','cancelada') | –     | Status antes.          |
| `novo_status`     | ENUM('em_andamento','finalizada','cancelada') | –     | Status após alteração. |
| `data_alteracao`  | DATETIME                                      | –     | Data da alteração.     |

---

## ### 🟦 **Tabela: `orgaos_deletados`** (Trigger)

| Coluna             | Tipo     | PK/FK | Descrição                        |
| ------------------ | -------- | ----- | -------------------------------- |
| `id_log`           | INT(11)  | PK    | Identificador do backup.         |
| `data_exclusao`    | DATETIME | –     | Data da exclusão.                |
| `dados_orgao_json` | JSON     | –     | JSON completo do órgão removido. |

---
