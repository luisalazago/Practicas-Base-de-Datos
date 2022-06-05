--2. Prueba

INSERT INTO t_productosorden 
VALUES(7284, 200, 500);

INSERT INTO t_productosorden 
VALUES(7284, 200, 20);

UPDATE t_productosorden
SET cantidad = 500
WHERE idproducto = 200 AND nroorden = 7284;

UPDATE t_productosorden
SET cantidad = 15
WHERE idproducto = 200 AND nroorden = 7284;

--3. Prueba
DECLARE
    t_prueba bonoTabla;
BEGIN
    t_prueba := bonoDescuento(10, 5, 2);
END;

--4. Prueba
BEGIN
    actualizarPrecio(20000);
END;

-- 5. Prueba
BEGIN
    borrarOrden(3983);
END;
