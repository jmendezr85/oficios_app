-- 002_fix_fk_types.sql
-- Alinea tipos para llaves foráneas y crea valoraciones

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Asegurar que las tablas base usan BIGINT UNSIGNED en sus PK (coinciden con las FKs)
-- (Si ya están así, estos ALTER no dañan nada)
ALTER TABLE usuarios
  MODIFY id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;

ALTER TABLE servicios
  MODIFY id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;

-- Por si quedó algún intento previo, limpia valoraciones antes de crear
DROP TABLE IF EXISTS valoraciones;

-- Ahora crea valoraciones con tipos alineados
CREATE TABLE valoraciones (
  id           BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  usuario_id   BIGINT UNSIGNED NOT NULL,  -- referencia a usuarios.id
  servicio_id  BIGINT UNSIGNED NOT NULL,  -- referencia a servicios.id
  puntuacion   TINYINT UNSIGNED NOT NULL, -- 1..5
  comentario   VARCHAR(500),
  creado_en    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_valoraciones_usuario
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_valoraciones_servicio
    FOREIGN KEY (servicio_id) REFERENCES servicios(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  INDEX idx_valoraciones_servicio (servicio_id),
  INDEX idx_valoraciones_usuario (usuario_id),
  CONSTRAINT chk_puntuacion CHECK (puntuacion BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
