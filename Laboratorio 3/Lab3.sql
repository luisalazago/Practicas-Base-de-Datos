INSERT INTO Ciudad VALUES(76001, 'Cali');
INSERT INTO Ciudad VALUES(11001, 'Bogota');
INSERT INTO Ciudad VALUES(05001, 'Medellin');
INSERT INTO Ciudad VALUES(08001, 'Barranquilla');
INSERT INTO Ciudad VALUES(19001, 'Popayan');

INSERT INTO tipoCarro VALUES(10, 'Particular');
INSERT INTO tipoCarro VALUES(20, 'Publico');
INSERT INTO tipoCarro VALUES(30, 'Diplomatico');
INSERT INTO tipoCarro VALUES(40, 'Oficial');
INSERT INTO tipoCarro VALUES(50, 'Especial');

INSERT INTO infraccion SELECT * FROM BD20.infraccion;
SELECT COUNT(*) FROM infraccion;

INSERT INTO persona SELECT * FROM BD20.persona;
SELECT COUNT(*) FROM persona;

SELECT COUNT(*) FROM carro;

SELECT COUNT(*) FROM carro;
SELECT COUNT(*) FROM ciudad;
SELECT COUNT(*) FROM infraccion;
SELECT COUNT(*) FROM infraccionparte;
SELECT COUNT(*) FROM matricula;
SELECT COUNT(*) FROM pago;
SELECT COUNT(*) FROM parte;
SELECT COUNT(*) FROM persona;
SELECT COUNT(*) FROM tipocarro;