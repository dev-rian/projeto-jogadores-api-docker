-- 1. Usuário específico para a aplicação
CREATE USER api_user WITH PASSWORD 'api_password';

-- 2. Permissão de CONECTAR ao banco
GRANT CONNECT ON DATABASE futebol_db TO api_user;

-- 3. Criamos a tabela para nossa API
CREATE TABLE IF NOT EXISTS jogadores (
    id SERIAL PRIMARY KEY,
    nome_completo VARCHAR(100) NOT NULL,
    time_atual VARCHAR(50),
    posicao VARCHAR(50),
    numero_camisa INTEGER
);

-- 4. 'api_user' apenas com as permissões necessárias (CRUD)
-- Ele NÃO PODE criar, deletar ou alterar tabelas. Apenas ler.
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE jogadores TO api_user;

-- 5. Garantimos que ele possa usar a 'sequence' para gerar os IDs
GRANT USAGE, SELECT ON SEQUENCE jogadores_id_seq TO api_user;