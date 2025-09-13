-- 001_init.sql
-- Esquema base: usuarios, categorias, servicios (sin valoraciones todavía)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS usuarios (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(120) NOT NULL,
  correo        VARCHAR(160) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  telefono      VARCHAR(30),
  rol           ENUM('cliente','proveedor','admin') NOT NULL DEFAULT 'cliente',
  creado_en     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS categorias (
  id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre    VARCHAR(80) NOT NULL UNIQUE,
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS servicios (
  id            BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  categoria_id  INT UNSIGNED NOT NULL,
  nombre        VARCHAR(140) NOT NULL,
  descripcion   TEXT,
  precio_base   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  activo        TINYINT(1) NOT NULL DEFAULT 1,
  creado_en     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_servicios_categoria
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX idx_servicios_categoria (categoria_id),
  INDEX idx_servicios_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
