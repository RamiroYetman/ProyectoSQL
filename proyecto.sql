CREATE DATABASE FinanzasPersonales;

--Comienzo Tablas
CREATE TABLE CUENTAS 
(IDCuenta int identity (1,1) constraint PK_CUENTAS primary key,
TipoCuenta varchar (10) not null,
NombreCuenta varchar (20) not null,
IDUsuario int,
FOREIGN KEY (IDUsuario) references USUARIO(IDUsuario),
CHECK (TipoCuenta like '%[a-zA-Z]%'),
CHECK (NombreCuenta like '%[a-zA-Z]%'));

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

CREATE TABLE CATEGORIA(
IDCategoria int identity (1,1) constraint PK_Categoria primary key,
NombreCategoria varchar (40) not null);

CREATE TABLE ASESOR (
IDAsesor int identity (1,1) constraint PK_Asesor primary key,
Nombre varchar (40) not null CHECK (Nombre like '%[a-zA-Z]%'),
Apellido varchar (40) not null CHECK (Apellido like '%[a-zA-Z]%'),
DNI INT not null,
Correo varchar(100) not null,
FechaNacimiento date not null,
Comision DECIMAL(5,4) NOT NULL CHECK (Comision >= 0.001 AND Comision <= 0.05),
constraint CorreoAsesorCheck CHECK (Correo LIKE '_%@_%.com%'));

CREATE TABLE ASESOR_USUARIO (
IDUsuario int not null,
IDAsesor int not null,
FOREIGN KEY (IDAsesor) REFERENCES ASESOR(IDAsesor),
FOREIGN KEY (IDUsuario) REFERENCES USUARIO(IDUsuario),
CONSTRAINT PK_AsesorUsuario PRIMARY KEY (IDUsuario, IDAsesor));

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
    SELECT @SaldoDisponible = dbo.fn_SaldoDisponible(@IDCuenta);

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


CREATE PROC VenderInversion
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

    SELECT @IDUsuario = IDUsuario FROM CUENTAS WHERE IDCuenta = @IDCuenta;

    SELECT TOP 1 @Comision = A.Comision
    FROM ASESOR A
    INNER JOIN ASESOR_USUARIO AU ON A.IDAsesor = AU.IDAsesor
    WHERE AU.IDUsuario = @IDUsuario;

    SET @PrecioVentaFinal = @PrecioVenta * (1 - ISNULL(@Comision, 0));

    INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha)
    VALUES (@IDCuenta, (SELECT IDCategoria FROM CATEGORIA WHERE NombreCategoria = 'Inversion'), 'Ingreso', @PrecioVentaFinal * @CantidadVendida, GETDATE());

    SELECT @CantidadActual = Cantidad FROM INVERSION WHERE IDCuenta = @IDCuenta AND Nombre = @Nombre;

    IF @CantidadActual IS NULL
    BEGIN
        PRINT 'Error: La inversión no existe para esta cuenta.';
        RETURN;
    END

    IF @CantidadVendida > @CantidadActual
    BEGIN
        PRINT 'Error: No se pueden vender más activos de los que se tienen.';
        RETURN;
    END

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

-- TRIGGERS 

--Trigger para evitar saldos negativos
GO
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
CREATE FUNCTION fn_SaldoDisponiblePorNombre (
    @Nombre VARCHAR(40) = NULL,
    @Apellido VARCHAR(40) = NULL
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @Saldo FLOAT;

    SELECT @Saldo = ISNULL(SUM(CASE WHEN M.TipoMovimiento = 'Ingreso' THEN M.Importe ELSE -M.Importe END), 0)
    FROM MOVIMIENTOS M
    INNER JOIN CUENTAS C ON M.IDCuenta = C.IDCuenta
    INNER JOIN USUARIO U ON C.IDUsuario = U.IDUsuario
    WHERE (@Nombre IS NULL OR U.Nombre = @Nombre)
      AND (@Apellido IS NULL OR U.Apellido = @Apellido);

    RETURN @Saldo;
END;
GO



--Funcion calcular comision por cada asesor
CREATE FUNCTION fn_ComisionAsesorPorFecha (
    @Nombre VARCHAR(40) = NULL,
    @Apellido VARCHAR(40) = NULL,
    @FechaDesde DATE,
    @FechaHasta DATE
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @ComisionTotal FLOAT = 0;

    -- Calcular la comisión total del asesor en el rango de fechas
    SELECT @ComisionTotal = SUM(M.Importe * A.Comision)
    FROM ASESOR A
    INNER JOIN ASESOR_USUARIO AU ON A.IDAsesor = AU.IDAsesor
    INNER JOIN CUENTAS C ON AU.IDUsuario = C.IDUsuario
    INNER JOIN MOVIMIENTOS M ON C.IDCuenta = M.IDCuenta
    INNER JOIN CATEGORIA CAT ON M.IDCategoria = CAT.IDCategoria
    WHERE A.Nombre = @Nombre
      AND A.Apellido = @Apellido
      AND M.TipoMovimiento IN ('Ingreso', 'Egreso')
      AND CAT.NombreCategoria = 'Inversion'
      AND M.Fecha BETWEEN @FechaDesde AND @FechaHasta;

    RETURN ISNULL(@ComisionTotal, 0);
END;
GO
