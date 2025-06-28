-- TRIGGERS 

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