/*

LABORATORIO 13
Autor: Luis Alberto Salazar.

1. Seleccione 2 de las funciones o procedimientos que implementó en los laboratorios anteriores,
en las que identifique que puede incluir manejo de excepciones, y agregueles el manejo de las
excepciones que puedan ocurrir (excepciones del sistema nombradas o no, o excepciones de
usuario).
*/

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

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(20001, 'No se encontró el o los registro(s).\n');
END;

CREATE OR REPLACE FUNCTION cantMatFecha(agno NUMBER)
RETURN t_tablePartesCarro AS
    v_dat t_tablePartesCarro;
BEGIN

    SELECT t_partesCarro(nombreciudad, countCal(agno), countCal(agno - 1), countCal(agno - 2), countCal(agno - 3))
    BULK COLLECT INTO v_dat
    FROM ciudad;
    RETURN v_dat;

    EXCEPTION
        WHEN INVALID_CURSOR THEN
            dbms_output.put_line(SQLCODE||''||SQLERRM(SQLCODE));
END;

/*
2. Dado el siguiente procedimiento que crea un registro en infraccionParte, y sino está creado, crea
también el parte; modifiquelo para agregar manejo transaccional y de excepciones.
*/

INSERT INTO ciudad
VALUES(100001, 'TRUE');

CREATE OR REPLACE PROCEDURE creaInfParte(nroP NUMBER, cond NUMBER, placaP VARCHAR, codInf NUMBER, idInf NUMBER,
                                         salMin NUMBER)
AS
    existe NUMBER(2) DEFAULT 0;
    vMulta NUMBER(12);
    ceroError EXCEPTION;
BEGIN
    -- 1. Si no existe el parte, lo crea
    SELECT COUNT(*) INTO existe FROM Parte WHERE nroParte = nroP;
        IF existe = 0 THEN
            RAISE ceroError;
        END IF;
    -- 2. Obtiene el valor de la multa
    BEGIN
        SAVEPOINT cero;
        SELECT multaSalariosMin * salMin INTO vMulta FROM Infraccion
        WHERE codigo = codInf;
        EXCEPTION WHEN OTHERS THEN ROLLBACK TO cero;
    END;
    -- 3. Crea el registro de la infraccion (verificar que el orden de los atributos es correcto según su tabla)
    BEGIN
        SAVEPOINT uno;
        INSERT INTO infraccionParte VALUES (codInf, nroP, vMulta, idInf);
        EXCEPTION WHEN OTHERS THEN ROLLBACK TO uno;
    END;

    EXCEPTION
        WHEN ceroError THEN
            INSERT INTO Parte VALUES (nroP, SYSDATE, cond, placaP);
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(20001, 'No se encontró el o los registro(s).\n');
END;

/*
3. Cree una vista para la siguiente consulta: Liste para cada ciudad, por cada mes y año, el valor
total de las multas de ese mes de los carros matriculados en esa ciudad.
*/

CREATE VIEW multasMatriculados AS (
    SELECT nombreciudad, EXTRACT(MONTH FROM fechahora) AS Mes, EXTRACT(YEAR FROM fechahora) AS agno, 
    SUM(valormulta) AS Multas
    FROM infraccionParte NATURAL JOIN parte INNER JOIN carro
    ON(parte.carro = placa) INNER JOIN matricula
    ON(carro.placa = matricula.placa) INNER JOIN ciudad
    ON(matricula.ciudad = codciudad)
    GROUP BY nombreciudad, fechahora
);

/*
4. Use la vista que creó en el punto anterior en una consulta que calcule el promedio del valor
mensual de las multas en los meses del año 2019.
*/

SELECT AVG(Multas)
FROM multasMatriculados
WHERE agno = 2016;

/*
5. Seleccione 3 funciones que haya desarrollado y cree un paquete con ellas.
*/

CREATE OR REPLACE PACKAGE pckFunciones IS   
    FUNCTION infraRegistradas RETURN t_tablesCondcutores;
    
    FUNCTION cantMatFecha(agno NUMBER) RETURN t_tablePartesCarro; 
    
    FUNCTION datosMatriculas(nombre CHAR, agno NUMBER)
    RETURN t_tableDatosMat;
END;

CREATE OR REPLACE PACKAGE BODY pckFunciones IS
    FUNCTION infraRegistradas RETURN t_tablesCondcutores
    IS 
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

    FUNCTION cantMatFecha(agno NUMBER) RETURN t_tablePartesCarro
    IS
        v_dat t_tablePartesCarro;
    BEGIN
        SELECT t_partesCarro(nombreciudad, countCal(agno), countCal(agno - 1), countCal(agno - 2), countCal(agno - 3))
        BULK COLLECT INTO v_dat
        FROM ciudad;
        RETURN v_dat;

        EXCEPTION
            WHEN INVALID_CURSOR THEN
                dbms_output.put_line(SQLCODE||''||SQLERRM(SQLCODE));
    END;

    FUNCTION datosMatriculas(nombre CHAR, agno NUMBER) RETURN t_tableDatosMat
    IS
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

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(20001, 'No se encontró el o los registro(s).\n');
    END;
END;
