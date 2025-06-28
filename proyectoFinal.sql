CREATE DATABASE TrabajoPracticoFinal;

--Comienzo Tablas
CREATE TABLE USUARIO (
IDUsuario int identity (1,1) constraint PK_USUARIO primary key,
Nombre varchar (40) Not null,
Apellido varchar (40) not null,
DNI INT,
Correo varchar (100) not null,
FechaNacimiento date,
constraint CorreoCheck CHECK (Correo LIKE '_%@_%.com%'),
CHECK (Nombre like '%[a-zA-Z]%'),
CHECK (Apellido like '%[a-zA-Z]%'));

CREATE TABLE ASESOR (
IDAsesor int identity (1,1) constraint PK_Asesor primary key,
Nombre varchar (40) not null CHECK (Nombre like '%[a-zA-Z]%'),
Apellido varchar (40) not null CHECK (Apellido like '%[a-zA-Z]%'),
DNI INT not null,
Correo varchar(100) not null,
FechaNacimiento date not null,
Comision DECIMAL(5,4) NOT NULL CHECK (Comision >= 0.001 AND Comision <= 0.05),
constraint CorreoAsesorCheck CHECK (Correo LIKE '_%@_%.com%'));

CREATE TABLE CATEGORIA(
IDCategoria int identity (1,1) constraint PK_Categoria primary key,
NombreCategoria varchar (40) not null);

CREATE TABLE CUENTAS 
(IDCuenta int identity (1,1) constraint PK_CUENTAS primary key,
TipoCuenta varchar (10) not null,
NombreCuenta varchar (20) not null,
IDUsuario int,
FOREIGN KEY (IDUsuario) references USUARIO(IDUsuario),
CHECK (TipoCuenta like '%[a-zA-Z]%'),
CHECK (NombreCuenta like '%[a-zA-Z]%'));

CREATE TABLE ASESOR_USUARIO (
IDUsuario int not null,
IDAsesor int not null,
FOREIGN KEY (IDAsesor) REFERENCES ASESOR(IDAsesor),
FOREIGN KEY (IDUsuario) REFERENCES USUARIO(IDUsuario),
CONSTRAINT PK_AsesorUsuario PRIMARY KEY (IDUsuario, IDAsesor));

CREATE TABLE MOVIMIENTOS (
IDMovimiento int identity (1,1) constraint PK_Movimiento primary key,
IDCuenta int not null,
IDCategoria int not null,
TipoMovimiento varchar (25) not null CHECK (TipoMovimiento IN ('Ingreso', 'Egreso')),
Importe float not null CHECK (Importe >= 0),
Fecha datetime  default GETDATE(),
FOREIGN KEY (IDCuenta) references CUENTAS(IDCuenta),
FOREIGN KEY (IDCategoria) references CATEGORIA(IDCategoria));

CREATE TABLE INVERSION (
IDInversion int identity (1,1) constraint PK_IDInversion primary key,
IDCuenta int not null,
TipoActivo varchar(20) NOT NULL CHECK (TipoActivo IN (
    'Accion',
    'Bono',
    'Plazo Fijo',
    'Fondo Comun de Inversion',
    'Obligacion Negociable',
    'Criptomoneda',
    'CEDEAR',
    'ETF',
    'Commodity',
    'Opcion'
)),
Nombre varchar (4) not null CHECK (Nombre LIKE '[0-9][0-9][A-Z][A-Z]'),
Cantidad int not null CHECK (Cantidad > 0),
PrecioCompra float not null CHECK (PrecioCompra > 0),
PrecioActual float not null CHECK (PrecioActual > 0),
FOREIGN KEY (IDCuenta) references CUENTAS(IDCuenta));

CREATE TABLE FECHA_TARJETA (
IDTarjeta int identity (1,1) constraint PK_Tarjeta primary key,
IDCuenta int,
FechaCierre date,
Foreign key (IDCuenta) references CUENTAS(IDCuenta));

--PROCEDIMIENTOS DE CREAR

GO
CREATE PROC CrearCuenta
	@TipoCuenta varchar (10),
	@NombreCuenta varchar (20),
	@IDUsuario int
AS
BEGIN
	INSERT INTO CUENTAS (TipoCuenta,NombreCuenta,IDUsuario)
	VALUES (@TipoCuenta, @NombreCuenta, @IDUsuario);
END;
GO

CREATE PROC CrearAsesor
	@Nombre varchar (40),
	@Apellido varchar (40),
	@DNI int,
	@Correo varchar (100),
	@FechaNacimiento date,
	@Comision float
AS
BEGIN
	INSERT INTO ASESOR (Nombre, Apellido, DNI, Correo, FechaNacimiento, Comision)
	VALUES (@Nombre, @Apellido, @DNI, @Correo, @FechaNacimiento, @Comision);
END;
GO

CREATE PROC CrearCategoria
	@NombreCategoria varchar (40)
AS
BEGIN
	INSERT INTO CATEGORIA (NombreCategoria)
	VALUES (@NombreCategoria);
END;
GO

CREATE PROC CrearFechaTarjeta
	@IDCuenta int,
	@FechaCierre date
