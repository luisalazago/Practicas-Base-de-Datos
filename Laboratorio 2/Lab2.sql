/*
    Caso Aplicación (Laboratorio 2)
    Autor: Luis Alberto Salazar.
    fecha: 18/02/2022.
*/

CREATE TABLE Matricula (
    nroMatricula NUMBER(19) PRIMARY KEY,
    fechaExpedicion DATE NOT NULL,
    placa CHAR(6) NOT NULL REFERENCES Carro,
    ciudad NUMBER(5) NOT NULL REFERENCES Ciudad,
    propietario NUMBER(10) NOT NULL REFERENCES Persona
);

CREATE TABLE Carro (
    Placa CHAR(6) PRIMARY KEY,
    nroMotor NUMBER(15) NOT NULL UNIQUE,
    nroChassis NUMBER(15) NOT NULL UNIQUE,
    modelo NUMBER(4) NOT NULL CHECK(modelo > 1950),
    capacidad NUMBER(2),
    tipo NUMBER(2) NOT NULL REFERENCES TipoCarro
);

CREATE TABLE TipoCarro (
    codigo NUMBER(2) PRIMARY KEY,
    descripcion CHAR(20)
);

CREATE TABLE Infraccion (
    codigo NUMBER(3) PRIMARY KEY,
    descripcion CHAR(50) NOT NULL,
    multaSalariosMin NUMBER(5) CHECK(multaSalariosMin >= 10)
);

CREATE TABLE InfraccionParte (
    codInfraccion NUMBER(3),
    nroParte NUMBER(10) PRIMARY KEY,
    valorMulta NUMBER(10,2) NOT NULL,
    FOREIGN KEY(codInfraccion) REFERENCES Infraccion(codigo),
    FOREIGN KEY(nroParte) REFERENCES Parte(nroParte)
);

CREATE TABLE Ciudad (
    codCiudad NUMBER(5) PRIMARY KEY,
    nombreCiudad CHAR(20)
);

CREATE TABLE Persona (
    cedula NUMBER(10) PRIMARY KEY,
    nombres CHAR(30) NOT NULL,
    apellidos CHAR(30) NOT NULL,
    direccion CHAR(30),
    telefono NUMBER(12),
    ciudadResidencia NUMBER(5) REFERENCES Ciudad
);

CREATE TABLE Parte (
    nroParte NUMBER(10) PRIMARY KEY,
    fechaHora DATE NOT NULL,
    conductor NUMBER(10) NOT NULL REFERENCES Persona,
    carro CHAR(6) NOT NULL REFERENCES Carro
);

CREATE TABLE Pago (
    nroRecibo NUMBER(12) PRIMARY KEY,
    fechaHora DATE NOT NULL,
    valor NUMBER(10, 2) NOT NULL,
    nroParte NUMBER(10) NOT NULL REFERENCES Parte
);








