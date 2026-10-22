-- ATIVIDADE: Linguagem de Manipulação de Dados (DML)
-- Projeto: Jogo de RPG Online
-- SGBD: SQL 
-- Este script considera que as tabelas do arquivo banco_jogo_rpg.sql já foram criadas.

USE jogo_rpg;

INSERT INTO USUARIOS (UsuarioId, Email, Senha) VALUES
(1, 'ana@example.com', '$2y$10$HASH_DE_EXEMPLO_NAO_UTILIZAR_EM_PRODUCAO'),
(2, 'bruno@example.com', '$2y$10$HASH_DE_EXEMPLO_NAO_UTILIZAR_EM_PRODUCAO'),
(3, 'carla@example.com', '$2y$10$HASH_DE_EXEMPLO_NAO_UTILIZAR_EM_PRODUCAO');

INSERT INTO CLASSES (ClasseId, Nome, Descricao) VALUES
(1, 'Guerreiro', 'Especialista em combate corpo a corpo e defesa.'),
(2, 'Mago', 'Utiliza magia para atacar e apoiar aliados.'),
(3, 'Arqueiro', 'Ataca à distância com arco e flechas.');

INSERT INTO HABILIDADES (HabilidadeId, Nome) VALUES
(1, 'Golpe Poderoso'),
(2, 'Bola de Fogo'),
(3, 'Flecha Precisa'),
(4, 'Escudo Protetor'),
(5, 'Rajada Arcana');

INSERT INTO PERSONAGENS (PersonagemId, NomePersonagem, UsuarioId, ClasseId) VALUES
(1, 'Thorin', 1, 1),
(2, 'Luna', 1, 2),
(3, 'Kael', 2, 3),
(4, 'Mira', 3, 2);

INSERT INTO CLASSES_HABILIDADES (ClasseId, HabilidadeId) VALUES
(1, 1),
(1, 4),
(2, 2),
(2, 5),
(3, 3);

-- =====================================================
-- 2. CONSULTAS (SELECT)
-- =====================================================

-- Listar todos os usuários (não exibir senhas em consultas comuns).
SELECT UsuarioId, Email FROM USUARIOS;

-- Listar personagens com o nome do usuário e da classe.
SELECT
    p.PersonagemId,
    p.NomePersonagem,
    u.Email,
    c.Nome AS Classe
FROM PERSONAGENS AS p
INNER JOIN USUARIOS AS u ON u.UsuarioId = p.UsuarioId
INNER JOIN CLASSES AS c ON c.ClasseId = p.ClasseId
ORDER BY p.NomePersonagem;

-- Listar habilidades de cada classe.
SELECT
    c.Nome AS Classe,
    h.Nome AS Habilidade
FROM CLASSES_HABILIDADES AS ch
INNER JOIN CLASSES AS c ON c.ClasseId = ch.ClasseId
INNER JOIN HABILIDADES AS h ON h.HabilidadeId = ch.HabilidadeId
ORDER BY c.Nome, h.Nome;

-- =====================================================
-- 3. ATUALIZAÇÃO DE DADOS (UPDATE)
-- =====================================================

-- Exemplo: atualizar a descrição de uma classe.
UPDATE CLASSES
SET Descricao = 'Especialista em combate corpo a corpo, defesa e proteção dos aliados.'
WHERE ClasseId = 1;

-- =====================================================
-- 4. EXCLUSÃO DE DADOS (DELETE)
-- =====================================================

-- Exemplo seguro para demonstração: excluir uma habilidade somente se
-- ela não estiver associada a nenhuma classe.
-- A habilidade 5 está associada à classe Mago; por isso, não será excluída.
-- Para testar a exclusão, descomente as linhas abaixo apenas se a habilidade
-- escolhida não estiver referenciada em CLASSES_HABILIDADES.
--
-- DELETE FROM HABILIDADES
-- WHERE HabilidadeId = 5
--   AND NOT EXISTS (
--       SELECT 1
--       FROM CLASSES_HABILIDADES
--       WHERE CLASSES_HABILIDADES.HabilidadeId = HABILIDADES.HabilidadeId
--   );

-- =====================================================
-- 5. PROCEDIMENTO ARMAZENADO (STORED PROCEDURE)
-- =====================================================

DELIMITER $$

CREATE PROCEDURE ListarPersonagensPorUsuario(IN p_UsuarioId INT)
BEGIN
    SELECT
        p.PersonagemId,
        p.NomePersonagem,
        c.Nome AS Classe
    FROM PERSONAGENS AS p
    INNER JOIN CLASSES AS c ON c.ClasseId = p.ClasseId
    WHERE p.UsuarioId = p_UsuarioId
    ORDER BY p.NomePersonagem;
END$$

DELIMITER ;

-- Executar o procedimento para listar os personagens do usuário 1:
CALL ListarPersonagensPorUsuario(1);

-- =====================================================
-- 6. TRIGGER (DISPARADOR)
-- =====================================================

-- Tabela de auditoria para registrar alterações na descrição das classes.
CREATE TABLE IF NOT EXISTS AUDITORIA_CLASSES (
    AuditoriaId INT AUTO_INCREMENT PRIMARY KEY,
    ClasseId INT NOT NULL,
    DescricaoAntiga TEXT,
    DescricaoNova TEXT,
    DataAlteracao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE TRIGGER trg_classes_apos_atualizacao
AFTER UPDATE ON CLASSES
FOR EACH ROW
BEGIN
    IF NOT (OLD.Descricao <=> NEW.Descricao) THEN
        INSERT INTO AUDITORIA_CLASSES
            (ClasseId, DescricaoAntiga, DescricaoNova)
        VALUES
            (OLD.ClasseId, OLD.Descricao, NEW.Descricao);
    END IF;
END$$

DELIMITER ;

-- Consultar o histórico de alterações registradas pelo trigger:
SELECT * FROM AUDITORIA_CLASSES ORDER BY DataAlteracao DESC;

-- =====================================================
-- BOAS PRÁTICAS DE SEGURANÇA
-- =====================================================
-- 1. Em sistemas reais, nunca armazene senhas em texto puro.
--    Gere hashes seguros no backend (por exemplo, Argon2id ou bcrypt).
-- 2. Os hashes acima são marcadores de exemplo e NÃO são senhas válidas.
-- 3. Utilize usuários de banco com apenas as permissões necessárias.
-- 4. Em aplicações, use consultas preparadas para evitar SQL injection.
-- 5. Antes de executar UPDATE ou DELETE em dados reais, confira o WHERE
--    e faça backup quando necessário.
