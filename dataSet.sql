--Carga de datos --
EXEC CrearCategoria 'Alquiler';
EXEC CrearCategoria 'Salario';
EXEC CrearCategoria 'Supermercado';
EXEC CrearCategoria 'Transporte';
EXEC CrearCategoria 'Ocio';
EXEC CrearCategoria 'Inversion';
EXEC CrearCategoria 'Educacion';
EXEC CrearCategoria 'Salud';
EXEC CrearCategoria 'Tarjeta';
EXEC CrearCategoria 'Otros';


EXEC CrearAsesor 'Laura', 'Mendez', 11223344, 'lauramendez@asesores.com', '1982-03-15', 0.025;
EXEC CrearAsesor 'Pablo', 'Suarez', 22334455, 'pablosuarez@asesores.com', '1979-07-21', 0.03;
EXEC CrearAsesor 'Andrea', 'Gutierrez', 33445566, 'andreagutierrez@asesores.com', '1990-11-30', 0.015;
EXEC CrearAsesor 'Marcos', 'Alvarez', 44556677, 'marcosalvarez@asesores.com', '1987-02-05', 0.02;
EXEC CrearAsesor 'Carolina', 'Fernandez', 55667788, 'carolinafernandez@asesores.com', '1984-06-18', 0.04;

EXEC CrearUsuario 'Carlos', 'Garcia', 10101010, 'carlos@correo.com', '1990-01-01';
EXEC CrearUsuario 'Lucia', 'Martinez', 20202020, 'lucia@correo.com', '1992-02-02';
EXEC CrearUsuario 'Fernando', 'Lopez', 30303030, 'fernando@correo.com', '1985-03-03';
EXEC CrearUsuario 'Sofia', 'Gomez', 40404040, 'sofia@correo.com', '1995-04-04';
EXEC CrearUsuario 'Miguel', 'Fernandez', 50505050, 'miguel@correo.com', '1988-05-05';
EXEC CrearUsuario 'Valentina', 'Diaz', 60606060, 'valentina@correo.com', '1993-06-06';
EXEC CrearUsuario 'Javier', 'Ruiz', 70707070, 'javier@correo.com', '1987-07-07';
EXEC CrearUsuario 'Camila', 'Sanchez', 80808080, 'camila@correo.com', '1991-08-08';
EXEC CrearUsuario 'Martin', 'Torres', 90909090, 'martin@correo.com', '1989-09-09';
EXEC CrearUsuario 'Florencia', 'Ramos', 11111111, 'florencia@correo.com', '1994-10-10';
EXEC CrearUsuario 'Agustin', 'Moreno', 12121212, 'agustin@correo.com', '1991-11-11';
EXEC CrearUsuario 'Brenda', 'Castro', 23232323, 'brenda@correo.com', '1993-09-23';
EXEC CrearUsuario 'Diego', 'Herrera', 34343434, 'diego@correo.com', '1986-03-14';
EXEC CrearUsuario 'Elena', 'Vega', 45454545, 'elena@correo.com', '1994-06-28';
EXEC CrearUsuario 'Federico', 'Molina', 56565656, 'federico@correo.com', '1989-12-30';
EXEC CrearUsuario 'Gabriela', 'Silva', 67676767, 'gabriela@correo.com', '1992-08-05';
EXEC CrearUsuario 'Hernan', 'Gimenez', 78787878, 'hernan@correo.com', '1990-04-22';
EXEC CrearUsuario 'Ivana', 'Dominguez', 89898989, 'ivana@correo.com', '1995-07-17';
EXEC CrearUsuario 'Julian', 'Peralta', 90909091, 'julian@correo.com', '1988-10-02';
EXEC CrearUsuario 'Karina', 'Luna', 11224455, 'karina@correo.com', '1996-01-19';

