-- 008_drop_wildcard_user.sql
DROP USER IF EXISTS 'oficios_app'@'%';
FLUSH PRIVILEGES;
