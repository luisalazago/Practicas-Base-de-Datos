/* Punto 1 */

SELECT DISTINCT cedula, CONCAT(nombres, apellidos)
FROM persona INNER JOIN parte 
ON(conductor = cedula) NATURAL JOIN infraccionparte INNER JOIN infraccion
ON(codigo = codInfraccion)
WHERE EXTRACT(YEAR FROM fechahora) = 2015;

/* Punto 2 */

SELECT AVG(multasalariosmin) * 1000000 AS Promedio_Multas FROM infraccion;

/* Punto 3 */

SELECT COUNT(nroparte) AS Cantidad_Partes FROM parte WHERE EXTRACT(YEAR FROM fechahora) = 2014;

/* Punto 4 */

SELECT COUNT(nromatricula) AS Cantidad_Matriculas 
FROM matricula INNER JOIN ciudad ON(ciudad = codciudad)
GROUP BY matricula.ciudad;

/* Punto 5 */

SELECT nombreciudad
FROM parte INNER JOIN persona
ON(conductor = cedula) INNER JOIN ciudad
ON(ciudadresidencia = codciudad)
GROUP BY nombreciudad HAVING COUNT(nroparte) > 25;

/* Punto 6 */

SELECT MAX(valor) AS Mayor_Valor, MIN(valor) AS Menor_Valor
FROM pago
WHERE EXTRACT(YEAR FROM fechahora) = 2014;

/* Punto 7 */

SELECT STATS_MODE(capacidad) AS MODA, tipocarro.descripcion
FROM carro INNER JOIN tipocarro
ON(tipo = codigo)
GROUP BY capacidad, tipocarro.descripcion;

/* Punto 8 */

SELECT cedula, nombres, apellidos
FROM pago INNER JOIN parte
ON(pago.nroparte = parte.nroparte) INNER JOIN persona
ON(conductor = cedula)
WHERE EXTRACT(YEAR FROM pago.fechahora) = 2013 AND valor < 300000
GROUP BY cedula, nombres, apellidos;









