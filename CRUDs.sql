-- ========================================
-- CRUD: CUENTAS
-- ========================================

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


-- ========================================
-- CRUD: USUARIO
-- ========================================

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

-- ========================================
-- CRUD: ASESOR
-- ========================================

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
        WHERE IDAsesor = @IDAsesor;
        PRINT 'SE MODIFICO CORRECTAMENTE AL ASESOR';
    END;
    ELSE
    BEGIN
        PRINT 'NO SE ENCONTRO UN ASESOR CON ESE ID';
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


-- ========================================
-- READ: ASESOR_USUARIO
-- ========================================

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
GO


-- ========================================
-- CRUD: CATEGORIA
-- ========================================

CREATE PROC CrearCategoria
    @NombreCategoria varchar (40)
AS
BEGIN
    INSERT INTO CATEGORIA (NombreCategoria)
    VALUES (@NombreCategoria);
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


-- ========================================
-- CRUD: FECHA_TARJETA
-- ========================================

CREATE PROC CrearFechaTarjeta
    @IDCuenta int,
    @FechaCierre date
AS
BEGIN
    INSERT INTO FECHA_TARJETA (IDCuenta, FechaCierre)
    VALUES (@IDCuenta, @FechaCierre);
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


-- ========================================
-- CRUD: INVERSION
-- ========================================

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

    SELECT @IDUsuario = IDUsuario FROM CUENTAS WHERE IDCuenta = @IDCuenta;

    SELECT TOP 1 @Comision = A.Comision
    FROM ASESOR A
    INNER JOIN ASESOR_USUARIO AU ON A.IDAsesor = AU.IDAsesor
    WHERE AU.IDUsuario = @IDUsuario;

    SET @PrecioCompraFinal = @PrecioCompra * (1 + ISNULL(@Comision, 0));
    SET @TotalCompra = @PrecioCompraFinal * @Cantidad;

    SELECT @SaldoDisponible = dbo.SaldoCuenta(@IDCuenta);

    IF @SaldoDisponible < @TotalCompra
    BEGIN
        PRINT 'ERROR: Saldo insuficiente para realizar la compra.';
        RETURN;
    END

    INSERT INTO INVERSION (IDCuenta, TipoActivo, Nombre, Cantidad, PrecioCompra, PrecioActual)
    VALUES (@IDCuenta, @TipoActivo, @Nombre, @Cantidad, @PrecioCompraFinal, @PrecioCompraFinal);

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

    SELECT @IDUsuario = IDUsuario FROM CUENTAS WHERE IDCuenta = @IDCuenta;

    SELECT TOP 1 @Comision = A.Comision
    FROM ASESOR A
    INNER JOIN ASESOR_USUARIO AU ON A.IDAsesor = AU.IDAsesor
    WHERE AU.IDUsuario = @IDUsuario;

    SELECT @CantidadActual = Cantidad 
    FROM INVERSION 
    WHERE IDCuenta = @IDCuenta AND Nombre = @Nombre;

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

    SET @PrecioVentaFinal = @PrecioVenta * (1 - ISNULL(@Comision, 0));

    INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe, Fecha)
    VALUES (@IDCuenta, (SELECT IDCategoria FROM CATEGORIA WHERE NombreCategoria = 'Inversion'), 'Ingreso', @PrecioVentaFinal * @CantidadVendida, GETDATE());

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


-- ========================================
-- CRUD: MOVIMIENTOS
-- ========================================

CREATE PROC CrearMovimiento
    @IDCuenta int,
    @IDCategoria int,
    @TipoMovimiento varchar (25),
    @Importe Float
AS
BEGIN
    INSERT INTO MOVIMIENTOS (IDCuenta, IDCategoria, TipoMovimiento, Importe)
    VALUES (@IDCuenta, @IDCategoria, @TipoMovimiento, @Importe);
END;
GO

CREATE PROC LeerMovimiento
    @IDMovimiento int
AS
BEGIN
    IF EXISTS (SELECT 1 FROM MOVIMIENTOS WHERE IDMovimiento = @IDMovimiento)
    BEGIN
        SELECT * FROM MOVIMIENTOS WHERE IDMovimiento = @IDMovimiento;
    END
    ELSE
    BEGIN
        PRINT ' NO EXISTE MOVIMIENTO CON ESE ID';
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
GO
