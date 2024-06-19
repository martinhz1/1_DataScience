-- crear tabla peliculas
CREATE TABLE Peliculas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255),
    anno INTEGER 
);

-- crear tabla tags
CREATE TABLE Tags (
    id SERIAL PRIMARY KEY, -- id tipo serial y definimos como PK
    tag VARCHAR(32)
);

-- crear tabla intermedia por relacion N:N
CREATE TABLE Peliculas_Tags (
    pelicula_id INTEGER REFERENCES Peliculas(id), -- foreign key 
    tag_id INTEGER REFERENCES Tags(id), -- foreign key
    PRIMARY KEY (pelicula_id, tag_id)
);

--insertamos valores a peliculas
INSERT INTO Peliculas (nombre, anno)
VALUES ('Inception', 2010), ('Perfect Days', 2023), ('Zone Of Interest', 2023), ('Dune 2', 2024),
('Bo Burnham Inside', 2021); 

SELECT * FROM Peliculas; 

-- insertamos valores a tags
INSERT INTO Tags (tag)
VALUES ('Drama'), ('Comedia'), ('Suspenso'), ('Ciencia Ficcion'), ('Crimen'); 

SELECT * FROM tags; 

-- asociacion a tags 

-- asociar 3 tags a pelicula con id=1 
INSERT INTO Peliculas_Tags (pelicula_id, tag_id)
VALUES (1, 1), (1, 3), (1, 4);


-- asociar 2 tags a pelicula con id=2
INSERT INTO Peliculas_Tags (pelicula_id, tag_id)
VALUES (2, 1), (2, 2);

-- contar cuantos tags tiene cada pelicula
-- La subconsulta (SELECT COUNT(*) FROM Peliculas_Tags pt2 
--WHERE pt2.película_id = p.id) cuenta el número de registros en la tabla peliculas_tags 
--para cada película (p.id).
SELECT p.nombre,
       (SELECT COUNT(*) FROM Peliculas_Tags pt2 WHERE pt2.pelicula_id = p.id) AS COUNT_TAGS
FROM Peliculas p;

-- inception, que es la primera pelicula, cuenta con 3 tags
-- perfect days  que es la segunda pelicula con, cuenta con 2 tags
-- primera parte lista 1/05

-- SEGUNDA PARTE 2/05

-- crear tabla preguntas
CREATE TABLE preguntas (
  ID serial primary key, 
  pregunta varchar(255), 
  respuesta_correcta varchar);

--crear tabla usuarios
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(255),
    edad INTEGER);
    
CREATE TABLE respuestas (
    id serial PRIMARY KEY,
    respuesta varchar(255),
    usuario_id integer REFERENCES Usuarios(id),
    pregunta_id integer REFERENCES Preguntas(id)
);

-- insertamos los usuarios 
INSERT INTO usuarios (nombre, edad)
VALUES
  ('Julian', 28),
  ('Gabriela', 35),
  ('Valentina', 22),
  ('Eduardo', 40),
  ('Millaray', 31);

-- comprobamos
SELECT * FROM usuarios; 

-- insertamos preguntas y respuestas
INSERT INTO preguntas (pregunta, respuesta_correcta)
VALUES
  ('¿En que país se encuentra el circuito de F1 conocido como Silverstone?', 'Inglaterra'),  -- Pregunta 1
  ('¿En que ciudad se encuentra el Estadio Mario Alberto Kempes?', 'Cordova'),  -- Pregunta 2
  ('¿Cuantos albumes de estudio lanzó Pink Floyd?', '15'),  -- Pregunta 3
  ('¿Cuantos circuitos tendrá la temporada 2024 de la F1?', '24'),  -- Pregunta 4
  ('¿Cual es el pais mas grande de Africa?', 'Algeria');  -- Pregunta 5
  
select * from preguntas; 

-- Usuario 1 y 2 responden correctamente a la pregunta 1. Usuario 3, 4 y 5 no. 
INSERT INTO respuestas (respuesta, usuario_id, pregunta_id)
VALUES
  ('Inglaterra', 1, 1), ('Inglaterra', 2, 1), ('España', 3, 1), ('Malasia', 4, 1), ('USA', 5, 1);

