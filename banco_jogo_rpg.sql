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
