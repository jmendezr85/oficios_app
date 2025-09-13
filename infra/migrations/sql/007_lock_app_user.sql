-- 007_lock_app_user.sql

-- 1) Crear el usuario específico por IP (idempotente)
CREATE USER IF NOT EXISTS 'oficios_app'@'TU_IP_PUBLICA' IDENTIFIED BY 'Oficios#2025!App';

-- 2) Permisos mínimos para la app (CRUD en la base)
GRANT SELECT, INSERT, UPDATE, DELETE ON `miappdb`.* TO 'oficios_app'@'TU_IP_PUBLICA';

FLUSH PRIVILEGES;

-- NOTA: NO borramos 'oficios_app'@'%' todavía. Primero probamos conexión.
