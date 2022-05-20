/*

LABORATORIO DE REPASO

Autor: Luis Alberto Salazar.

1. Seleccione el id y nombre de los productos que no tienen una descripción definida y que están en al
menos 4 órdenes con estado “EnProceso�?
*/

SELECT idproducto, nombre, COUNT(nroorden) AS cont
FROM bd21.orden NATURAL JOIN bd21.productosorden NATURAL JOIN bd21.producto
WHERE estado = 'EnProceso' AND descripcion IS NULL
HAVING(COUNT(nroorden) >= 4)
GROUP BY idproducto, nombre;

/*
2. Liste el nombre del producto, el nombre de la categoría, y el precio de los productos que están en
órdenes del año 2020, pero no están en órdenes del año 2021.
*/

SELECT nombre, categoria.descripcion AS Nombre_Categoria, precio
FROM bd21.producto NATURAL JOIN bd21.productosorden NATURAl JOIN bd21.orden INNER JOIN bd21.categoria 
ON(bd21.producto.idcategoria = bd21.categoria.idcategoria)
WHERE EXTRACT(YEAR FROM fecha) = 2020
MINUS
SELECT nombre, categoria.descripcion AS Nombre_Categoria, precio
FROM bd21.producto NATURAL JOIN bd21.productosorden NATURAl JOIN bd21.orden INNER JOIN bd21.categoria 
ON(bd21.producto.idcategoria = bd21.categoria.idcategoria)
WHERE EXTRACT(YEAR FROM fecha) = 2021;

/*
3. Para las entidades bancarias que durante el año 2020 aplicaron pagos por más de $ 100.000.000,
seleccione el nombre de la entidad y el valor total facturado por cada mes de ese año. Ordene el
resultado por entidad y mes.
*/

SELECT entidad.nombre, SUM(precio * cantidad) AS sumpro
FROM bd21.producto INNER JOIN bd21.productosorden 
ON(bd21.producto.idproducto = bd21.productosorden.idproducto) INNER JOIN bd21.orden
ON(bd21.orden.nroorden = bd21.productosorden.nroorden) INNER JOIN bd21.factura
ON(bd21.orden.nroorden = bd21.factura.nroorden) INNER JOIN bd21.entidad
ON(bd21.entidad.identidad = bd21.factura.identidad)
WHERE EXTRACT(YEAR FROM factura.fecha) = 2020
GROUP BY entidad.nombre
HAVING(SUM(precio * cantidad) > 100000000)
ORDER BY entidad.nombre;
/*
4. Liste el nombre y el peso de todos los productos, y si aparece en órdenes del año 2019, la cantidad
total de ese producto que se tiene en esas órdenes.
*/

SELECT nombre, pesokg, SUM(cantidad) AS Suma_Cantidad
FROM bd21.producto LEFT OUTER JOIN bd21.productosorden
ON(bd21.producto.idproducto = bd21.productosorden.idproducto) LEFT OUTER JOIN bd21.orden
ON(bd21.orden.nroorden = bd21.productosorden.nroorden) LEFT OUTER JOIN (SELECT nroorden
                                                                        FROM bd21.orden
                                                                        WHERE EXTRACT(YEAR FROM (orden.fecha)) = 2019) orden2019
ON(productosorden.nroorden = orden2019.nroorden)
GROUP BY nombre, pesokg;

/*
5. Liste el nombre y la identificación de las personas que: durante el año 2019 compraron más (en
valor) que lo que en promedio compraron los clientes ese año, y también, esas mismas personas
compraron en 2020 más de lo que en promedio compraron los clientes ese año (tome en cuenta la
fecha de las facturas).
*/

WITH cant_procor AS (SELECT SUM(precio * cantidad) AS sumapro
					 FROM bd21.producto INNER JOIN bd21.productosorden
					 ON(bd21.producto.idproducto = bd21.productosorden.idproducto)
					 GROUP BY producto.idproducto),
	 procor_orden AS (SELECT SUM(sumapro) AS sum_sumapro
	 				  FROM bd21.orden INNER JOIN bd21.factura
	 				  ON(bd21.orden.nroorden = bd21.factura.nroorden) NATURAL JOIN cant_procor
	 				  GROUP BY orden.idcliente),
	 orden_cliente AS (SELECT SUM(sum_sumapro) AS sum_sum
	 				   FROM bd21.cliente NATURAL JOIN procor_orden
	 				   GROUP BY cliente.idcliente),
	 promedio AS (SELECT AVG(sum_sum) AS prom
	 			  FROM orden_cliente
	 			  GROUP BY sum_sum)
SELECT nombre, cliente.idcliente
FROM bd21.cliente INNER JOIN bd21.orden
ON(bd21.cliente.idcliente = bd21.orden.idcliente) INNER JOIN bd21.factura
ON(bd21.orden.nroorden = bd21.factura.nroorden) NATURAL JOIN promedio NATURAL JOIN orden_cliente
WHERE EXTRACT(YEAR FROM factura.fecha) = 2019
GROUP BY nombre, cliente.idcliente
HAVING(sum_sum > prom)
INTERSECT
SELECT nombre, cliente.idcliente
FROM bd21.cliente INNER JOIN bd21.orden
ON(bd21.cliente.idcliente = bd21.orden.idcliente) INNER JOIN bd21.factura
ON(bd21.orden.nroorden = bd21.factura.nroorden) NATURAL JOIN promedio NATURAL JOIN orden_cliente
WHERE EXTRACT(YEAR FROM factura.fecha) = 2020
GROUP BY nombre, cliente.idcliente
HAVING(sum_sum > prom);
/*
6. Se requiere clasificar el nivel de consumo de cada cliente en los últimos 3 años como ALTO,
MEDIO, o BAJO. El rango se asigna de acuerdo el mínimo y máximo valor de consumo (total de los
3 años) de los clientes. Se considera que el consumo es ALTO cuando está en el tercio superior
del rango entre el mínimo y el máximo; el consumo es BAJO cuando está en el tercio inferior de
ese rango; y, es MEDIO en los otros casos.
*/



/*
7. Se requiere listar los clientes que han registrado una dirección de correo que no corresponde con
el siguiente formato:
    • La dirección de correo electrónico consta de dos partes: el nombre del usuario y el
    dominio, ambos unidos por el símbolo arroba (@). El nombre del usuario está a la izquierda
    del símbolo, y el de dominio a la derecha.
    • El nombre del usuario puede incluir letras, números, guiones bajos (_), puntos (.), o
    guiones (-). Debe tener mínimo 5 caracteres.
    • El dominio puede incluir letras, números, guiones (-) y puntos (.). Ddebe tener al menos 3
    caracteres.
*/