AS
BEGIN
	INSERT INTO FECHA_TARJETA (IDCuenta, FechaCierre)
	VALUES (@IDCuenta, @FechaCierre);
END;
GO

CREATE PROC AgregarInversion
    @IDCuenta INT,
    @TipoActivo VARCHAR(30),
    @Nombre VARCHAR(4),
    @Cantidad INT,
    @PrecioCompra FLOAT
AS
BEGIN
    DECLARE @IDUsuario INT;
    DECLARE @Comision FLOAT = 0;
    DECLARE @PrecioCompraFinal FLOAT = 0;
    DECLARE @SaldoDisponible FLOAT = 0;
    DECLARE @TotalCompra FLOAT = 0;

    -- Buscar el usuario dueño de la cuenta
    SELECT @IDUsuario = IDUsuario FROM CUENTAS WHERE IDCuenta = @IDCuenta;

    -- Buscar la comisión del asesor asociado
    SELECT TOP 1 @Comision = A.Comision
    FROM ASESOR A
    INNER JOIN ASESOR_USUARIO AU ON A.IDAsesor = AU.IDAsesor
    WHERE AU.IDUsuario = @IDUsuario;

    -- Calcular precio de compra final con comisión
    SET @PrecioCompraFinal = @PrecioCompra * (1 + ISNULL(@Comision, 0));
    SET @TotalCompra = @PrecioCompraFinal * @Cantidad;

    -- Consultar saldo disponible desde la función
    SELECT @SaldoDisponible = dbo.SaldoCuenta(@IDCuenta);

    IF @SaldoDisponible < @TotalCompra
    BEGIN
        PRINT 'ERROR: Saldo insuficiente para realizar la compra.';
        RETURN;
    END

    -- Registrar la inversión con el precio con comisión
    INSERT INTO INVERSION (IDCuenta, TipoActivo, Nombre, Cantidad, PrecioCompra, PrecioActual)
    VALUES (@IDCuenta, @TipoActivo, @Nombre, @Cantidad, @PrecioCompraFinal, @PrecioCompraFinal);

    -- Registrar el movimiento tipo Egreso por la compra
    INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha)
    VALUES (@IDCuenta, (SELECT IDCategoria FROM CATEGORIA WHERE NombreCategoria = 'Inversion'), 'Egreso', @TotalCompra, GETDATE());

    PRINT 'Compra registrada correctamente con comisión aplicada.';
END;
GO

CREATE OR ALTER PROC VenderInversion
    @IDCuenta INT,
    @Nombre VARCHAR(4), 
    @CantidadVendida INT,
    @PrecioVenta FLOAT
AS
BEGIN
    DECLARE @IDUsuario INT;
    DECLARE @Comision FLOAT = 0;
    DECLARE @PrecioVentaFinal FLOAT = 0;
    DECLARE @CantidadActual INT;

    -- Buscar el usuario dueño de la cuenta
    SELECT @IDUsuario = IDUsuario FROM CUENTAS WHERE IDCuenta = @IDCuenta;

    -- Buscar la comisión del asesor asociado
    SELECT TOP 1 @Comision = A.Comision
    FROM ASESOR A
    INNER JOIN ASESOR_USUARIO AU ON A.IDAsesor = AU.IDAsesor
    WHERE AU.IDUsuario = @IDUsuario;

    -- Buscar la cantidad actual de la inversión
    SELECT @CantidadActual = Cantidad 
    FROM INVERSION 
    WHERE IDCuenta = @IDCuenta AND Nombre = @Nombre;

    -- Verificar si existe la inversión
    IF @CantidadActual IS NULL
    BEGIN
        PRINT 'Error: La inversión no existe para esta cuenta.';
        RETURN;
    END

    -- Verificar si hay suficientes activos para vender
    IF @CantidadVendida > @CantidadActual
    BEGIN
        PRINT 'Error: No se pueden vender más activos de los que se tienen.';
        RETURN;
    END

    -- Calcular precio final con comisión
    SET @PrecioVentaFinal = @PrecioVenta * (1 - ISNULL(@Comision, 0));

    -- Registrar el movimiento solo si la inversión existe
    INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha)
    VALUES (@IDCuenta, (SELECT IDCategoria FROM CATEGORIA WHERE NombreCategoria = 'Inversion'), 'Ingreso', @PrecioVentaFinal * @CantidadVendida, GETDATE());

    -- Si vendió todo, eliminar la inversión
    IF @CantidadVendida = @CantidadActual
    BEGIN
        DELETE FROM INVERSION WHERE IDCuenta = @IDCuenta AND Nombre = @Nombre;
        PRINT 'Venta completa: La inversión fue eliminada.';
    END
    ELSE
    BEGIN
        UPDATE INVERSION
        SET Cantidad = Cantidad - @CantidadVendida
        WHERE IDCuenta = @IDCuenta AND Nombre = @Nombre;

        PRINT 'Venta parcial: La cantidad de la inversión fue actualizada.';
    END
END;
GO