INSERT INTO ASESOR_USUARIO VALUES (1, 1);
INSERT INTO ASESOR_USUARIO VALUES (2, 1);
INSERT INTO ASESOR_USUARIO VALUES (3, 1);
INSERT INTO ASESOR_USUARIO VALUES (4, 2);
INSERT INTO ASESOR_USUARIO VALUES (5, 2);
INSERT INTO ASESOR_USUARIO VALUES (6, 3);
INSERT INTO ASESOR_USUARIO VALUES (7, 3);
INSERT INTO ASESOR_USUARIO VALUES (8, 4);
INSERT INTO ASESOR_USUARIO VALUES (9, 5);
INSERT INTO ASESOR_USUARIO VALUES (10, 6);
INSERT INTO ASESOR_USUARIO VALUES (1, 7);
INSERT INTO ASESOR_USUARIO VALUES (4, 7);
INSERT INTO ASESOR_USUARIO VALUES (11, 1);
INSERT INTO ASESOR_USUARIO VALUES (12, 1);
INSERT INTO ASESOR_USUARIO VALUES (13, 2);
INSERT INTO ASESOR_USUARIO VALUES (14, 2);
INSERT INTO ASESOR_USUARIO VALUES (15, 3);
INSERT INTO ASESOR_USUARIO VALUES (16, 3);
INSERT INTO ASESOR_USUARIO VALUES (17, 4);
INSERT INTO ASESOR_USUARIO VALUES (18, 5);
INSERT INTO ASESOR_USUARIO VALUES (19, 6);
INSERT INTO ASESOR_USUARIO VALUES (20, 7);

EXEC CrearCuenta 'Credito', 'Santander', 1;
EXEC CrearCuenta 'Debito', 'Santander', 1;
EXEC CrearCuenta 'Inversion', 'UALINTEC', 1;
EXEC CrearCuenta 'Credito', 'Galicia', 2;
EXEC CrearCuenta 'Debito', 'Galicia', 2;
EXEC CrearCuenta 'Inversion', 'BALANZ', 2;
EXEC CrearCuenta 'Credito', 'BBVA', 3;
EXEC CrearCuenta 'Debito', 'BBVA', 3;
EXEC CrearCuenta 'Inversion', 'eTORO', 3;
EXEC CrearCuenta 'Credito', 'HSBC', 4;
EXEC CrearCuenta 'Debito', 'HSBC', 4;
EXEC CrearCuenta 'Inversion', 'BullMarket', 4;
EXEC CrearCuenta 'Credito', 'Macro', 5;
EXEC CrearCuenta 'Debito', 'Macro', 5;
EXEC CrearCuenta 'Inversion', 'UALINTEC', 5;
EXEC CrearCuenta 'Credito', 'Supervielle', 6;
EXEC CrearCuenta 'Debito', 'Supervielle', 6;
EXEC CrearCuenta 'Inversion', 'BALANZ', 6;
EXEC CrearCuenta 'Credito', 'NaranjaX', 7;
EXEC CrearCuenta 'Debito', 'NaranjaX', 7;
EXEC CrearCuenta 'Inversion', 'eTORO', 7;
EXEC CrearCuenta 'Credito', 'Brubank', 8;
EXEC CrearCuenta 'Debito', 'Brubank', 8;
EXEC CrearCuenta 'Inversion', 'BullMarket', 8;
EXEC CrearCuenta 'Credito', 'Ualá', 9;
EXEC CrearCuenta 'Debito', 'Ualá', 9;
EXEC CrearCuenta 'Inversion', 'UALINTEC', 9;
EXEC CrearCuenta 'Credito', 'ICBC', 10;
EXEC CrearCuenta 'Debito', 'ICBC', 10;
EXEC CrearCuenta 'Inversion', 'BALANZ', 10;
EXEC CrearCuenta 'Credito', 'Santander', 11;
EXEC CrearCuenta 'Debito', 'Santander', 11;
EXEC CrearCuenta 'Inversion', 'eTORO', 11;
EXEC CrearCuenta 'Credito', 'Galicia', 12;
EXEC CrearCuenta 'Debito', 'Galicia', 12;
EXEC CrearCuenta 'Inversion', 'BullMarket', 12;
EXEC CrearCuenta 'Credito', 'BBVA', 13;
EXEC CrearCuenta 'Debito', 'BBVA', 13;
EXEC CrearCuenta 'Inversion', 'UALINTEC', 13;
EXEC CrearCuenta 'Credito', 'HSBC', 14;
EXEC CrearCuenta 'Debito', 'HSBC', 14;
EXEC CrearCuenta 'Inversion', 'BALANZ', 14;
EXEC CrearCuenta 'Credito', 'Macro', 15;
EXEC CrearCuenta 'Debito', 'Macro', 15;
EXEC CrearCuenta 'Inversion', 'eTORO', 15;
EXEC CrearCuenta 'Credito', 'Supervielle', 16;
EXEC CrearCuenta 'Debito', 'Supervielle', 16;
EXEC CrearCuenta 'Inversion', 'BullMarket', 16;
EXEC CrearCuenta 'Credito', 'NaranjaX', 17;
EXEC CrearCuenta 'Debito', 'NaranjaX', 17;
EXEC CrearCuenta 'Inversion', 'UALINTEC', 17;
EXEC CrearCuenta 'Credito', 'Brubank', 18;
EXEC CrearCuenta 'Debito', 'Brubank', 18;
EXEC CrearCuenta 'Inversion', 'BALANZ', 18;
EXEC CrearCuenta 'Credito', 'Ualá', 19;
EXEC CrearCuenta 'Debito', 'Ualá', 19;
EXEC CrearCuenta 'Inversion', 'eTORO', 19;
EXEC CrearCuenta 'Credito', 'ICBC', 20;
EXEC CrearCuenta 'Debito', 'ICBC', 20;
EXEC CrearCuenta 'Inversion', 'BullMarket', 20;

