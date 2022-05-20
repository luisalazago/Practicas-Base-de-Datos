SELECT placa, nromotor, tipo FROM carro WHERE modelo > 2000;

SELECT parte.nroParte, pago.nroparte, parte.fechaHora, pago.fechahora, valor
    FROM parte INNER JOIN pago
    ON(parte.nroparte = pago.nroparte)
    WHERE EXTRACT(YEAR FROM parte.fechahora) = 2015;
    
SELECT placa, nromotor, nrochassis
    FROM carro NATURAL JOIN matricula NATURAL JOIN ciudad
    WHERE matricula.ciudad = ciudad.codciudad AND ciudad.nombreciudad LIKE 'B%';

SELECT placa, nromotor
    FROM carro
    WHERE modelo >= 2000 AND capacidad > 5 AND tipo = 10
    ORDER BY placa, nromotor;
    
SELECT nroParte, fechaHora, nombres, apellidos, modelo, descripcion, valorMulta
    FROM parte INNER JOIN persona 
    ON(parte.conductor = persona.cedula) INNER JOIN carro
    ON(carro.placa = parte.carro) NATURAL JOIN infraccionparte INNER JOIN infraccion
    ON(infraccionparte.codinfraccion = infraccion.codigo)
    WHERE EXTRACT(YEAR FROM parte.fechahora) = 2014 AND EXTRACT(MONTH FROM parte.fechahora) = 3;

SELECT DISTINCT nombreciudad
    FROM persona INNER JOIN ciudad
    ON(persona.ciudadresidencia = ciudad.codciudad) INNER JOIN parte
    ON(persona.cedula = parte.conductor) NATURAL JOIN infraccionparte INNER JOIN infraccion
    ON(infraccion.codigo = infraccionparte.codinfraccion)
    WHERE infraccion.codigo = 10;

SELECT DISTINCT nombres AS "MATRICULADOS"
    FROM persona INNER JOIN matricula
    ON(persona.cedula = matricula.propietario) INNER JOIN ciudad
    ON(matricula.ciudad = ciudad.codciudad) NATURAL JOIN carro
    WHERE persona.ciudadresidencia != ciudad.codciudad;

SELECT EXTRACT(DAY FROM CURRENT_DATE) - EXTRACT(DAY FROM fechahora) AS DIAS, carro AS "PLACA"
    FROM parte INNER JOIN persona
    ON(persona.cedula = parte.conductor)
    WHERE persona.nombres LIKE 'Paki%' 
    ORDER BY DIAS;
    
