SET NAMES utf8mb4;

-- Asegura que la tabla exista (si ya existe, no pasa nada)
CREATE TABLE IF NOT EXISTS usuarios (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(120) NOT NULL DEFAULT '',
  correo VARCHAR(160) NOT NULL DEFAULT '',
  password_hash VARCHAR(255) NOT NULL DEFAULT '',
  telefono VARCHAR(30) NULL,
  rol ENUM('cliente','proveedor','admin') NOT NULL DEFAULT 'cliente',
  creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY idx_usuarios_correo (correo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Asegura tipo de PK
ALTER TABLE usuarios
  MODIFY id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;

-- Prepara variables
SET @db := DATABASE();

-- nombre
SET @exists := (SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema=@db AND table_name='usuarios' AND column_name='nombre');
SET @sql := IF(@exists=0,
  'ALTER TABLE usuarios ADD COLUMN nombre VARCHAR(120) NOT NULL DEFAULT '''' AFTER id',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- correo
SET @exists := (SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema=@db AND table_name='usuarios' AND column_name='correo');
SET @sql := IF(@exists=0,
  'ALTER TABLE usuarios ADD COLUMN correo VARCHAR(160) NOT NULL DEFAULT '''' AFTER nombre',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- password_hash
SET @exists := (SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema=@db AND table_name='usuarios' AND column_name='password_hash');
SET @sql := IF(@exists=0,
  'ALTER TABLE usuarios ADD COLUMN password_hash VARCHAR(255) NOT NULL DEFAULT '''' AFTER correo',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- telefono
SET @exists := (SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema=@db AND table_name='usuarios' AND column_name='telefono');
SET @sql := IF(@exists=0,
  'ALTER TABLE usuarios ADD COLUMN telefono VARCHAR(30) NULL AFTER password_hash',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- rol
SET @exists := (SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema=@db AND table_name='usuarios' AND column_name='rol');
SET @sql := IF(@exists=0,
  'ALTER TABLE usuarios ADD COLUMN rol ENUM(''cliente'',''proveedor'',''admin'') NOT NULL DEFAULT ''cliente'' AFTER telefono',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- creado_en
SET @exists := (SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema=@db AND table_name='usuarios' AND column_name='creado_en');
SET @sql := IF(@exists=0,
  'ALTER TABLE usuarios ADD COLUMN creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER rol',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- actualizado_en
SET @exists := (SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema=@db AND table_name='usuarios' AND column_name='actualizado_en');
SET @sql := IF(@exists=0,
  'ALTER TABLE usuarios ADD COLUMN actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER creado_en',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- índice único en correo
SET @idx := (SELECT COUNT(*) FROM information_schema.statistics
  WHERE table_schema=@db AND table_name='usuarios' AND index_name='idx_usuarios_correo');
SET @sql := IF(@idx=0,
  'CREATE UNIQUE INDEX idx_usuarios_correo ON usuarios(correo)',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