EXEC CrearFechaTarjeta 1, '2025-07-01';
EXEC CrearFechaTarjeta 4, '2025-07-05';
EXEC CrearFechaTarjeta 7, '2025-07-10';
EXEC CrearFechaTarjeta 10, '2025-07-15';
EXEC CrearFechaTarjeta 13, '2025-07-20';
EXEC CrearFechaTarjeta 16, '2025-07-25';
EXEC CrearFechaTarjeta 19, '2025-07-30';

-- Fechas anteriores
EXEC CrearFechaTarjeta 1, '2025-06-01';
EXEC CrearFechaTarjeta 4, '2025-06-05';
EXEC CrearFechaTarjeta 7, '2025-06-10';
EXEC CrearFechaTarjeta 10, '2025-06-15';
EXEC CrearFechaTarjeta 13, '2025-06-20';
EXEC CrearFechaTarjeta 16, '2025-06-25';
EXEC CrearFechaTarjeta 19, '2025-06-30';

EXEC CrearFechaTarjeta 1, '2025-05-01';
EXEC CrearFechaTarjeta 4, '2025-05-05';
EXEC CrearFechaTarjeta 7, '2025-05-10';
EXEC CrearFechaTarjeta 10, '2025-05-15';
EXEC CrearFechaTarjeta 13, '2025-05-20';
EXEC CrearFechaTarjeta 16, '2025-05-25';
EXEC CrearFechaTarjeta 19, '2025-05-30';

-- Fechas futuras
EXEC CrearFechaTarjeta 1, '2025-08-01';
EXEC CrearFechaTarjeta 4, '2025-08-05';
EXEC CrearFechaTarjeta 7, '2025-08-10';
EXEC CrearFechaTarjeta 10, '2025-08-15';
EXEC CrearFechaTarjeta 13, '2025-08-20';
EXEC CrearFechaTarjeta 16, '2025-08-25';
EXEC CrearFechaTarjeta 19, '2025-08-30';


