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