SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO categorias (nombre) VALUES
  ('Carpintería'),
  ('Electricidad'),
  ('Plomería')
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre);

INSERT INTO usuarios (nombre, correo, password_hash, telefono, rol) VALUES
  ('Cliente Demo', 'cliente@demo.com', '$2b$12$7u7u7u7u7u7u7u7u7u7u7uO9v8x7y6z5w4v3u2t1s0r9q8p7o6', '3001234567', 'cliente')
ON DUPLICATE KEY UPDATE telefono = VALUES(telefono), rol = VALUES(rol);

INSERT INTO usuarios (nombre, correo, password_hash, telefono, rol) VALUES
  ('Proveedor Demo', 'pro@demo.com', '$2b$12$1a2b3c4d5e6f7g8h9i0j1kLmNoPqRsTuVwXyZ0123456789abcd12', '3007654321', 'proveedor')
ON DUPLICATE KEY UPDATE telefono = VALUES(telefono), rol = VALUES(rol);

INSERT INTO servicios (categoria_id, nombre, descripcion, precio_base, activo)
SELECT c.id, 'Instalación de toma eléctrica', 'Instalación de toma 110V', 80000, 1
FROM categorias c WHERE c.nombre = 'Electricidad'
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion), precio_base = VALUES(precio_base), activo = VALUES(activo);

INSERT INTO servicios (categoria_id, nombre, descripcion, precio_base, activo)
SELECT c.id, 'Reparación de fuga', 'Reparación básica de fuga de agua', 70000, 1
FROM categorias c WHERE c.nombre = 'Plomería'
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion), precio_base = VALUES(precio_base), activo = VALUES(activo);

INSERT INTO servicios (categoria_id, nombre, descripcion, precio_base, activo)
SELECT c.id, 'Fabricación de mueble', 'Mueble simple a medida', 250000, 1
FROM categorias c WHERE c.nombre = 'Carpintería'
ON DUPLICATE KEY UPDATE descripcion = VALUES(descripcion), precio_base = VALUES(precio_base), activo = VALUES(activo);

SET FOREIGN_KEY_CHECKS = 1;