EXEC CrearMovimiento 1, 2, 'Ingreso', 80000;
EXEC CrearMovimiento 1, 3, 'Egreso', 15000;
EXEC CrearMovimiento 1, 4, 'Egreso', 5000;
EXEC CrearMovimiento 2, 2, 'Ingreso', 50000;
EXEC CrearMovimiento 2, 3, 'Egreso', 7000;
EXEC CrearMovimiento 2, 5, 'Egreso', 4000;
EXEC CrearMovimiento 3, 2, 'Ingreso', 100000;
EXEC CrearMovimiento 3, 6, 'Egreso', 20000;
EXEC CrearMovimiento 4, 2, 'Ingreso', 90000;
EXEC CrearMovimiento 4, 3, 'Egreso', 20000;
EXEC CrearMovimiento 4, 4, 'Egreso', 8000;
EXEC CrearMovimiento 5, 2, 'Ingreso', 60000;
EXEC CrearMovimiento 5, 3, 'Egreso', 9000;
EXEC CrearMovimiento 5, 5, 'Egreso', 5000;
EXEC CrearMovimiento 6, 2, 'Ingreso', 120000;
EXEC CrearMovimiento 6, 6, 'Egreso', 30000;
EXEC CrearMovimiento 7, 2, 'Ingreso', 95000;
EXEC CrearMovimiento 7, 3, 'Egreso', 25000;
EXEC CrearMovimiento 7, 4, 'Egreso', 10000;
EXEC CrearMovimiento 8, 2, 'Ingreso', 70000;
EXEC CrearMovimiento 8, 3, 'Egreso', 11000;
EXEC CrearMovimiento 8, 5, 'Egreso', 6000;
EXEC CrearMovimiento 9, 2, 'Ingreso', 150000;
EXEC CrearMovimiento 9, 6, 'Egreso', 50000;
EXEC CrearMovimiento 10, 2, 'Ingreso', 85000;
EXEC CrearMovimiento 10, 3, 'Egreso', 20000;
EXEC CrearMovimiento 10, 4, 'Egreso', 7000;
EXEC CrearMovimiento 11, 2, 'Ingreso', 65000;
EXEC CrearMovimiento 11, 3, 'Egreso', 9000;
EXEC CrearMovimiento 11, 5, 'Egreso', 4000;
EXEC CrearMovimiento 12, 2, 'Ingreso', 130000;
EXEC CrearMovimiento 12, 6, 'Egreso', 40000;
EXEC CrearMovimiento 13, 2, 'Ingreso', 92000;
EXEC CrearMovimiento 13, 3, 'Egreso', 15000;
EXEC CrearMovimiento 13, 4, 'Egreso', 6000;
EXEC CrearMovimiento 14, 2, 'Ingreso', 58000;
EXEC CrearMovimiento 14, 3, 'Egreso', 7000;
EXEC CrearMovimiento 14, 5, 'Egreso', 3000;
EXEC CrearMovimiento 15, 2, 'Ingreso', 110000;
EXEC CrearMovimiento 15, 6, 'Egreso', 35000;
EXEC CrearMovimiento 16, 2, 'Ingreso', 88000;
EXEC CrearMovimiento 16, 3, 'Egreso', 17000;
EXEC CrearMovimiento 16, 4, 'Egreso', 5000;
EXEC CrearMovimiento 17, 2, 'Ingreso', 62000;
EXEC CrearMovimiento 17, 3, 'Egreso', 8000;
EXEC CrearMovimiento 17, 5, 'Egreso', 4000;
EXEC CrearMovimiento 18, 2, 'Ingreso', 125000;
EXEC CrearMovimiento 18, 6, 'Egreso', 30000;
EXEC CrearMovimiento 19, 2, 'Ingreso', 91000;
EXEC CrearMovimiento 19, 3, 'Egreso', 16000;
EXEC CrearMovimiento 19, 4, 'Egreso', 7000;
EXEC CrearMovimiento 20, 2, 'Ingreso', 59000;
EXEC CrearMovimiento 20, 3, 'Egreso', 9000;
EXEC CrearMovimiento 20, 5, 'Egreso', 3000;
 
