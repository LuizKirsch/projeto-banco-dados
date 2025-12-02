-- -----------------------------------------------------
-- 04_views.sql
-- Views para Consultas e Relatórios
-- -----------------------------------------------------

-- 1. View: Órgãos Disponíveis com Informações Completas
CREATE OR REPLACE VIEW vw_orgaos_disponiveis AS
SELECT 
    o.id_orgao,
    o.nome_orgao,
    o.tipo_sanguineo,
    o.condicao_do_orgao,
    o.data_entrada,
    o.data_validade,
    o.valor,
    DATEDIFF(o.data_validade, CURDATE()) AS dias_restantes,
    d.nome AS nome_doador,
    d.sexo AS sexo_doador,
    f.nome AS nome_fornecedor,
    f.telefone AS telefone_fornecedor,
    f.email AS email_fornecedor
FROM orgaos o
LEFT JOIN doador d ON o.id_doador = d.id_doador
LEFT JOIN fornecedor f ON o.id_fornecedor = f.id_fornecedor
WHERE o.data_validade >= CURDATE()
ORDER BY o.data_validade ASC;

-- 2. View: Cotações Ativas com Detalhes
CREATE OR REPLACE VIEW vw_cotacoes_ativas AS
SELECT 
    c.id_cotacao,
    c.valor AS valor_oferta,
    c.data_cotacao,
    c.status,
    o.nome_orgao,
    o.tipo_sanguineo,
    o.valor AS valor_base,
    ROUND(((c.valor - o.valor) / o.valor) * 100, 2) AS percentual_acima_base,
    comp.nome AS nome_comprador,
    comp.sexo AS sexo_comprador,
    TIMESTAMPDIFF(YEAR, comp.data_nascimento, CURDATE()) AS idade_comprador
FROM cotacao c
JOIN orgaos o ON c.id_orgao = o.id_orgao
JOIN comprador comp ON c.id_comprador = comp.id_comprador
WHERE c.status = 'em_andamento'
ORDER BY c.valor DESC;

-- 3. View: Histórico de Transações Concluídas
CREATE OR REPLACE VIEW vw_transacoes_concluidas AS
SELECT 
    t.id_transacao,
    t.data_transacao,
    t.status,
    c.valor AS valor_final,
    o.nome_orgao,
    o.tipo_sanguineo,
    comp.nome AS comprador,
    d.nome AS doador,
    f.nome AS fornecedor
FROM transacao t
JOIN cotacao c ON t.id_cotacao = c.id_cotacao
JOIN orgaos o ON c.id_orgao = o.id_orgao
JOIN comprador comp ON t.id_comprador = comp.id_comprador
LEFT JOIN doador d ON o.id_doador = d.id_doador
LEFT JOIN fornecedor f ON o.id_fornecedor = f.id_fornecedor
WHERE t.status = 'concluida'
ORDER BY t.data_transacao DESC;

-- 4. View: Ranking de Compradores Mais Ativos
CREATE OR REPLACE VIEW vw_ranking_compradores AS
SELECT 
    comp.id_comprador,
    comp.nome,
    COUNT(c.id_cotacao) AS total_cotacoes,
    COUNT(t.id_transacao) AS total_transacoes,
    AVG(c.valor) AS valor_medio_ofertas,
    SUM(CASE WHEN t.status = 'concluida' THEN c.valor ELSE 0 END) AS valor_total_compras
FROM comprador comp
LEFT JOIN cotacao c ON comp.id_comprador = c.id_comprador
LEFT JOIN transacao t ON comp.id_comprador = t.id_comprador AND t.status = 'concluida'
GROUP BY comp.id_comprador, comp.nome
HAVING total_cotacoes > 0
ORDER BY total_transacoes DESC, valor_total_compras DESC;

-- 5. View: Órgãos Próximos ao Vencimento
CREATE OR REPLACE VIEW vw_orgaos_proximos_vencimento AS
SELECT 
    o.id_orgao,
    o.nome_orgao,
    o.tipo_sanguineo,
    o.data_validade,
    DATEDIFF(o.data_validade, CURDATE()) AS dias_restantes,
    COUNT(c.id_cotacao) AS total_cotacoes_ativas,
    MAX(c.valor) AS maior_oferta
FROM orgaos o
LEFT JOIN cotacao c ON o.id_orgao = c.id_orgao AND c.status = 'em_andamento'
WHERE o.data_validade BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)
GROUP BY o.id_orgao, o.nome_orgao, o.tipo_sanguineo, o.data_validade
ORDER BY dias_restantes ASC;

-- 6. View: Relatório de Auditoria de Cotações
CREATE OR REPLACE VIEW vw_auditoria_cotacoes AS
SELECT 
    lc.id_log,
    lc.id_cotacao,
    lc.status_anterior,
    lc.novo_status,
    lc.data_alteracao,
    o.nome_orgao,
    comp.nome AS nome_comprador,
    c.valor AS valor_cotacao
FROM log_cotacao lc
JOIN cotacao c ON lc.id_cotacao = c.id_cotacao
JOIN orgaos o ON c.id_orgao = o.id_orgao
JOIN comprador comp ON c.id_comprador = comp.id_comprador
ORDER BY lc.data_alteracao DESC;