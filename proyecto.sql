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
constraint CorreoCheck check (Correo like '%@%' and correo like '%.com%'),
CHECK (Nombre like '%[a-zA-Z]%'),
CHECK (Apellido like '%[a-zA-Z]%'));

--FALTA AGREGAR RESTRICCIONES
CREATE TABLE MOVIMIENTOS (
IDMovimiento int identity (1,1) constraint PK_Movimiento primary key,
IDCuenta int not null,
IDCategoria int not null,
TipoMovimiento varchar (25) not null,
Importe float not null,
Fecha date,
FOREIGN KEY (IDCuenta) references CUENTAS(IDCuenta),
FOREIGN KEY (IDCategoria) references CATEGORIA(IDCategoria));

--FALTA AGREGAR RESTRICCIONES
CREATE TABLE INVERSION (
IDInversion int identity (1,1) constraint PK_IDInversion primary key,
IDCuenta int,
TipoActivo varchar (30) not null,
Nombre varchar (40) not null,
Cantidad int not null,
PrecioCompra float not null,
PrecioActual float not null,
foreign key (IDCuenta) references CUENTAS(IDCuenta));

--FALTA AGREGAR RESTRICCIONES
CREATE TABLE CATEGORIA(
IDCategoria int identity (1,1) constraint PK_Categoria primary key,
NombreCategoria varchar (40) not null);

--FALTA AGREGAR RESTRICCIONES
CREATE TABLE ASESOR (
IDAsesor int identity (1,1) constraint PK_Asesor primary key,
Nombre varchar (40) not null,
Apellido varchar (40) not null,
DNI INT not null,
Correo varchar(100) not null,
FechaNacimiento date not null,
Comision float not null,
constraint CorreoAsesorCheck check (Correo like '%@%' and correo like '%.com%'));

--FALTA AGREGAR RESTRICCIONES
CREATE TABLE ASESOR_USUARIO(
IDUsuario int, -- se declara como pk?
IDAsesor int,
foreign key (IDAsesor) references ASESOR(IDAsesor),
foreign key (IDUsuario) references USUARIO(IDUsuario));

CREATE TABLE FECHA_TARJETA (
IDTarjeta int identity (1,1) constraint PK_Tarjeta primary key,
IDCuenta int,
FechaCierre date,
Foreign key (IDCuenta) references CUENTAS(IDCuenta));

