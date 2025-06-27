
-- FUNCIONES

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


CREATE FUNCTION SaldoCuenta (
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


CREATE FUNCTION SaldoUsuario (
@IDUsuario int
)
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