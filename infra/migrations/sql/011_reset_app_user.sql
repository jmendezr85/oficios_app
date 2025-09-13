-- 011_reset_app_user.sql
-- Resetea el usuario de app tanto por IP actual como comodín (temporal)

-- Limpieza previa (no falla si no existen)
DROP USER IF EXISTS 'oficios_app'@'181.33.143.230';
DROP USER IF EXISTS 'oficios_app'@'%';

-- Recreación con la contraseña del .env
CREATE USER 'oficios_app'@'181.33.143.230' IDENTIFIED BY 'Oficios#2025!App';
CREATE USER 'oficios_app'@'%'   IDENTIFIED BY 'Oficios#2025!App';

-- Permisos mínimos
GRANT SELECT, INSERT, UPDATE, DELETE ON miappdb.* TO 'oficios_app'@'181.33.143.230';
GRANT SELECT, INSERT, UPDATE, DELETE ON miappdb.* TO 'oficios_app'@'%';

FLUSH PRIVILEGES;