CREATE PROC CrearMovimiento
	@IDCuenta int,
	@IDCategoria int,
	@TipoMovimiento varchar (25),
	@Importe Float
AS
BEGIN
	INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe)
	VALUES (@IDCuenta, @IDCategoria, @TipoMovimiento, @Importe);
END
GO

CREATE PROC CrearUsuario
	@Nombre varchar (40),
	@Apellido varchar (40),
	@DNI int,
	@Correo varchar (100),
	@FechaNacimiento date
AS
BEGIN
	INSERT INTO USUARIO (Nombre, Apellido, DNI, Correo, FechaNacimiento)
	VALUES (@Nombre, @Apellido, @DNI, @Correo, @FechaNacimiento);
END
GO

--PROCEDIMIENTOS DE MODIFICAR

GO
CREATE PROC ModificarCuentas
	@IDCuenta int,
	@TipoCuenta varchar (10) = null,
	@NombreCuenta varchar (20) = null,
	@IDUsuario int = null
AS
BEGIN
	IF EXISTS (SELECT 1 FROM CUENTAS WHERE @IDCuenta = IDCuenta)
	BEGIN
		UPDATE CUENTAS
		SET TipoCuenta = isnull (@TipoCuenta,TipoCuenta),
			NombreCuenta = isnull (@NombreCuenta,NombreCuenta),
			IDUsuario = isnull (@IDUsuario,IDUsuario)
			WHERE IDCuenta = @IDCuenta;
		PRINT 'LA CUENTA FUE MODIFICADA CORRECTAMENTE';
	END
	ELSE
	BEGIN
		PRINT 'EL IDCuenta INGRESADO NO EXISTE';
	END
END; 
GO

CREATE PROC ModificarUsuario
	@IDUsuario int,
	@Nombre varchar (40) = null,
	@Apellido varchar (40)= null,
	@DNI INT = null,
	@Correo varchar (100) = null,
	@FechaNacimiento date = null
AS
BEGIN
	IF EXISTS (SELECT 1 FROM USUARIO WHERE @IDUsuario = IDUsuario)
	BEGIN
		UPDATE USUARIO
		SET Nombre = isnull (@Nombre,Nombre),
			Apellido =isnull (@Apellido, apellido),
			DNI = isnull (@DNI,DNI),
			Correo = isnull (@Correo,Correo),
			FechaNacimiento = isnull (@FechaNacimiento,FechaNacimiento)
			WHERE IDUsuario = @IDUsuario;
			PRINT 'EL USUARIO FUE MODIFICADO CON EXITO';
	END;
	ELSE
	BEGIN
		PRINT 'NO SE ENCONTRO UN USUARIO CON ESE ID';
	END
END;
GO

CREATE PROC ModificarAsesor
	@IDAsesor int, 
	@Nombre varchar (40) = null,
	@Apellido varchar (40) = null,
	@DNI int = null,
	@Correo varchar (100) = null,
	@FechaNacimiento date = null,
	@Comision float = null
AS
BEGIN
	IF EXISTS (SELECT 1 FROM  ASESOR WHERE IDAsesor = @IDAsesor)
	BEGIN
		UPDATE ASESOR
		SET Nombre = ISNULL (@Nombre, Nombre),
			Apellido = ISNULL (@Apellido, Apellido),
			DNI = ISNULL (@DNI, DNI),
			Correo = ISNULL (@Correo, Correo),
			FechaNacimiento = ISNULL(@FechaNacimiento, FechaNacimiento),
			Comision = ISNULL (@Comision, Comision)
			where IDAsesor = @IDAsesor;
			PRINT 'SE MODIFICO CORRECTAMENTE AL ASESOR';
	END;
	ELSE
	BEGIN
		PRINT 'NO SE ENCONTRO UN ASESOR CON ESE ID';
	END
END;
GO

CREATE PROC ModificarTarjeta
	@IDTarjeta int,
	@IDCuenta int = null,
	@FechaCierre date = null
AS
BEGIN
	IF EXISTS (SELECT 1 FROM FECHA_TARJETA WHERE IDTarjeta = @IDTarjeta)
	BEGIN
		UPDATE FECHA_TARJETA
		SET IDCuenta = ISNULL (@IDCuenta, IDCuenta),
			FechaCierre = ISNULL (@FechaCierre, FechaCierre)
			WHERE IDTarjeta = @IDTarjeta;
			PRINT 'SE MODIFICO CORRECTAMENTE';
	END
	ELSE
	BEGIN
		PRINT 'NO SE ENCONTRO UNA TARJETA CON ESE ID';
	END
END;
GO

CREATE PROC ModificarCategoria
	@IDCategoria int,
	@NombreCategoria varchar (40) = null
AS
BEGIN
	IF EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCategoria = @IDCategoria)
	BEGIN
		UPDATE CATEGORIA
		SET NombreCategoria = ISNULL(@NombreCategoria,NombreCategoria)
		WHERE IDCategoria = @IDCategoria;
		PRINT 'SE MODIFICO CORRECTAMENTE EL NOMBRE DE LA CATEGORIA';
	END
	ELSE
	BEGIN
		PRINT 'NO SE ENCONTRO UNA CATEGORIA CON ESE ID';
	END
