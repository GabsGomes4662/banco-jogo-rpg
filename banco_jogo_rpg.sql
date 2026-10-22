-- Banco de dados: Jogo RPG Online
-- Estrutura baseada no diagrama fornecido na atividade SENAI

CREATE DATABASE IF NOT EXISTS jogo_rpg;
USE jogo_rpg;

CREATE TABLE USUARIOS (
    UsuarioId INT AUTO_INCREMENT PRIMARY KEY,
    Email VARCHAR(255) NOT NULL,
    Senha VARCHAR(255) NOT NULL
);

CREATE TABLE CLASSES (
    ClasseId INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Descricao TEXT
);

CREATE TABLE HABILIDADES (
    HabilidadeId INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL
);

CREATE TABLE PERSONAGENS (
    PersonagemId INT AUTO_INCREMENT PRIMARY KEY,
    NomePersonagem VARCHAR(100) NOT NULL,
    UsuarioId INT NOT NULL,
    ClasseId INT NOT NULL,
    CONSTRAINT fk_personagens_usuarios
        FOREIGN KEY (UsuarioId) REFERENCES USUARIOS (UsuarioId),
    CONSTRAINT fk_personagens_classes
        FOREIGN KEY (ClasseId) REFERENCES CLASSES (ClasseId)
);

CREATE TABLE CLASSES_HABILIDADES (
    ClasseId INT NOT NULL,
    HabilidadeId INT NOT NULL,
    PRIMARY KEY (ClasseId, HabilidadeId),
    CONSTRAINT fk_classes_habilidades_classes
        FOREIGN KEY (ClasseId) REFERENCES CLASSES (ClasseId),
    CONSTRAINT fk_classes_habilidades_habilidades
        FOREIGN KEY (HabilidadeId) REFERENCES HABILIDADES (HabilidadeId)
);



/*
  ATIVIDADE: Permissões e auditoria no SQL Server
  Objetivo: permitir somente leitura e auditar acessos.
*/

-- 1. Criar o login no SQL Server
USE master;
GO

CREATE LOGIN [usuario_consulta]
WITH PASSWORD = 'Troque_Esta_Senha#2026',
     CHECK_POLICY = ON;
GO

-- 2. Criar a auditoria no servidor
-- A pasta C:\SQLAudit deve existir e permitir
-- gravação pela conta de serviço do SQL Server.

CREATE SERVER AUDIT [AuditoriaRPG]
TO FILE
(
    FILEPATH = 'C:\SQLAudit\',
    MAXSIZE = 100 MB,
    MAX_ROLLOVER_FILES = 10
)
WITH (ON_FAILURE = CONTINUE);
GO

ALTER SERVER AUDIT [AuditoriaRPG]
WITH (STATE = ON);
GO

-- 3. Selecionar o banco de dados do RPG
USE [RPGOnline];
GO

-- 4. Criar o usuário dentro do banco
CREATE USER [usuario_consulta]
FOR LOGIN [usuario_consulta];
GO

-- 5. Conceder somente leitura nas tabelas do esquema dbo
GRANT SELECT ON SCHEMA::dbo TO [usuario_consulta];
GO

-- 6. Bloquear operações de escrita no esquema dbo
DENY INSERT, UPDATE, DELETE
ON SCHEMA::dbo TO [usuario_consulta];
GO

-- 7. Criar a especificação de auditoria do banco
CREATE DATABASE AUDIT SPECIFICATION [AuditoriaRPG_DB]
FOR SERVER AUDIT [AuditoriaRPG]
    ADD (SELECT ON SCHEMA::dbo BY [usuario_consulta]),
    ADD (INSERT ON SCHEMA::dbo BY [usuario_consulta]),
    ADD (UPDATE ON SCHEMA::dbo BY [usuario_consulta]),
    ADD (DELETE ON SCHEMA::dbo BY [usuario_consulta])
WITH (STATE = ON);
GO

-- 8. Consultar os registros da auditoria
SELECT
    event_time,
    action_id,
    succeeded,
    server_principal_name,
    database_name,
    statement
FROM sys.fn_get_audit_file
(
    'C:\SQLAudit\*.sqlaudit',
    DEFAULT,
    DEFAULT
)
ORDER BY event_time DESC;
GO
