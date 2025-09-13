SET NAMES utf8mb4;

SELECT COUNT(*) AS categorias FROM categorias;
SELECT COUNT(*) AS usuarios FROM usuarios;
SELECT COUNT(*) AS servicios FROM servicios;

SELECT s.id, s.nombre AS servicio, c.nombre AS categoria, s.precio_base
FROM servicios s
JOIN categorias c ON c.id = s.categoria_id
ORDER BY s.id;
