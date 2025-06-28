-- Consultas
-- 1 - Monto a pagar por mes de tarjeta
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

-- 2 - Ingresos mensuales
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

-- 3 - Excedentes mensuales
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


-- 4 - Tenencia acitvos
GO
DECLARE @IDUsuario INT = 1	-- Usuario seleccionado
SELECT 
  TipoActivo,
  SUM(Cantidad * PrecioActual) AS ValorActualTotal
FROM INVERSION
WHERE IDcuenta IN (SELECT IDcuenta FROM cuentas WHERE IDusuario = @IDUsuario)
GROUP BY TipoActivo;
  
GO


-- 5 - Cuentas con mayor número de movimientos
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


-- 6 - Variacion de precio de inversiones por usuario (utilizando funcion)
GO
DECLARE @IDUsuario INT = 1
SELECT * FROM dbo.VariacionPrecioInv(@IDUsuario)
ORDER BY Tenencia DESC;
GO


-- 7 - Inversiones activas por tipo de activo
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


-- 8 - Porcentaje de ganancias por usuario
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


-- 9 - Lista de clientes del asesor
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



-- 10 - Lista de Usuarios por cuenta
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


-- 11 - Lista totales por mes por usuario
GO
DECLARE @IDUsuario INT = 1
SELECT * FROM TotalesPorMesPorUsuario(@IDUsuario)
ORDER BY Año, Mes;
GO


-- 12 - Lista inversion mensual por año
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