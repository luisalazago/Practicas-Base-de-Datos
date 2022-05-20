/*

LABORATORIO 12
Autor: Luis Alberto Salazar

1) Se requiere una función que retorne reciba como parámetro el nombre de una ciudad y un año,
y retorne una tabla con los siguientes datos de las matrículas de ese año: número de matrícula,
fecha de expedición, placa, y descripción del tipo de carro.
*/

CREATE OR REPLACE TYPE t_datosMat AS OBJECT(nromatricula NUMBER(10),
fechaexpe DATE, placa CHAR(6), descripcion CHAR(20));

CREATE OR REPLACE TYPE t_tableDatosMat AS TABLE OF t_datosMat;

CREATE OR REPLACE FUNCTION datosMatriculas(nombre CHAR, agno NUMBER)
RETURN t_tableDatosMat AS
    v_dat t_tableDatosMat;
BEGIN
    SELECT t_datosMat(nromatricula, fechaexpedicion, carro.placa, descripcion)
    BULK COLLECT INTO v_dat
    FROM matricula INNER JOIN carro
    ON(matricula.placa = carro.placa) INNER JOIN tipocarro
    ON(carro.tipo = tipocarro.codigo) INNER JOIN ciudad
    ON(matricula.ciudad = codciudad)
    WHERE EXTRACT(YEAR FROM fechaexpedicion) = agno AND nombreciudad = nombre;
    
    RETURN v_dat;
END;

SELECT * FROM table(datosMatriculas('Cali', 2000));

/*
2) Escriba una función que reciba como parámetro un año y retorne una tabla. Cada registro de la
tabla tiene el nombre de una ciudad, y la información de cuantos partes han recibido los carros
matriculados en esa ciudad en los 4 años anteriores al dado.
* En este caso el atributo “partes? se refiere a la cantidad de partes dados para el año que se
recibió como parámetro. “Partes-1? para el año anterior, y así sucesivamente.
    a) Use ésta función en una consulta que retorne el total de partes registrados en cada uno de
    los años.
*/

CREATE OR REPLACE TYPE t_partesCarro AS OBJECT(nombreciudad NUMBER(10),
cantPartes NUMBER(10), cantPartes1 NUMBER(10), cantPartes2 NUMBER(10),
cantPartes3 NUMBER(10));

CREATE OR REPLACE TYPE t_tablePartesCarro AS TABLE OF t_partesCarro;

CREATE OR REPLACE FUNCTION countCal(agno NUMBER)
RETURN NUMBER AS
    CURSOR c1(agno NUMBER) IS SELECT COUNT(parte.nroparte)
                 FROM parte INNER JOIN persona
                 ON(conductor = cedula) INNER JOIN carro
                 ON(parte.carro = placa) NATURAL JOIN matricula INNER JOIN ciudad
                 ON(matricula.ciudad = codciudad)
                 WHERE EXTRACT(YEAR FROM fechahora) = agno;
    retorno NUMBER(30);
BEGIN
    OPEN c1(agno);
    FETCH c1 INTO retorno;
    CLOSE c1;

    RETURN retorno;
END;

CREATE OR REPLACE FUNCTION cantMatFecha(agno NUMBER)
RETURN t_tablePartesCarro AS
    v_dat t_tablePartesCarro;
BEGIN
    SELECT t_partesCarro(nombreciudad, countCal(agno), countCal(agno - 1), countCal(agno - 2), countCal(agno - 3))
    BULK COLLECT INTO v_dat
    FROM ciudad;

    RETURN v_dat;
END;

/*
3) Se va a ofrecer un descuento a los conductores con menos infracciones registradas. Se
requiere una función que retorne en una tabla los datos de los primeros diez conductores (con
menos infracciones), y el valor del descuento, calculado de esta forma:
- Para el primer conductor el 8% del valor de su ultimo parte
- Para el segundo y tercer conductor 6% del valor de su ultimo parte
- Para los puestos en 4º y 5º, 5%
- Y para los restantes 2%
Si varios conductores tienen la misma cantidad de infracciones, se da prioridad a quienes tienen
mas tiempo desde el último parte que recibieron.
*/

