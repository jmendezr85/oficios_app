-- 004_app_user.sql
-- Usuario de BD para la app (ajusta la contraseña a algo fuerte tuyo)
CREATE USER IF NOT EXISTS 'oficios_app'@'%' IDENTIFIED BY 'Oficios#2025!App';

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX
  ON miappdb.* TO 'oficios_app'@'%';

FLUSH PRIVILEGES;
