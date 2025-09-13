-- 011_fix_app_user_current_ip.sql
-- Crea o corrige el usuario 'oficios_app' para TU IP pública actual
CREATE USER IF NOT EXISTS 'oficios_app'@'181.33.143.230' IDENTIFIED BY 'Oficios#2025!App';
ALTER  USER              'oficios_app'@'181.33.143.230' IDENTIFIED BY 'Oficios#2025!App';
GRANT SELECT, INSERT, UPDATE, DELETE ON miappdb.* TO 'oficios_app'@'181.33.143.230';
FLUSH PRIVILEGES;