/*

LABORATORIO 7

Autor: Luis Alberto Salazar Gómez.

1. Se requiere agregar a la información de los carros el atributo Color, que tiene un texto.
*/

ALTER TABLE carro
ADD color CHAR(10);

/*
2. Se requiere agregar en la tabla TipoCarro una restricción para asegurar que el atributo descripción
no sea nulo.
*/

ALTER TABLE tipocarro
MODIFY descripcion NOT NULL;

/*
3. Modificar la tabla Pago, cuyo atributo fechaHora es no nulo, para que use como valor por defecto,
cuando no se provea ese atributo, la fecha actual del sistema.
*/

ALTER TABLE pago
MODIFY fechahora DEFAULT CURRENT_DATE;

/*
4. Agregar a la tabla Infraccion el atributo id que es un número de 5 dígitos. Cambie la clave primaria
de la tabla para que en adelante sea el id. Para ello, actualice los datos de la tabla, asignando el id a
partir de 1000, e incrementando de 1 en 1, según el orden en que aparezca cada registro.
*/

ALTER TABLE infraccionparte
DROP PRIMARY KEY;

ALTER TABLE infraccionparte
ADD infraid NUMBER(5);

UPDATE infraccionparte
SET infraid = ROWNUM + 999;

ALTER TABLE infraccionparte
MODIFY infraid PRIMARY KEY;

/*
5. Liste todas las ciudades y, si tienen personas que residen en ellas, el nombre y dirección de los
residentes.
*/

SELECT codciudad, nombreciudad, nombres, direccion
FROM ciudad LEFT OUTER JOIN persona ON(codciudad = ciudadresidencia);

/*
6. Liste todas las ciudades y si tienen partes registrados, el valor total de los pagos recibidos para esa
ciudad.
*/

SELECT codciudad, nombreciudad, parte.nroparte, valor
FROM ciudad LEFT OUTER JOIN persona
ON(codciudad = ciudadresidencia) INNER JOIN parte
ON(conductor = cedula) INNER JOIN pago ON(parte.nroparte = pago.nroparte);

/*
7. Liste todas las infracciones definidas en el sistema, y si están relacionadas con un parte que ha tenido
algún pago, el número de recibo y la fecha del pago.
*/

SELECT DISTINCT descripcion, nrorecibo, pago.fechahora
FROM infraccion LEFT OUTER JOIN infraccionparte 
ON(codigo = codinfraccion) NATURAL LEFT OUTER JOIN parte LEFT OUTER JOIN pago
USING(nroparte);