END;
GO

CREATE PROC ModificarInversion
	@IDInversion int,
	@IDCuenta int = null,
	@TipoActivo varchar (30) = null,
	@Nombre varchar (40) = null,
	@Cantidad int = null,
	@PrecioCompra float = null,
	@PrecioActual float = null
AS
BEGIN
	IF EXISTS (SELECT 1 FROM INVERSION WHERE IDInversion = @IDInversion)
	BEGIN
		UPDATE INVERSION
		SET IDCuenta = ISNULL (@IDCuenta, IDCuenta),
			TipoActivo = ISNULL (@TipoActivo, TipoActivo),
			Nombre = ISNULL (@Nombre, Nombre),
			Cantidad = ISNULL (@Cantidad, Cantidad),
			PrecioCompra = ISNULL (@PrecioCompra, PrecioCompra),
			PrecioActual = ISNULL (@PrecioActual, PrecioActual)
			WHERE IDInversion = @IDInversion;
			PRINT 'SE ACTUALIZO CORRECTAMENTE LA TABLA INVERSION';
	END
	ELSE
	BEGIN
		PRINT 'NO SE ENCONTRO UNA INVERSION CON ESE ID';
	END
END;
GO

CREATE PROC ModificarMovimiento
	@IDMovimiento int,
	@IDCuenta int = null,
	@IDCategoria int = null, 
	@TipoMovimiento varchar (25) = null,
	@Importe float = null,
	@Fecha date = null
AS
BEGIN 
	IF EXISTS (SELECT 1 FROM MOVIMIENTOS WHERE @IDMovimiento = IDMovimiento)
	BEGIN
		UPDATE MOVIMIENTOS
		SET IDCuenta = ISNULL(@IDCuenta, IDCuenta),
			IDCategoria = ISNULL (@IDCategoria, IDCategoria),
			TipoMovimiento = ISNULL(@TipoMovimiento, TipoMovimiento),
			Importe = ISNULL(@Importe, importe),
			Fecha = ISNULL (@Fecha, Fecha)
			WHERE IDMovimiento = @IDMovimiento;
			PRINT 'SE MODIFICO CORRECTAMENTE LA TABLA MOVIMIENTOS';
	END
	ELSE
	BEGIN
		PRINT 'NO SE ENCONTRO EL ID EN LA TABLA MOVIMIENTOS';
	END
END;

--ELIMINAR
GO

-- PROCEDIMIENTO DE ELIMINAR

CREATE PROC EliminarCuenta
	@IDCuenta INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM CUENTAS WHERE @IDCuenta = IDCuenta)
	BEGIN
		DELETE FROM CUENTAS WHERE IDCuenta = @IDCuenta;
		PRINT 'CUENTA ELIMINADA CORRECTAMENTE';
	END
	ELSE
	BEGIN
		PRINT 'LA CUENTA NO EXISTE';
	END
END;
GO

CREATE PROC EliminarAsesor
	@IDAsesor INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM ASESOR WHERE IDAsesor = @IDAsesor)
	BEGIN
		DELETE FROM ASESOR WHERE IDAsesor = @IDAsesor;
		PRINT 'ASESOR ELIMINADO CORRECTAMENTE';
	END
	ELSE
	BEGIN
		PRINT 'EL ASESOR NO EXISTE';
	END
END;
GO

CREATE PROC EliminarCategoria
	@IDCategoria int
AS
BEGIN
	IF EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCategoria = @IDCategoria)
	BEGIN
		DELETE FROM CATEGORIA WHERE IDCategoria = @IDCategoria;
		PRINT 'CATEGORIA ELIMINADA';
	END
	ELSE
	BEGIN
		PRINT 'NO EXISTE CATEGORIA CON ESE ID';
	END
END;
GO

CREATE PROC EliminarUsuario
	@IDUsuario INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM USUARIO WHERE IDUsuario = @IDUsuario)
	BEGIN
		DELETE FROM USUARIO WHERE IDUsuario = @IDUsuario;
		PRINT 'USUARIO ELIMINADO';
	END
	ELSE
	BEGIN
		PRINT 'NO EXISTE UN USUARIO CON ESE ID';
	END
END;
GO

CREATE PROC EliminarFechaTarjeta
	@IDTarjeta int
AS
BEGIN
	IF EXISTS (SELECT 1 FROM FECHA_TARJETA WHERE IDTarjeta = @IDTarjeta)
	BEGIN
		DELETE FROM FECHA_TARJETA WHERE IDTarjeta = @IDTarjeta;
		PRINT 'TARJETA ELIMINADA';
	END
	ELSE
	BEGIN
		PRINT 'NO SE ENCONTRO EL ID DE TARJETA INGRESADO';
	END
END;
GO

CREATE PROC EliminarInversion
	@IDInversion INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM INVERSION WHERE IDInversion = @IDInversion)
	BEGIN
		DELETE FROM INVERSION WHERE IDInversion = @IDInversion;
		PRINT 'SE ELIMINO LA INVERSION';
	END
	ELSE
	BEGIN
		PRINT 'NO SE ENCONTRO INVERSION CON ESE ID';
	END
