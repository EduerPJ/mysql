-- Consultas a la tabla libros:

-- Obtener todos los libros escritos por autores que cuenten con un seudónimo.
USE libreria_cf;
SELECT * FROM libros WHERE autor_id IN (
  SELECT autor_id FROM autores WHERE seudonimo IS NOT NULL
);

-- Obtener el título de todos los libros publicados en el año actual cuyos autores poseen un seudónimo.
SELECT titulo FROM libros WHERE DATE(fecha_publicacion) = CURDATE() AND autor_id IN(
    SELECT autor_id FROM autores WHERE seudonimo IS NOT NULL
);

-- Obtener todos los libros escritos por autores que cuenten con un seudónimo y que hayan nacido ante de 1965
SELECT * FROM libros WHERE autor_id IN(
  SELECT autor_id FROM autores WHERE seudonimo IS NOT NULL AND YEAR(fecha_nacimiento) <= 1965
);

-- Colocar el mensaje no disponible a la columna descripción, en todos los libros publicados antes del año 2000
-- Update rows in table 'libros'
UPDATE libros SET descripcion  = 'No disponible' WHERE YEAR(fecha_publicacion) < 2000;

-- Obtener la llave primaria de todos los libros cuya descripción sea diferente de no disponible
SELECT libro_id FROM libros WHERE descripcion != 'No disponible';

-- Obtener el título de los últimos 3 libros escritos por el autor con id 2.
SELECT titulo FROM libros WHERE autor_id = 2  ORDER BY libro_id DESC LIMIT 3;


-- Obtener en un mismo resultado la cantidad de libros escritos por autores con seudónimo y sin seudónimo.
SELECT(SELECT COUNT(*) FROM libros WHERE autor_id IN(
        SELECT autor_id FROM autores WHERE seudonimo IS NOT NULL
) ) AS 'Con seudonimo',
(
  SELECT COUNT(*) FROM libros WHERE autor_id IN(
    SELECT autor_id FROM autores WHERE seudonimo IS NULL
  )
) AS 'Sin seudonimo';

-- Obtener la cantidad de libros publicados entre enero del año 2000 y enero del año 2005
SELECT COUNT(*) AS 'Libros publicados entre enero 2000 y enero 2005' FROM libros WHERE DATE(fecha_publicacion) BETWEEN '2000-01-01' AND '2005-01-01'; 

-- Obtener el título y el número de ventas de los cinco libros más vendidos.
SELECT titulo, ventas FROM libros ORDER BY ventas DESC limit 5;

-- Obtener el título y el número de ventas de los cinco libros más vendidos de la última década.
SELECT titulo, ventas FROM libros WHERE YEAR(fecha_publicacion) >= 2010 ORDER BY ventas DESC LIMIT 5;

-- Obtener la cantidad de libros vendidos por los autores con id 1, 2 y 3.
SELECT autor_id AS autor, SUM(ventas) AS ventas FROM libros WHERE autor_id = 1 GROUP BY autor_id
UNION
SELECT autor_id AS autor, SUM(ventas) AS ventas FROM libros WHERE autor_id = 2 GROUP BY autor_id
UNION
SELECT autor_id AS autor, SUM(ventas) AS ventas FROM libros WHERE autor_id = 3 GROUP BY autor_id;

-- Obtener el título del libro con más páginas.
SELECT titulo FROM libros ORDER BY paginas DESC LIMIT 1;
-- OR
SELECT titulo, MAX(paginas) AS paginas FROM libros GROUP BY libro_id ORDER BY paginas DESC LIMIT 1;

-- Obtener todos los libros cuyo título comience con la palabra “La”.
SELECT * FROM libros WHERE titulo LIKE 'La%';

-- Obtener todos los libros cuyo título comience con la palabra “La” y termine con la letra “a”.
SELECT * FROM libros WHERE titulo LIKE 'La%%a';

-- Establecer el stock en cero a todos los libros publicados antes del año de 1995
UPDATE libros SET stock = 0 WHERE YEAR(fecha_publicacion) < 1995;

-- Mostrar el mensaje Disponible si el libro con id 1 posee más de 5 ejemplares en stock, en caso contrario mostrar el mensaje No disponible.
SELECT IF(stock > 5, 'Dispobible', 'No disponible') AS '¿Disponible?' FROM libros WHERE libro_id = 1;

-- Obtener el título los libros ordenador por fecha de publicación del más reciente al más viejo.
SELECT titulo FROM libros ORDER BY fecha_publicacion DESC;

-- ---------------------------------------------------
-- Consultas a la tabla autores:
-- Obtener el nombre de los autores cuya fecha de nacimiento sea posterior a 1950

SELECT nombre FROM autores WHERE YEAR(fecha_nacimiento) > 1950;

-- Obtener la el nombre completo y la edad de todos los autores.
SELECT CONCAT(nombre, ' ', apellido) AS 'nombre completo', fecha_nacimiento FROM autores;


-- Obtener el nombre completo de todos los autores cuyo último libro publicado sea posterior al 2005
SELECT CONCAT(nombre, ' ', apellido) AS 'nombre autores' FROM autores WHERE autor_id IN(
  SELECT autor_id FROM libros WHERE YEAR(fecha_publicacion) > 2005
);

-- Obtener el id de todos los escritores cuyas ventas en sus libros superen el promedio.
SET @promedio_ventas:=(SELECT AVG(ventas) FROM libros);

SELECT autor_id FROM autores WHERE autor_id IN(
  SELECT autor_id FROM libros WHERE ventas > @promedio_ventas
);

-- Obtener el id de todos los escritores cuyas ventas en sus libros sean mayores a cien mil ejemplares.
SELECT autor_id FROM autores WHERE autor_id IN(
  SELECT autor_id FROM libros WHERE ventas > 100000
);


-- --------------------------------
-- Funciones
-- Crear una función la cual nos permita saber si un libro es candidato a préstamo o no. Retornar “Disponible” si el libro posee por lo menos un ejemplar en stock, en caso contrario retornar “No disponible.”
DELIMITER //

CREATE FUNCTION disponible__prestamo_stock(id INT)
RETURNS VARCHAR(20)
BEGIN
SET @message = (SELECT IF(stock > 0, 'Dispobible', 'No disponible') AS '¿Disponible?' FROM libros WHERE libro_id = id);
RETURN @message;
END //

DELIMITER ;