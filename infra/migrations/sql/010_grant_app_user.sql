-- 010_grant_app_user.sql
GRANT SELECT, INSERT, UPDATE, DELETE ON `miappdb`.* TO 'oficios_app'@'181.33.143.230';
FLUSH PRIVILEGES;