END;
GO

CREATE PROC EliminarMovimiento
	@IDMovimiento int
AS
BEGIN
	IF EXISTS (SELECT 1 FROM MOVIMIENTOS WHERE IDMovimiento = @IDMovimiento)
	BEGIN
		DELETE FROM MOVIMIENTOS WHERE IDMovimiento = @IDMovimiento;
		PRINT 'SE ELIMINO EL MOVIMIENTO';
	END
	ELSE
		BEGIN
		PRINT 'NO SE ENCONTRO MOVIMIENTO CON ESE ID';
	END
END;

--LECTURA
GO

--PROCEDIMIENTO DE LEER

CREATE PROC LeerCuenta
	@IDCuenta INT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM CUENTAS WHERE IDCuenta = @IDCuenta)
	BEGIN
		SELECT * FROM CUENTAS WHERE IDCuenta = @IDCuenta;
	END
	ELSE
	BEGIN
		PRINT 'NO EXISTE CUENTA CON ESE ID';
	END
END;
GO

CREATE PROC LeerAsesor
	@IDAsesor int
AS
BEGIN
	IF EXISTS (SELECT 1 FROM ASESOR WHERE IDAsesor = @IDAsesor)
	BEGIN
		SELECT * FROM ASESOR WHERE IDAsesor = @IDAsesor;
	END
	ELSE
	BEGIN
		PRINT 'NO EXISTE ASESOR CON ESE ID';
	END
END;
GO

CREATE PROC LeerCategoria
	@IDCategoria int
AS
BEGIN
	IF EXISTS (SELECT 1 FROM CATEGORIA WHERE IDCategoria = @IDCategoria)
	BEGIN
		SELECT * FROM CATEGORIA WHERE IDCategoria = @IDCategoria;
	END
	ELSE
	BEGIN
		PRINT 'NO EXISTE CATEGORIA CON ESE ID';
	END
END;
GO

CREATE PROC LeerUsuario
	@IDUsuario int
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM USUARIO WHERE IDUsuario = @IDUsuario)
	BEGIN
		SELECT * FROM USUARIO WHERE IDUsuario = @IDUsuario;
	END
	ELSE
	BEGIN
		PRINT ' NO SE ENCONTRO USUARIO CON ESE ID';
	END
END;
GO

CREATE PROC LeerMovimiento
	@IDMovimiento int
AS
BEGIN
	IF EXISTS (SELECT 1 FROM MOVIMIENTOS WHERE IDMovimiento = @IDMovimiento)
	BEGIN
		SELECT *FROM MOVIMIENTOS WHERE IDMovimiento = @IDMovimiento;
	END
	ELSE
	BEGIN
		PRINT ' NO EXISTE MOVIMIENTO CON ESE ID';
	END
END;
GO

CREATE PROC LeerFechaTarjeta
	@IDTarjeta int
AS
BEGIN
	IF EXISTS (SELECT 1 FROM FECHA_TARJETA WHERE IDTarjeta = @IDTarjeta)
	BEGIN
		SELECT * FROM FECHA_TARJETA WHERE IDTarjeta = @IDTarjeta;
	END
	ELSE
	BEGIN
		PRINT 'NO EXISTE TARJETA CON ESE ID';
	END
END;
GO

CREATE PROC LeerInversion
	@IDInversion int 
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM INVERSION WHERE IDInversion = @IDInversion)
	BEGIN
		SELECT * FROM INVERSION WHERE IDInversion = @IDInversion;
	END
	ELSE
	BEGIN
		PRINT ' NO EXISTE INVERSION CON ESE ID';
	END
END;
GO

CREATE PROC LeerUsuarioAsesor
	@IDusario int =NULL,
	@IDAsesor int = NULL
AS
BEGIN
	IF EXISTS (SELECT 1 FROM ASESOR_USUARIO WHERE IDUsuario = @IDusario OR IDAsesor = @IDAsesor)
	BEGIN
		SELECT * FROM ASESOR_USUARIO WHERE IDUsuario = @IDusario OR IDAsesor = @IDAsesor;
	END
	ELSE
	BEGIN
		PRINT 'NO SE ENCONTRO NINGUN ASESOR O USUARIO CON ESE ID';
	END
END;

--Ver procedimientos creados --

SELECT name 
FROM sys.objects 
WHERE type = 'P';

-- TRIGGERS 

--Trigger para evitar saldos negativos
GO

--VIEWS
GO
CREATE VIEW GastoCategoria
AS
SELECT 
    USUARIO.IDUsuario,
    USUARIO.Nombre + ' ' + USUARIO.Apellido AS Usuario,
    CATEGORIA.NombreCategoria,
    SUM(MOVIMIENTOS.Importe) AS TotalGastado
FROM MOVIMIENTOS
    JOIN CATEGORIA ON MOVIMIENTOS.IDCategoria = CATEGORIA.IDCategoria
    JOIN CUENTAS ON MOVIMIENTOS.IDCuenta = CUENTAS.IDCuenta
    JOIN USUARIO ON CUENTAS.IDUsuario = USUARIO.IDUsuario
