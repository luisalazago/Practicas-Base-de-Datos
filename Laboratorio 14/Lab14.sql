/*
LABORATORIO 14
Autor: Luis Alberto Salazar.

1. Cree los índices necesarios para mejorar el tiempo de respuesta de las siguientes consultas:
SELECT * FROM T_Cliente WHERE nombreDeUsuario = 'Calvin';
SELECT * FROM T_Cliente NATURAL JOIN T_Orden
WHERE fecha BETWEEN '01/06/2020' AND '31/10/2020';

Para mirar el plan de ejecución, agregue la sentencia EXPLAIN PLAN FOR antes del SELECT:
EXPLAIN PLAN FOR SELECT * FROM T_Cliente WHERE nombreDeUsuario = 'Calvin';

Una vez ejecutado el comando, use la siguiente sentencia para desplegar el plan de ejecución:
SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());
*/

-- SELECT * FROM T_Cliente WHERE nombreDeUsuario = 'Calvin';
CREATE INDEX calvo ON T_Cliente(nombredeusuario);
-- SELECT * FROM T_Cliente NATURAL JOIN T_Orden WHERE fecha BETWEEN '01/06/2020' AND '31/10/2020';
CREATE INDEX fechaOrden ON T_Orden(fecha);

EXPLAIN PLAN FOR SELECT * FROM T_Cliente WHERE nombreDeUsuario = 'Calvin';
EXPLAIN PLAN FOR SELECT * FROM T_Cliente NATURAL JOIN T_Orden WHERE fecha BETWEEN '01/06/2020' AND '31/10/2020';

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

/*
2. Escriba un trigger que evite agregar a una orden un producto en una cantidad mayor a la que
está disponible. En el mismo sentido, si se aumenta la cantidad de un producto en una orden,
evite que la diferencia supere la cantidad disponible del producto. Incluya en el script los casos
de prueba (casos en que se aborta la operación, casos exitosos).
*/

CREATE OR REPLACE TRIGGER evitarOrden
BEFORE INSERT OR UPDATE ON t_productosorden FOR EACH ROW
DECLARE canti NUMBER(4);
BEGIN
    SELECT cantidaddisp INTO canti 
    FROM t_producto
    WHERE :NEW.idproducto = t_producto.idproducto;
    CASE
        WHEN INSERTING THEN
            IF :NEW.cantidad > canti THEN
                Raise_application_error(-20000, 'El salario ingresado es mayor que el disponible: '
                                        ||:NEW.cantidad||' > '||canti||'.\n');
            END IF;
        WHEN UPDATING THEN
            IF :NEW.cantidad > :OLD.cantidad AND :NEW.cantidad - :OLD.cantidad > canti THEN
                Raise_application_error(-20001, 'La diferencia supera la cantidad disponible.\n');
            END IF;
    END CASE;
END;

/*
3. Se va a otorgar un bono de descuento a los n clientes con mayores compras (valor comprado) de
cada ciudad. Escriba una función PL que reciba 3 parámetros: El primero, n, indica cuantos
clientes elije de cada ciudad; el segundo, maxp, es el máximo porcentaje de descuento, que se
da al cliente con mayor valor comprado; y el tercero minp, es el porcentaje mínimo de descuento
que se va a otorgar. La función debe retornar una tabla con la identificación y nombre de cada
cliente seleccionado, la dirección, el nombre de la ciudad donde vive, y el valor del bono de
descuento. En cada ciudad, el cliente con mayor valor comprado recibe el maxp descuento, el
segundo cliente recibe maxp – 0.1, el siguiente maxp – 0.2, luego maxp – 0.3 y así
sucesivamente hasta llegar a minp, a partir de ese punto todos los clientes reciben el porcentaje
minp, hasta completar n clientes.
*/

CREATE OR REPLACE TYPE bono AS OBJECT(identificacion NUMBER(4), nombre CHAR(25), direccion CHAR(25),
                                      ciudadresidencia CHAR(15), valorBono NUMBER(10));

CREATE OR REPLACE TYPE bonoTabla AS TABLE OF bono;

CREATE OR REPLACE FUNCTION bonoDescuento(numero NUMBER, maxp NUMBER, minp NUMBER)
RETURN bonoTabla AS 
    v_bono bonoTabla;
    valor NUMBER(10);
BEGIN
    WITH valorCompra AS (SELECT SUM(precio) * cantidad AS valor
                         FROM t_producto NATURAL JOIN t_productosorden
                         GROUP BY cantidad)
    SELECT bono(idcliente, t_cliente.nombre, direccion, t_ciudad.nombre, 
                CASE
                    WHEN maxp - (ROWNUM / 10) > minp THEN (valor * maxp - (ROWNUM / 10)) / 100
                    ELSE (valor * minp) / 100
                END)
    BULK COLLECT INTO v_bono
    FROM valorCompra NATURAL JOIN t_cliente INNER JOIN t_ciudad
    USING(codciudad)
    WHERE ROWNUM <= numero
    ORDER BY valor ASC;

    RETURN v_bono;
END;

/*
4. Escriba un procedimiento que use el cursor for update para actualizar el precio de los productos
que al listar los productos en orden ascendente de su nombre ocupan las posiciones 3, 5, 8 y
12. El nuevo valor de esos productos llega como parámetro.
*/

CREATE OR REPLACE PROCEDURE actualizarPrecio(nuevo_precio NUMBER)
AS
    fila t_producto%ROWTYPE;
    CURSOR actua IS SELECT *
                    FROM t_producto
                    ORDER BY nombre ASC
                    FOR UPDATE OF t_producto.precio;
    it INTEGER(3);
BEGIN
    it := 1;
    FOR fila IN actua LOOP
        IF it = 3 THEN
            fila.precio := nuevo_precio;
        ELSIF it = 5 THEN
            fila.precio := nuevo_precio;
        ELSIF it = 8 THEN
            fila.precio := nuevo_precio;
        ELSIF it = 12 THEN
            fila.precio := nuevo_precio;
        END IF;
        it := it + 1;
    END LOOP;
END;

/*
5. Cuando se borra una factura se debe borrar la orden asociada a ella. Escriba un procedimiento
que reciba como parámetro el número de la factura, y se encargue de borrar la factura y su orden
asociada. Tenga en cuenta incluir el manejo transaccional y de excepciones.
*/

CREATE OR REPLACE PROCEDURE borrarOrden(numfactura NUMBER)
AS
BEGIN
    BEGIN
        SAVEPOINT cero;
        DELETE FROM t_factura
        WHERE nrofactura = numfactura;
        EXCEPTION WHEN NO_DATA_FOUND THEN ROLLBACK TO cero;
    END;
    BEGIN
        SAVEPOINT uno;
        DELETE FROM T_Orden
        WHERE nroorden IN (SELECT t_orden.nroorden
                           FROM t_factura INNER JOIN T_Orden
                           ON(t_factura.nroorden = T_Orden.nroorden)
                           WHERE nrofactura = numfactura);
        EXCEPTION WHEN NO_DATA_FOUND THEN ROLLBACK TO uno;
    END;
    COMMIT;
END;