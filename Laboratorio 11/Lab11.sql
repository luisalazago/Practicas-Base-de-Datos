/*

LABORATORIO 11
Autor: Luis Alberto Salazar.

1. Cree un trigger que asegure que cuando se inserta un registro en la tabla matricula la fecha de
expedición quede registrada con la fecha y hora actual.
Hint: Recuerde que se pueden asignar valores a los atributos de :NEW y los valores de :NEW son
los que quedarán guardados en la tabla.
*/

CREATE OR REPLACE TRIGGER horaVal
BEFORE INSERT ON matricula FOR EACH ROW
BEGIN
    SELECT current_timestamp INTO :NEW.fechaexpedicion FROM DUAL;
END;

/*
2. Cree un trigger que evite que se actualicen los datos y las infracciones de los partes que ya tienen
pagos realizados.
*/

CREATE OR REPLACE TRIGGER actData
AFTER UPDATE ON infraccionparte
DECLARE val NUMERIC(20);
BEGIN
    SELECT SUM(valor) INTO val FROM infraccionparte INNER JOIN parte 
    ON(infraccionparte.nroparte = parte.nroparte) INNER JOIN pago 
    ON(parte.nroparte = pago.nroparte);
    IF val > 0 THEN
        Raise_application_error(20000, 'Los pagos ya estan realizados, no se pueden actualizar los datos');
    END IF;
END;

/*
3. Agregue a la tabla Persona el atributo SaldoMultas. Cree los triggers necesarios para mantener
actualizado este valor en cada persona.
*/

ALTER TABLE persona
ADD saldoMultas NUMERIC(10);

CREATE OR REPLACE TRIGGER updateSaldoMulta
AFTER INSERT OR UPDATE OR DELETE ON pago FOR EACH ROW
BEGIN
    CASE
        WHEN INSERTING THEN
            UPDATE persona
            SET saldomultas = (SELECT saldomultas - :NEW.valor FROM persona INNER JOIN parte
                               ON(cedula = conductor) INNER JOIN pago
                               ON(parte.nroparte = pago.nroparte));
        WHEN UPDATING THEN
            UPDATE persona
            SET saldomultas = (SELECT (saldomultas + :OLD.valor) - :NEW.valor FROM persona INNER JOIN parte
                               ON(cedula = conductor) INNEr JOIN pago
                               ON(parte.nroparte = pago.nroparte));
        WHEN DELETING THEN
            UPDATE persona
            SET saldomultas = (SELECT saldomultas + :OLD.valor FROM persona INNER JOIN parte
                               ON(cedula = conductor) INNER JOIN pago
                               ON(parte.nroparte = pago.nroparte));
    END CASE;
END;

/*
4. Se requiere un trigger que evite registrar un pago por un valor mayor que el saldo de la deuda del
parte. El saldo de la deuda se calcula encontrando el total de la multa del parte (la suma de los
valores de sus infracciones) y restando el total de los pagos ya realizados.
*/

CREATE OR REPLACE TRIGGER mayorSaldo
BEFORE INSERT ON pago FOR EACH ROW
DECLARE saldoDeuda NUMERIC(10);
BEGIN
    SELECT SUM(valormulta) - SUM(valor) INTO saldoDeuda FROM infraccionparte INNER JOIN parte
                                                        ON(infraccionparte.nroparte = parte.nroparte) INNER JOIN pago
                                                        ON(pago.nroparte = parte.nroparte);
    IF :New.valor > saldoDeuda THEN
        Raise_application_error(20000, 'El pago: '||saldoDeuda||', es mayor que el saldo de la deuda.');
    END IF;
END;