WHERE MOVIMIENTOS.TipoMovimiento = 'Egreso'
GROUP BY 
    USUARIO.IDUsuario, 
    USUARIO.Nombre, 
    USUARIO.Apellido, 
    CATEGORIA.NombreCategoria;
GO
--TRIGGERS

--Trigger para evitar saldos negativos
CREATE TRIGGER Trig_EvitarSaldoNegativo
ON MOVIMIENTOS
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @IDCuenta INT;
    DECLARE @TipoMovimiento VARCHAR(25);
    DECLARE @Importe FLOAT;
    DECLARE @SaldoActual FLOAT;

    SELECT @IDCuenta = IDCuenta, @TipoMovimiento = TipoMovimiento, @Importe = Importe
    FROM INSERTED;

    -- Calculamos el saldo actual de la cuenta
    SELECT @SaldoActual = ISNULL(SUM(CASE WHEN TipoMovimiento = 'Ingreso' THEN Importe ELSE -Importe END), 0)
    FROM MOVIMIENTOS
    WHERE IDCuenta = @IDCuenta;

    -- Si es un egreso, validamos si el saldo alcanza
    IF @TipoMovimiento = 'Egreso'
    BEGIN
        IF @SaldoActual >= @Importe
        BEGIN
            -- Si hay saldo suficiente, permitimos el egreso
            INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha)
            SELECT IDCuenta, IDCategoria, TipoMovimiento, Importe, GETDATE()
            FROM INSERTED;

            PRINT 'Egreso registrado correctamente.';
        END
        ELSE
        BEGIN
            PRINT 'ERROR: Saldo insuficiente para realizar el egreso.';
        END
    END
    ELSE
    BEGIN
        -- Si es un ingreso, lo permitimos directamente
        INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha)
        SELECT IDCuenta, IDCategoria, TipoMovimiento, Importe, GETDATE()
        FROM INSERTED;

        PRINT 'Ingreso registrado correctamente.';
    END
END;
GO
--Trigger para evitar que las comisiones esten fuera de rango
GO
CREATE TRIGGER TR_ControlComision
ON ASESOR
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED
        WHERE Comision < 0.001 OR Comision > 0.05
    )
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'ERROR: La comisión debe estar entre 0.001 y 0.05. La operación fue cancelada.';
    END
END;
GO
-- FUNCIONES

