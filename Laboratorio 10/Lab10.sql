/*

LABORATORIO 10
Autor: Luis Alberto Salazar

1. Escriba un bloque de programa que imprima en la salida del DBMS una cadena por cada
matriculado en una ciudad. La cadena debe tener la forma: “placa – modelo – marca”. El
procedimiento recibe como parámetro el nombre de la ciudad.
*/

CREATE OR REPLACE PROCEDURE mostrar_cadena(nombre VARCHAR) AS
	BEGIN
		FOR elems IN(SELECT matricula.placa AS placa_carro, modelo, descripcion
                     FROM tipocarro INNER JOIN carro
                     ON(codigo = tipo) INNER JOIN matricula 
                     ON(matricula.placa = carro.Placa) INNER JOIN ciudad
                     ON(matricula.ciudad = codciudad)
                     WHERE nombreciudad = nombre)
    
		LOOP
			DBMS_OUTPUT.PUT_LINE(elems.placa_carro||' - '||elems.modelo||' - '||elems.descripcion);
		END LOOP;
	END;

BEGIN
    mostrar_cadena('Cali');
END;

/*
2. Escriba un procedimiento que actualice el valor de multa en salarios mínimos de una infracción.
El procedimiento recibe como parámetros el porcentaje en que se incrementa el valor y el código
de la infracción.
*/

CREATE OR REPLACE PROCEDURE cambiar_saliomin(porcentaje NUMERIC, codigop NUMERIC) AS
	BEGIN
		UPDATE infraccion
		SET multasalariosmin = multasalariosmin + (porcentaje * 100)
		WHERE codigop = codigo;
	END;

/*
3. Escriba un procedimiento que reciba como parámetros el nombre de una persona y una fecha.
El procedimiento imprime en la salida del DBMS el número del(os) parte(s) que tiene esa persona
en la fecha dada, la placa del carro que conducía, la descripción de las infracciones que incluye
el parte, y el valor de la multa de cada infracción.
*/

CREATE OR REPLACE PROCEDURE num_partes(nombrep VARCHAR, fechap DATE) AS
	BEGIN
		FOR elems IN(SELECT valormulta, parte.nroparte AS num_par, placa AS placa_carro, descripcion
					 FROM infraccion INNER JOIN infraccionparte
					 ON(codigo = codinfraccion) INNER JOIN parte 
                     ON(infraccionparte.nroparte = parte.nroparte)INNER JOIN persona
					 ON(conductor = cedula) INNER JOIN carro
                     ON(placa = carro)
					 WHERE nombrep = nombres AND fechap = fechahora)

		LOOP
			DBMS_OUTPUT.PUT_LINE('Condcutor: '||nombrep||'\n'||'Parte numero: '||elems.num_par||'\n'||
								 'Placa: '||elems.placa_carro||'\n'||'Infracciones:\n'||elems.descripcion||
								 'multa: '||elems.valormulta||'\n');
		END LOOP;
	END;

/*
4. Escriba una función que reciba como parámetros el número de identificación de una persona y
un año; y retorna el valor total de los pagos realizados por esa persona durante el año dado.
*/

CREATE OR REPLACE FUNCTION pt(numid NUMERIC, agno NUMERIC) RETURN NUMERIC AS valor_total NUMERIC(20, 3);
	BEGIN
		SELECT SUM(valor) INTO valor_total
		FROM pago INNER JOIN parte
		ON(pago.nroparte = parte.nroparte) INNER JOIN persona
		ON(conductor = cedula)
		WHERE numid = cedula AND EXTRACT(YEAR FROM pago.fechahora) = agno;
		RETURN valor_total;
	END;

/*
5. Escriba un procedimiento que haga el registro de un pago. El procedimiento recibe como
parámetros la placa, la identificación del conductor, y el valor del pago. Con esos datos busca:
    a. El número de recibo siguiente (busca el mayor y suma uno)
    b. Busca el menor número de parte del conductor y placa dados que todavía no haya
    cancelado completamente sus multas (aquellos partes en que la suma de los pagos es
    menor que la suma de las multas de sus infracciones)
    
    Con esos datos inserta un registro en Pago, con la fecha y hora actuales.
*/

CREATE OR REPLACE PROCEDURE hacer_registro(placap NUMERIC, cedulap NUMERIC, valorp NUMERIC) AS
	BEGIN
		WITH regis_sig AS(SELECT MAX(nrorecibo)
						  FROM pago
						  GROUP BY nrorecibo),
			 parte_menor AS(SELECT MIN(parte.nroparte), MIN(placa)
			 				FROM pago INNER JOIN parte
			 				ON(pago.nroparte = parte.nroparte) NATURAL JOIN infraccionparte INNER JOIN
			 				ON(carro = placa) INNER JOIN persona
			 				ON(conductor = cedula)
			 				WHERE)

	END;