-- Usuario 1 responde correctamente a la pregunta 2. Todos los demas no 
INSERT INTO respuestas (respuesta, usuario_id, pregunta_id)
VALUES
  ('Cordova', 1, 2), ('Buenos Aires', 2, 2), ('Montevideo', 3, 2), ('Asuncion', 4, 2), ('Medellin', 5, 2);
  
-- Preguntas 3, 4 y 5 solo respuestas incorrectas  
-- preg 3
INSERT INTO respuestas (respuesta, usuario_id, pregunta_id)
VALUES
  ('12', 1, 3), ('11', 2, 3), ('5', 3, 3), ('13', 4, 3), ('9', 5, 3);
  
--preg 4
INSERT INTO respuestas (respuesta, usuario_id, pregunta_id)
VALUES
  ('21', 1, 4), ('20', 2, 4), ('18', 3, 4), ('26', 4, 4), ('16', 5, 4);
  
-- preg 5
INSERT INTO respuestas (respuesta, usuario_id, pregunta_id)
VALUES
  ('Egipto', 1, 5), ('Congo', 2, 5), ('Sudafrica', 3, 5), ('Nigeria', 4, 5), ('Senegal', 5, 5);

-- Cuenta la cantidad de respuestas correctas totales por usuario (independiente de la pregunta) 
SELECT u.nombre, COUNT(r.id) AS respuestas_correctas
FROM Usuarios u
INNER JOIN Respuestas r ON u.id = r.usuario_id
WHERE r.respuesta = (
    SELECT p.respuesta_correcta
    FROM Preguntas p
    WHERE p.id = r.pregunta_id)
GROUP BY u.nombre;

-- Por cada pregunta, en la tabla preguntas, cuenta cuántos usuarios respondieron correctamente
SELECT p.pregunta, 
       (SELECT COUNT(DISTINCT r.usuario_id) 
        FROM Respuestas r 
        WHERE r.pregunta_id = p.id 
          AND r.respuesta = p.respuesta_correcta) AS usuarios_correctos
FROM Preguntas p;

-- Para implementar el borrado en cascada de las respuestas al eliminar un usuario en PostgreSQL,
--podemos modificar la tabla Respuestas agregando una restricción de clave foránea que referencie a la tabla Usuarios. 
--De esta manera, cuando se elimine un usuario,
-- todas las respuestas asociadas a ese usuario también se eliminarán automáticamente.
ALTER TABLE Respuestas 
DROP CONSTRAINT respuestas_usuario_id_fkey,
ADD CONSTRAINT respuestas_usuario_id_fkey
FOREIGN KEY (usuario_id) REFERENCES Usuarios(id)
ON DELETE CASCADE; 


-- Creamos tablas de respaldo para volver en caso de error
CREATE TABLE usuarios_copy AS 
TABLE usuarios;

CREATE TABLE respuestas_copy AS 
TABLE respuestas;

CREATE TABLE preguntas_copy AS 
TABLE preguntas;

-- comprueba haber borrado al usuario 1 
DELETE FROM usuarios
WHERE id = 1;

select * from usuarios; 

-- Crea una restricción que impida insertar usuarios menores de 18 años en la bbdd
ALTER TABLE Usuarios
ADD CONSTRAINT ck_edad_mayor_igual_18
CHECK (edad >= 18);

-- comprobamos

--error 
INSERT INTO usuarios (nombre, edad)
VALUES ('Mariana', 17);
--valido
INSERT INTO usuarios (nombre, edad)
VALUES ('Fito', 23);

select * from usuarios; 
 

ALTER TABLE usuarios
ADD COLUMN email VARCHAR(255) UNIQUE;

INSERT INTO usuarios (nombre, edad, email)
VALUES ('Pamela G.', 22, 'pamelag@gmail.com');

--error porque ya agregamos el mail pamelag@gmail.com
INSERT INTO usuarios (nombre, edad, email)
VALUES ('Pamela', 52, 'pamelag@gmail.com');




 
 










  
  