--Funcion para calcular el patrimonio de un usuario
GO
CREATE FUNCTION dbo.SaldoCuenta (
    @IDCuenta int
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @INGRESOS FLOAT;
    DECLARE @EGRESOS FLOAT;

    SELECT @INGRESOS =SUM(IMPORTE) FROM MOVIMIENTOS WHERE IDCuenta = @IDCuenta AND TipoMovimiento = 'Ingreso';
    SELECT @EGRESOS = SUM(IMPORTE) FROM MOVIMIENTOS WHERE IDCuenta = @IDCuenta AND TipoMovimiento = 'Egreso';
    RETURN ISNULL (@INGRESOS, 0) - ISNULL(@EGRESOS,0);
    END;
GO
--Funcion calcular comision por cada asesor
GO
CREATE FUNCTION dbo.SaldoUsuario (@IDUsuario int)
RETURNS FLOAT
AS
BEGIN
    DECLARE @TotalCuentas FLOAT

    SELECT @TotalCuentas = SUM (CASE WHEN MOVIMIENTOS.TipoMovimiento = 'Ingreso' then MOVIMIENTOS.Importe 
    WHEN MOVIMIENTOS.TipoMovimiento = 'Egreso' then -MOVIMIENTOS.Importe 
    ELSE 0
    END)
    FROM MOVIMIENTOS
    JOIN CUENTAS C ON MOVIMIENTOS.IDCuenta = C.IDCuenta
    WHERE C.IDUsuario = @IDUsuario;

    RETURN ISNULL (@TotalCuentas,0);
    end;
GO
--Funcion para consultar mejores tenencia 
GO
CREATE FUNCTION dbo.MejoresTenencias(@IDUsuario int)
RETURNS TABLE
	AS
	RETURN (
	SELECT INVERSION.Nombre, (INVERSION.PrecioActual - INVERSION.PrecioCompra) AS TENENCIA FROM INVERSION
	JOIN CUENTAS ON INVERSION.IDCuenta = CUENTAS.IDCuenta
	WHERE CUENTAS.IDUsuario = @IDUsuario);;
GO
--Funcion totales por mes por ingreso
GO
CREATE FUNCTION TotalesPorMesPorUsuario (
    @IDUsuario INT
)
RETURNS TABLE
AS
RETURN (
SELECT 
YEAR(MOVIMIENTOS.Fecha) AS Año,
MONTH(MOVIMIENTOS.Fecha) AS Mes,
SUM(CASE WHEN MOVIMIENTOS.TipoMovimiento = 'Ingreso' THEN MOVIMIENTOS.Importe ELSE 0 END) AS TotalIngresos,
SUM(CASE WHEN MOVIMIENTOS.TipoMovimiento = 'Egreso' THEN MOVIMIENTOS.Importe ELSE 0 END) AS TotalEgresos
FROM MOVIMIENTOS
JOIN CUENTAS ON MOVIMIENTOS.IDCuenta = CUENTAS.IDCuenta
WHERE CUENTAS.IDUsuario = @IDUsuario
GROUP BY YEAR(MOVIMIENTOS.Fecha), MONTH(MOVIMIENTOS.Fecha)
);
GO
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

EXEC AgregarInversion 3, 'Accion', '12AB', 15, 500;
EXEC AgregarInversion 6, 'Plazo Fijo', '34CD', 10, 1000;
EXEC AgregarInversion 9, 'Fondo Comun de Inversion', '56EF', 20, 750;
EXEC AgregarInversion 12, 'CEDEAR', '78GH', 8, 1200;
EXEC AgregarInversion 15, 'Bono', '90IJ', 12, 600;
EXEC AgregarInversion 18, 'Criptomoneda', '11KL', 5, 3000;
EXEC AgregarInversion 3, 'Accion', '12AB', 15, 400;

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
-- Consultas
--Monto a pagar por mes de tarjeta
GO
DECLARE @IDUsuario INT = 2;    -- Usuario seleccionado
DECLARE @Año INT = 2025;       -- Año seleccionado
DECLARE @Mes INT = 7;          -- Mes seleccionado

SELECT 
    F.IDTarjeta,
    F.IDCuenta,
    F.FechaCierre,
    ISNULL((
        SELECT MAX(F2.FechaCierre)
        FROM FECHA_TARJETA F2
        WHERE F2.IDCuenta = F.IDCuenta
          AND F2.FechaCierre < F.FechaCierre
    ), '1900-01-01') AS CierreAnterior,
    SUM(M.Importe) AS MontoAPagar
FROM FECHA_TARJETA F
    JOIN CUENTAS C ON F.IDCuenta = C.IDCuenta
    JOIN MOVIMIENTOS M ON F.IDCuenta = M.IDCuenta
WHERE 
    C.IDUsuario = @IDUsuario
    AND C.TipoCuenta = 'Credito'
    AND YEAR(F.FechaCierre) = @Año
    AND MONTH(F.FechaCierre) = @Mes
    AND M.TipoMovimiento = 'Egreso'
    AND M.Fecha > ISNULL((
        SELECT MAX(F2.FechaCierre)
        FROM FECHA_TARJETA F2
        WHERE F2.IDCuenta = F.IDCuenta
          AND F2.FechaCierre < F.FechaCierre
    ), '1900-01-01')
    AND M.Fecha <= F.FechaCierre
GROUP BY 
    F.IDTarjeta,
    F.IDCuenta,
    F.FechaCierre
ORDER BY 
    F.FechaCierre, F.IDTarjeta;
GO
-- Ingresos mensuales
GO
DECLARE @IDUsuario INT = 2;    -- Usuario seleccionado
DECLARE @Año INT = 2025;       -- Año seleccionado
DECLARE @Mes INT = 6;          -- Mes seleccionado

SELECT 
    U.IDUsuario,
    U.Nombre + ' ' + U.Apellido AS Usuario,
    YEAR(M.Fecha) AS Año,
    MONTH(M.Fecha) AS Mes,
    SUM(M.Importe) AS TotalIngresos
FROM MOVIMIENTOS M
    JOIN CUENTAS C ON M.IDCuenta = C.IDCuenta
    JOIN USUARIO U ON C.IDUsuario = U.IDUsuario
WHERE 
    M.TipoMovimiento = 'Ingreso'
    AND U.IDUsuario = @IDUsuario
    AND YEAR(M.Fecha) = @Año
    AND MONTH(M.Fecha) = @Mes
GROUP BY 
    U.IDUsuario,
    U.Nombre,
    U.Apellido,
    YEAR(M.Fecha),
    MONTH(M.Fecha)
ORDER BY 
    Año, Mes;

GO
-- Excedentes mensuales
GO
DECLARE @IDUsuario INT = 4;    -- Usuario seleccionado
DECLARE @Año INT = 2025;       -- Año seleccionado

SELECT 
    U.IDUsuario,
    U.Nombre + ' ' + U.Apellido AS Usuario,
    YEAR(M.Fecha) AS Año,
    MONTH(M.Fecha) AS Mes,
    SUM(CASE WHEN M.TipoMovimiento = 'Ingreso' THEN M.Importe ELSE 0 END) AS TotalIngresos,
    SUM(CASE WHEN M.TipoMovimiento = 'Egreso' THEN M.Importe ELSE 0 END) AS TotalEgresos,
    SUM(CASE WHEN M.TipoMovimiento = 'Ingreso' THEN M.Importe ELSE -M.Importe END) AS Excedente
FROM MOVIMIENTOS M
    JOIN CUENTAS C ON M.IDCuenta = C.IDCuenta
    JOIN USUARIO U ON C.IDUsuario = U.IDUsuario
WHERE 
    U.IDUsuario = @IDUsuario
    AND YEAR(M.Fecha) = @Año
GROUP BY 
    U.IDUsuario,
    U.Nombre,
    U.Apellido,
    YEAR(M.Fecha),
    MONTH(M.Fecha)
ORDER BY 
    Año, Mes;

GO
-- Tenencia acitvos
GO
DECLARE @IDUsuario INT = 6	-- Usuario seleccionado
SELECT 
  TipoActivo,
  SUM(Cantidad * PrecioActual) AS ValorActualTotal
FROM INVERSION
WHERE IDcuenta IN (SELECT IDcuenta FROM cuentas WHERE IDusuario = @IDUsuario)
GROUP BY TipoActivo;
  
GO
--- Cuentas con mayor número de movimientos
GO
SELECT
  c.IDCuenta             AS Cuenta,
  c.NombreCuenta         AS Descripción,
  (
    SELECT COUNT(1)
    FROM MOVIMIENTOS AS m
    WHERE m.IDCuenta = c.IDCuenta
  )                       AS TotalMovs
FROM CUENTAS AS c
ORDER BY TotalMovs DESC;
GO
--Mejores tenencias por usuario (utilizando funcion)
GO
DECLARE @IDUsuario INT = 1
SELECT * FROM dbo.MejoresTenencias(@IDUsuario)
ORDER BY Tenencia DESC;
GO
-- Inversiones activas por tipo de activo
GO
SELECT 
    resumen.Activo AS TipoDeActivo,
    resumen.TotalInversiones AS CantidadInversiones,
    resumen.ValorAcumulado AS ValorActualTotal
FROM (
    SELECT 
        i.TipoActivo AS Activo,
        COUNT(*) AS TotalInversiones,
        SUM(i.Cantidad * i.PrecioActual) AS ValorAcumulado
    FROM INVERSION AS i
    WHERE i.PrecioActual > 0
    GROUP BY i.TipoActivo
) AS resumen
ORDER BY resumen.TotalInversiones DESC;
GO
--Porcentaje de ganancias por usuario
GO
DECLARE @IDUsuario INT = 1
SELECT 
    I.IDInversion,
    C.NombreCuenta,
    I.TipoActivo,
    I.Nombre AS NombreActivo,
    I.Cantidad,
   CONCAT('$', I.PrecioCompra) AS PrecioCompra,
    CONCAT('$',I.PrecioActual) AS PrecioActual,
    CONCAT('$',(i.Cantidad * i.PrecioCompra)) AS TotalInvertido,
    CONCAT('$',(I.PrecioActual - I.PrecioCompra) * I.Cantidad) AS Ganancia_Perdida_Pesos,
     CONCAT(ROUND(((I.PrecioActual - I.PrecioCompra) / I.PrecioCompra) * 100, 2),'%') AS Porcentaje_Ganancia_Perdida
FROM INVERSION I
JOIN CUENTAS C ON I.IDCuenta = C.IDCuenta
WHERE C.IDUsuario = @IDUsuario;
GO
--Lista de clientes del asesor
GO
DECLARE @IDUsuario INT = 1
SELECT 
    U.IDUsuario,
    U.Nombre + ' ' + U.Apellido AS Usuario,
    ROUND(SUM((I.PrecioActual - I.PrecioCompra) * I.Cantidad * A.Comision), 1) AS GananciaAsesor
FROM ASESOR_USUARIO AU
JOIN USUARIO U ON AU.IDUsuario = U.IDUsuario
JOIN ASESOR A ON AU.IDAsesor = A.IDAsesor
JOIN CUENTAS C ON U.IDUsuario = C.IDUsuario
JOIN INVERSION I ON I.IDCuenta = C.IDCuenta
WHERE AU.IDAsesor = @IDUsuario
GROUP BY U.IDUsuario, U.Nombre, U.Apellido;
GO
--Lista de Usuarios por cuenta
GO
SELECT 
    U.IDUsuario,
    U.Nombre + ' ' + U.Apellido AS NombreCompleto,
    U.Correo,
    C.IDCuenta,
    C.NombreCuenta,
    C.TipoCuenta,
    dbo.SaldoCuenta(C.IDCuenta) AS Saldo
FROM CUENTAS C
JOIN USUARIO U ON C.IDUsuario = U.IDUsuario;
GO
--Lista totales por mes por usuario
GO
DECLARE @IDUsuario INT = 1
SELECT * FROM TotalesPorMesPorUsuario(@IDUsuario)
ORDER BY Año, Mes;
GO
--Lista inversion mensual por año
GO
SELECT
  CONCAT(YEAR(ft.FechaCierre), '/', RIGHT('0' + CAST(MONTH(ft.FechaCierre) AS VARCHAR), 2)) AS Periodo,
  SUM(i.Cantidad * i.PrecioCompra)AS TotalInvertido
FROM INVERSION AS i
JOIN FECHA_TARJETA AS ft
  ON i.IDCuenta = ft.IDCuenta
GROUP BY
  YEAR(ft.FechaCierre),
  MONTH(ft.FechaCierre)
ORDER BY
  YEAR(ft.FechaCierre),
  MONTH(ft.FechaCierre);
GO