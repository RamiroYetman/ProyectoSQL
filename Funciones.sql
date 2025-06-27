
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
