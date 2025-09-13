-- 009_fix_app_user_pwd.sql  (idempotente)
-- Asegura que exista el usuario EXACTO y con la contraseña correcta,
-- aunque antes haya sido borrado por otras migraciones.

CREATE USER IF NOT EXISTS 'oficios_app'@'181.33.143.230' IDENTIFIED BY 'Oficios#2025!App';
ALTER  USER              'oficios_app'@'181.33.143.230' IDENTIFIED BY 'Oficios#2025!App';

GRANT SELECT, INSERT, UPDATE, DELETE ON `miappdb`.* TO 'oficios_app'@'181.33.143.230';
FLUSH PRIVILEGES;
