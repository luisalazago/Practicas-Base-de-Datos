/* 

LABORATORIO 6

Autor: Luis Alberto Salazar.

1. Se va a incrementar en 3% los salarios mínimos que se cobran por las infracciones. Escriba
una sentencia que haga este incremento.
*/

UPDATE infraccion
SET multasalariosmin = CEIL(multasalariosmin * 1.03);

/*
2. Escriba una sentencia que actualice la fecha de expedición de la matrícula del carro de placa
JOQ093 expedida en fecha 14/10/2015. La fecha de expedición correcta es 14/10/2016
LABORATORIO 6
*/

UPDATE matricula
SET fechaexpedicion = '14/10/2016'
WHERE placa = 'JOQ093' AND fechaexpedicion = '14/10/2015';

/*
3. El parte número 17369348 tiene asociadas dos infracciones, una por cruzar el semáforo en
rojo (código 10) y otra por estacionar en lugar prohibido (código 20). Escriba una sentencia
que elimine de ese parte la infracción de código 20
*/

DELETE FROM infraccionparte
WHERE nroparte = 17369348 AND codinfraccion = 20;

/*
4. El parte número 4777379 tiene asociado un solo pago y varias infracciones. Escriba una
sentencia que actualice el valor del pago, con la totalidad de los valores de las multas de ese
parte.
*/

UPDATE pago
SET valor = (SELECT SUM(infraccionparte.valormulta) FROM infraccionparte WHERE infraccionparte.nroparte = 4777379)
WHERE pago.nroparte = 4777379;

/*
5. Escriba una sentencia para borrar la última matricula expedida en la ciudad de Cali.
*/

DELETE FROM matricula 
WHERE fechaexpedicion = (SELECT MAX(fechaexpedicion) FROM matricula
INNER JOIN ciudad ON(ciudad.codciudad = matricula.ciudad)
WHERE nombreciudad = 'Cali');

/*
6. Escriba una sentencia para actualizar las matriculas expedidas en Cali en el mes de
Diciembre de 2014, se requiere sumar un dia a la fecha de expedición de dichas matrículas.
*/

UPDATE (SELECT fechaexpedicion, nombreciudad, matricula.ciudad, codciudad
FROM matricula INNER JOIN ciudad ON(matricula.ciudad = codciudad)
WHERE nombreciudad = 'Cali' AND EXTRACT(MONTH FROM fechaexpedicion) = 12 AND EXTRACT(YEAR FROM fechaexpedicion) = 2014)
SET fechaexpedicion = fechaexpedicion + 1;

/*
7. Escriba una sentencia para actualizar el valor de las multas de los partes que se han puesto
a Dean Kirkland. Calcule el valor de cada infracción que ha cometido Dean, tomando los
valores definidos en la tabla infracciones y el valor del salario mínimo actual..

*/

UPDATE infraccionparte
SET valormulta = (SELECT multasalariosmin * valormulta FROM infraccion WHERE codigo = codinfraccion)
WHERE infraccionparte.nroparte IN (SELECT DISTINCT parte.nroparte FROM parte INNER JOIN persona ON(conductor = cedula)
WHERE nombres = 'Dean' AND apellidos = 'Kirkland');

/* 
8. Escriba una sentencia que actualice el c�digo as�: para cada registro de la tabla, el c�digo es
el n�mero de fila correspondiente. Use la funci�n ROWNUM para obtener el n�mero de la fila
de cada registro.
*/

CREATE TABLE PRUEBA (codigo NUMBER(2), dato CHAR(2));
INSERT INTO PRUEBA (dato) VALUES ('Aa');
INSERT INTO PRUEBA (dato) VALUES ('Bb');
INSERT INTO PRUEBA (dato) VALUES ('Cc');
INSERT INTO PRUEBA (dato) VALUES ('Dd');
INSERT INTO PRUEBA (dato) VALUES ('Ee');

UPDATE prueba
SET codigo = ROWNUM;










