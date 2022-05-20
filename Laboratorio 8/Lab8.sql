/* 

LABORATORIO 8
Autor: Luis Alberto Salazar.

1. Liste el nombre de las ciudades que tienen carros matriculados o que tiene personas residentes.
Ordene el resultado alfabéticamente.
*/

SELECT nombreCiudad
FROM ciudad INNER JOIN matricula ON(codciudad = matricula.ciudad)
UNION
SELECT nombreCiudad
FROM ciudad INNER JOIN persona ON(codciudad = ciudadresidencia)
ORDER BY nombreciudad;

/*
2. Liste las placas de los carros que han sido matriculados en Cali y también, el mismo carro en otro
momento, en Bogotá.
*/

SELECT placa
FROM matricula INNER JOIN ciudad ON(matricula.ciudad = codciudad)
WHERE nombreciudad = 'Cali'
INTERSECT
SELECT placa
FROM matricula INNER JOIN ciudad ON(matricula.ciudad = codciudad)
WHERE nombreciudad = 'Bogota';

/*
3. Liste el nombre y apellido de las personas que han matriculado carros en Medellín pero, la misma
persona, no ha matriculado en Popayán.
*/

SELECT nombres, apellidos
FROM persona INNER JOIN matricula
ON(cedula = propietario) INNER JOIN ciudad
ON(matricula.ciudad = codciudad)
WHERE nombreciudad = 'Medellin'
MINUS
SELECT nombres, apellidos
FROM persona INNER JOIN matricula
ON(cedula = propietario) INNER JOIN ciudad
ON(matricula.ciudad = codciudad)
WHERE nombreciudad = 'Popayan';

/*
4. Calcule el promedio de valor de las multas impuestas en los partes (tenga en cuenta que un parte
puede tener varias infracciones y cada una genera un valor que se agrega a la multa del parte).
*/

WITH total AS (SELECT nroparte, SUM(valormulta) AS sumv
               FROM parte NATURAL JOIN infraccionparte
               GROUP BY nroparte)
SELECT AVG(sumv) AS promedio
FROM total;

/*
5. Liste las ciudades que en el año 2014 recibieron más ingresos por pago de multas que en el año
2015, muestre para cada ciudad la diferencia del ingreso.
*/

WITH diferenciaa AS (SELECT nombreciudad AS n1, codciudad AS c1, SUM(valor) AS v1
                    FROM parte INNER JOIN pago
                    USING(nroparte) INNER JOIN persona
                    ON(conductor = cedula) INNER JOIN ciudad
                    ON(codciudad = ciudadresidencia)
                    WHERE EXTRACT(YEAR FROM pago.fechahora) = 2014
                    GROUP BY codciudad, nombreciudad),
     diferenciab AS (SELECT nombreciudad AS n2, codciudad AS c2, SUM(valor) AS v2
                    FROM parte INNER JOIN pago
                    USING(nroparte) INNER JOIN persona
                    ON(conductor = cedula) INNER JOIN ciudad
                    ON(codciudad = ciudadresidencia)
                    WHERE EXTRACT(YEAR FROM pago.fechahora) = 2015
                    GROUP BY codciudad, nombreciudad)
SELECT nombreciudad, v1 - v2 AS diferencia
FROM ciudad NATURAL JOIN diferenciaa NATURAL JOIN diferenciab
WHERE v1 > v2;

/*
6. Liste, para cada año, el máximo valor pagado por una multa y la ciudad donde se puso la multa.
*/

WITH maximo AS (SELECT MAX(valormulta) AS maxi, nombreciudad
                FROM infraccionparte NATURAL JOIN parte INNER JOIN persona
                ON(conductor = cedula) INNER JOIN ciudad
                ON(ciudadresidencia = codciudad)
                GROUP BY maxi, nombreciudad)
SELECT EXTRACT(YEAR FROM fechahora) AS fecha
FROM parte NATURAL JOIN maximo;

/*
7. Liste las personas que en el año 2015 pagaron multas por menos de $ 500.000 en total, y
también (las mismas peronas) en 2013 pagaron multas por más de $ 600.000.
*/

WITH menor AS (SELECT nombres AS n1, apellidos AS a1, SUM(valormulta) AS v1
               FROM infraccionparte NATURAL JOIN parte INNER JOIN persona
               ON(cedula = conductor)
               WHERE v1 < 500000
               GROUP BY nombres, apellidos),
     mayor AS (SELECT nombres AS n2, apellidos AS a2, SUM(valormulta) AS v2
               FROM infraccionparte NATURAL JOIN parte INNER JOIN persona
               ON(cedula = conductor)
               WHERE v2 > 600000
               GROUP BY nombres, apellidos)
SELECT nombres, apellidos
FROM persona NATURAL JOIN menor
UNION
SELECT nombres, apellidos
FROM persona NATURAL JOIN mayor

/*
8. Liste los dueños que ha tenido el carro más antiguo registrado en el sistema (tome la fecha de
expedición de la matrícula para medir la antiguedad).
*/

WITH carmin AS (SELECT placa, MIN(fechaexpedicion) AS fechamin
                FROM matricula INNER JOIN persona
                ON(propietario = cedula)
                GROUP BY placa, fechamin)
SELECT nombres, apellidos
FROM persona NATURAL JOIN carmin;

/*
9. Se requiere listar las ciudades que en 2020 rentaron más carros que el promedio de los carros
rentados por todas las ciudades en ese mismo año.
*/

WITH con AS (SELECT COUNT(placa) AS cp, ciudad
             FROM matricula NATURAL JOIN carro
             WHERE EXTRACT(YEAR FROM fechaexpedicion) = 2020
             GROUP BY cp, ciudad),
     prom AS (SELECT AVG(cp) AS p
              FROM con)
SELECT nombreciudad, COUNT(placa) AS renta
FROM matricula INNER JOIN ciudad
ON(matricula.ciudad = codciudad) NATURAL JOIN prom
WHERE EXTRACT(YEAR FROM fechaexpedicion) = 2020 AND renta > p;