ASESOR ASESOR_USUARIO CATEGORIA CUENTAS FECHA_TARJETA INVERSION MOVIMIENTOS USUARIO

EXEC AgregarInversion 3, 'Accion', '12AB', 15, 500;
EXEC AgregarInversion 6, 'Plazo Fijo', '34CD', 10, 1000;
EXEC AgregarInversion 9, 'Fondo Comun de Inversion', '56EF', 20, 750;
EXEC AgregarInversion 12, 'CEDEAR', '78GH', 8, 1200;
EXEC AgregarInversion 15, 'Bono', '90IJ', 12, 600;
EXEC AgregarInversion 18, 'Criptomoneda', '11KL', 5, 3000;
EXEC AgregarInversion 3, 'Accion', '12AB', 15, 400;

EXEC AgregarInversion 3, 'Accion', 'A1FR', 10, 1000;
EXEC AgregarInversion 3, 'Bono', 'B2AR', 5, 1200;
EXEC AgregarInversion 3, 'Plazo Fijo', 'P3AR', 1, 15000;
EXEC AgregarInversion 3, 'Fondo Comun de Inversion', 'F4AR', 2, 7000;
EXEC AgregarInversion 3, 'Obligacion Negociable', 'O5AR', 3, 800;
EXEC AgregarInversion 3, 'Criptomoneda', 'C6AR', 10, 30000;
EXEC AgregarInversion 3, 'CEDEAR', 'D7AR', 8, 1100;
EXEC AgregarInversion 3, 'ETF', 'E8AR', 4, 2500;


UPDATE INVERSION SET PrecioActual = PrecioActual * 1.22 WHERE IDInversion = 7;   -- +22%
UPDATE INVERSION SET PrecioActual = PrecioActual * 1.48 WHERE IDInversion = 25;  -- +48%
UPDATE INVERSION SET PrecioActual = PrecioActual * 1.60 WHERE IDInversion = 27;  -- +60%
UPDATE INVERSION SET PrecioActual = PrecioActual * 2.05 WHERE IDInversion = 32;  -- +105%
UPDATE INVERSION SET PrecioActual = PrecioActual * 0.78 WHERE IDInversion = 26;  -- -22%
UPDATE INVERSION SET PrecioActual = PrecioActual * 0.55 WHERE IDInversion = 31;  -- -45%





EXEC VenderInversion 3, '12AB', 10, 6500;
EXEC VenderInversion 6, '34CD', 5, 1500;
EXEC VenderInversion 9, '56EF', 15, 1100;
EXEC VenderInversion 12, '78GH', 8, 1300;
EXEC VenderInversion 15, '90IJ', 12, 650;

INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (1, 2, 'Ingreso', 15000, '2025-06-01');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (1, 3, 'Egreso', 5000, '2025-06-05');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (2, 4, 'Ingreso', 12000, '2025-06-10');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (2, 5, 'Egreso', 4000, '2025-06-12');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (4, 6, 'Ingreso', 20000, '2025-05-20');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (4, 3, 'Egreso', 8000, '2025-05-25');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (7, 4, 'Ingreso', 30000, '2025-04-10');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (7, 5, 'Egreso', 10000, '2025-04-15');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (10, 2, 'Ingreso', 25000, '2025-03-05');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (10, 3, 'Egreso', 9000, '2025-03-08');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (13, 2, 'Ingreso', 18000, '2025-02-20');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (13, 4, 'Egreso', 6000, '2025-02-25');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (16, 2, 'Ingreso', 20000, '2025-01-10');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (16, 5, 'Egreso', 7000, '2025-01-15');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (19, 2, 'Ingreso', 30000, '2024-12-05');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (19, 3, 'Egreso', 12000, '2024-12-10');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (20, 2, 'Ingreso', 27000, '2024-11-15');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (20, 4, 'Egreso', 8000, '2024-11-20');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (8, 6, 'Egreso', 30228, '2024-08-28');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (15, 4, 'Ingreso', 4695, '2024-01-31');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (13, 6, 'Ingreso', 47991, '2024-11-25');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (13, 6, 'Egreso', 18494, '2024-11-29');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (16, 2, 'Egreso', 38633, '2024-12-18');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (8, 6, 'Ingreso', 37413, '2024-06-12');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (4, 4, 'Ingreso', 45178, '2025-05-06');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (10, 5, 'Ingreso', 32841, '2024-05-19');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (5, 6, 'Egreso', 30916, '2025-06-14');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (20, 5, 'Ingreso', 31291, '2024-07-26');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (1, 2, 'Ingreso', 48337, '2024-04-15');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (7, 4, 'Egreso', 31070, '2024-12-31');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (11, 5, 'Egreso', 40606, '2024-07-19');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (16, 2, 'Ingreso', 43637, '2024-07-28');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (5, 6, 'Egreso', 35929, '2024-05-19');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (3, 6, 'Egreso', 22791, '2024-07-23');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (20, 4, 'Ingreso', 38520, '2024-03-09');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (8, 6, 'Ingreso', 33029, '2024-10-12');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (4, 2, 'Ingreso', 47388, '2025-06-02');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (2, 4, 'Egreso', 44863, '2024-05-20');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (10, 2, 'Ingreso', 23527, '2024-08-17');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (14, 5, 'Egreso', 49946, '2024-04-17');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (7, 4, 'Ingreso', 30065, '2024-06-06');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (2, 5, 'Egreso', 12549, '2024-02-15');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (16, 3, 'Ingreso', 32626, '2024-12-10');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (18, 5, 'Ingreso', 44686, '2024-01-24');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (3, 5, 'Ingreso', 16492, '2024-06-06');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (2, 3, 'Ingreso', 49577, '2025-06-24');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (7, 4, 'Ingreso', 33123, '2024-05-01');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (2, 5, 'Ingreso', 38559, '2025-04-16');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (20, 6, 'Egreso', 28790, '2025-02-23');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (5, 4, 'Ingreso', 17514, '2024-02-18');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (9, 3, 'Ingreso', 46506, '2024-01-24');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (11, 4, 'Ingreso', 44784, '2024-03-12');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (20, 3, 'Egreso', 22107, '2024-06-02');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (11, 2, 'Ingreso', 31270, '2024-02-16');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (1, 5, 'Ingreso', 43457, '2025-04-26');
INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha) VALUES (4, 2, 'Ingreso', 47732, '2025-04-07');

UPDATE INVERSION
SET PrecioActual = PrecioActual * 1.0450
WHERE IDInversion = 1;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 0.9994
WHERE IDInversion = 2;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 0.9828
WHERE IDInversion = 3;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 1.0451
WHERE IDInversion = 4;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 0.9940
WHERE IDInversion = 5;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 0.9750
WHERE IDInversion = 6;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 0.9974
WHERE IDInversion = 7;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 1.0305
WHERE IDInversion = 8;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 1.0407
WHERE IDInversion = 9;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 1.0274
WHERE IDInversion = 10;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 0.9737
WHERE IDInversion = 11;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 1.0377
WHERE IDInversion = 12;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 0.9856
WHERE IDInversion = 13;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 0.9587
WHERE IDInversion = 14;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 1.0041
WHERE IDInversion = 15;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 0.9855
WHERE IDInversion = 16;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 1.0024
WHERE IDInversion = 17;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 1.0427
WHERE IDInversion = 18;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 0.9516
WHERE IDInversion = 19;

UPDATE INVERSION
SET PrecioActual = PrecioActual * 0.9667
WHERE IDInversion = 20;


GO