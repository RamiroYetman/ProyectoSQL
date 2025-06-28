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
CREATE FUNCTION dbo.VariacionPrecioInv(@IDUsuario int)
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