CREATE OR REPLACE TYPE t_conductores AS OBJECT(cedula NUMBER, nombres CHAR, apellidos CHAR, direccion CHAR,
                                     telefono NUMBER, ciudadresidencia NUMBER, descuento NUMBER);

CREATE OR REPLACE TYPE t_tablesCondcutores AS TABLE OF t_conductores;

CREATE OR REPLACE FUNCTION descuentoConductor(cedula NUMBER, fila NUMBER)
RETURN NUMBER AS
    CURSOR c2(ced NUMBER) IS SELECT valormulta
                             FROM persona INNER JOIN parte
                             ON(cedula = conductor) NATURAL JOIN infraccionparte
                             WHERE cedula = ced;
    retorno NUMBER(10);
    temporal NUMBER(10);
BEGIN
    OPEN c2(cedula);
    LOOP
        FETCH c2 INTO retorno;
    END LOOP;
    CLOSE c2;

    temporal :=  
        CASE
            WHEN fila = 1 THEN 8
            WHEN fila = 2 THEN 6
            WHEN fila = 3 THEN 6
            WHEN fila = 4 THEN 5
            WHEN fila = 5 THEN 5
            ELSE 2
        END;
    retorno := (retorno * temporal) / 100;

    RETURN retorno;
END;

CREATE OR REPLACE FUNCTION infraRegistradas RETURN t_tablesCondcutores AS
    v_dat t_tablesCondcutores;
BEGIN
    SELECT t_conductores(cedula, nombres, apellidos, direccion, telefono, ciudadresidencia, 
        CASE
            WHEN ROWNUM = 1 THEN descuentoConductor(cedula, 8)
            WHEN ROWNUM = 2 THEN descuentoConductor(cedula, 6)
            WHEN ROWNUM = 3 THEN descuentoConductor(cedula, 6)
            WHEN ROWNUM = 4 THEN descuentoConductor(cedula, 5)
            WHEN ROWNUM = 5 THEN descuentoConductor(cedula, 5)
            ELSE descuentoConductor(cedula, 2)
        END)
    BULK COLLECT INTO v_dat
    FROM infraccionparte NATURAL JOIN parte INNER JOIN persona
    ON(cedula = conductor)
    WHERE ROWNUM <= 10;

    RETURN v_dat;
END;

/*
4) Tomando como base la lógica de la función anterior, cree un procedimiento que use un CURSOR
FOR UPDATE para actualizar el valor de la multa en las infracciones del último parte de los
conductores, aplicando el descuento concedido según las condiciones del ejercicio anterior.
*/

CREATE OR REPLACE PROCEDURE cambiarValor(cedula NUMBER, fila NUMBER) AS
    CURSOR c3(ced NUMBER) IS SELECT valormulta
                             FROM persona INNER JOIN parte
                             ON(cedula = conductor) NATURAL JOIN infraccionparte
                             WHERE cedula = ced
                             FOR UPDATE OF valormulta;
    CURSOR c4(ced2 NUMBER) IS SELECT infraccionparte.nroparte
                             FROM persona INNER JOIN parte
                             ON(cedula = conductor) INNER JOIN infraccionparte
                             ON(infraccionparte.nroparte = parte.nroparte)
                             WHERE cedula = ced2;
    temporal NUMBER(10);
    temporal2 NUMBER(10);
    retorno NUMBER(10);
BEGIN
    OPEN c3(cedula);
    OPEN c4(cedula);
    LOOP
        FETCH c3 INTO retorno;
        FETCH c4 INTO temporal2;
    END LOOP;
    CLOSE c3;
    CLOSE c4;
    temporal :=  
        CASE
            WHEN fila = 1 THEN 8
            WHEN fila = 2 THEN 6
            WHEN fila = 3 THEN 6
            WHEN fila = 4 THEN 5
            WHEN fila = 5 THEN 5
            ELSE 2
        END;
    UPDATE infraccionparte
    SET valormulta = valormulta + (temporal * retorno) / 100
    WHERE temporal2 = nroparte;
END;
