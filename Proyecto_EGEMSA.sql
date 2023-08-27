--DROP DATABASE BDEGEMSA;

CREATE DATABASE	BDEGEMSA;

USE  BDEGEMSA;


--DISEÑADOS
CREATE TABLE Feriado (
	FeriadoID		INT PRIMARY KEY IDENTITY(1,1),
	Anio			SMALLINT NOT NULL,
	Fecha			DATE NOT NULL,
	Descripcion		VARCHAR(100) NOT NULL,
	Estado			BIT DEFAULT 1,
	FechaRegistro	DATETIME DEFAULT GETDATE(),
	CONSTRAINT uk_anio_fecha_descripcion UNIQUE (Anio, Fecha, Descripcion)
);


CREATE TABLE CatalogoRol (
	RolID			INT PRIMARY KEY IDENTITY(1,1),
	NombreRol		VARCHAR(30) NOT NULL UNIQUE,
	Estado			BIT DEFAULT 1,
	FechaRegistro	DATETIME DEFAULT GETDATE(),
);

CREATE TABLE PersonaJuridica (
	PersonaJuridicaID	INT PRIMARY KEY IDENTITY(1,1),
	Ruc					CHAR(11) NOT NULL UNIQUE,
	RazonSocial			NVARCHAR(60) NOT NULL,
	Estado				BIT DEFAULT 1,
	FechaRegistro		DATETIME DEFAULT GETDATE(),
);



CREATE TABLE PersonaNatural ( 
	PersonaNaturalID	INT PRIMARY KEY IDENTITY(1,1),
	Nombres				VARCHAR(50) NOT NULL,
	ApellidoPaterno		VARCHAR(50) NOT NULL,
	ApellidoMaterno		VARCHAR(50) NOT NULL,
	NroDocumento		VARCHAR(15) NOT NULL ,
	TipoDocumento		VARCHAR(3) NOT NULL CHECK (TipoDocumento IN ('DNI','CE','OTR')),
	Estado				BIT DEFAULT 1,
	FechaRegistro		DATETIME DEFAULT GETDATE(),
	CONSTRAINT uk_nrodoc_tipodoc UNIQUE (NroDocumento, TipoDocumento)
);



CREATE TABLE CatalogoTipoUsuario (
	TipoUsuarioID		INT PRIMARY KEY IDENTITY(1,1),
	DEscripcion				VARCHAR(50) NOT NULL UNIQUE,
	Estado				BIT DEFAULT 1,
	FechaRegistro		DATETIME DEFAULT GETDATE(),
);

CREATE TABLE CatalogoEstado (
	EstadoID		INT PRIMARY KEY IDENTITY(1,1),
	Descripcion		VARCHAR(20) NOT NULL UNIQUE,
	Estado			BIT DEFAULT 1,
	FechaRegistro	DATETIME DEFAULT GETDATE(),

);


CREATE TABLE CatalogoTipoDocumento (
	TipoDocumentoID		INT PRIMARY KEY IDENTITY(1,1),
	Descripcion			VARCHAR(30) NOT NULL UNIQUE,
	Estado				BIT DEFAULT 1,
	FechaRegistro		DATETIME DEFAULT GETDATE(),
);

CREATE TABLE Plazo (
	PlazoID				INT PRIMARY KEY IDENTITY(1,1),
	DiasPlazoMaximo		SMALLINT NOT NULL,
	DiasProrroga		SMALLINT NOT NULL,
	Estado				BIT DEFAULT 1,
	FechaRegistro		DATETIME DEFAULT GETDATE(),
);

CREATE TABLE CatalogoFormaEntrega ( --AGREGAR si GEENERA COSTO
	FormaEntregaID		INT PRIMARY KEY IDENTITY(1,1),
	Descripcion			VARCHAR(50) NOT NULL UNIQUE,
	GeneraCosto			BIT DEFAULT 0,
	Estado				BIT DEFAULT 1,
	FechaRegistro		DATETIME DEFAULT GETDATE(),
);



--------TABLAS DEPENDIENTES

CREATE TABLE Usuario (
	UsuarioID			INT PRIMARY KEY IDENTITY(1,1),
	Usuario			VARCHAR(30) NOT NULL UNIQUE,
	Pass			NVARCHAR(200) NOT NULL UNIQUE,
	Correo			NVARCHAR(50) NOT NULL UNIQUE,
	PersonaID		INT REFERENCES PersonaNatural(PersonaNaturalID),
	Estado			BIT DEFAULT 1,
	FechaRegistro	DATETIME DEFAULT GETDATE(),
);

CREATE TABLE Tarea (--definir si l ohace el sistema o la persona
	TareaID			INT PRIMARY KEY IDENTITY(1,1),
	Descripcion		VARCHAR(100) NOT NULL , 
	EstadoID		INT REFERENCES CatalogoEstado(EstadoID),
	Estado			BIT DEFAULT 1,
	FechaRegistro	DATETIME DEFAULT GETDATE(),
);


CREATE TABLE Area (
	AreaID			INT PRIMARY KEY IDENTITY(1,1),
	TipoUsuarioID	INT NOT NULL REFERENCES CatalogoTipoUsuario(TipoUsuarioID),
	Nombre			VARCHAR(50) NOT NULL,
	Estado			BIT DEFAULT 1,
	FechaRegistro	DATETIME DEFAULT GETDATE(),
	CONSTRAINT uk_tipousuario_nombre UNIQUE (TipoUsuarioID, Nombre),
);


CREATE TABLE Responsable (
	ResponsableID		INT PRIMARY KEY IDENTITY(1,1),
	PersonaNaturalID	INT NOT NULL REFERENCES PersonaNatural(PersonaNaturalID),
	AreaID				INT NOT NULL REFERENCES Area(AreaID),
	Correo				NVARCHAR(50) NOT NULL,
	Estado				BIT DEFAULT 1,
	FechaRegistro		DATETIME DEFAULT GETDATE(),
	CONSTRAINT uk_personaid_areaid_correo UNIQUE (PersonaNaturalID, AreaID, Correo),
);


CREATE TABLE UsuarioRol (
	UsuarioRolID	INT PRIMARY KEY IDENTITY(1,1),
	RolID			INT NOT NULL REFERENCES CatalogoRol(RolID),
	UsuarioID		INT NOT NULL REFERENCES Usuario(UsuarioID),
	Estado			BIT DEFAULT 1,
	FechaRegistro	DATETIME DEFAULT GETDATE(),
);



CREATE TABLE Solicitud (
	SolicitudID					INT PRIMARY KEY IDENTITY(1,1),
	PersonaJuridicaID			INT NULL REFERENCES PersonaJuridica(PersonaJuridicaID),
	PersonaNaturalID			INT NULL REFERENCES PersonaNatural(PersonaNaturalID),
	FraiID						INT NOT NULL REFERENCES Responsable(ResponsableID),
	MpvID						INT NULL REFERENCES Responsable(ResponsableID),
	ResponsableClasificacionID	INT NULL REFERENCES Responsable(ResponsableID),
	Correo						NVARCHAR(50) NOT NULL,
	Telefono					VARCHAR(12) NULL,
	InformacionSolicitada		NVARCHAR(MAX) NOT NULL,
	FormaEntregaID				INT NOT NULL REFERENCES CatalogoFormaEntrega(FormaEntregaID),
	Direccion					VARCHAR(100) NOT NULL,
	Departamento				VARCHAR(20) NOT NULL,
	Provincia					VARCHAR(20) NOT NULL,
	Distrito					VARCHAR(20) NOT NULL,
	CodigoSigedd				VARCHAR(20) NULL,
	CostoTotal					SMALLMONEY NULL,
	FechaPresentacion			DATETIME DEFAULT GETDATE(),
	FechaVencimiento			DATETIME DEFAULT NULL,
	FechaVencimientoProrroga	DATETIME DEFAULT NULL,
	PlazoMaximo					SMALLINT NOT NULL,
	Prorroga					SMALLINT NOT NULL,
	Observacion					VARCHAR(100) NULL,
	Estado						BIT DEFAULT 1,
	FechaRegistro				DATETIME DEFAULT GETDATE(),
);



CREATE TABLE Bitacora (
	BitacoraID			INT PRIMARY KEY IDENTITY(1,1),
	SolicitudID			INT NOT NULL REFERENCES Solicitud(SolicitudID),
	TareaID				INT NOT NULL REFERENCES Tarea(TareaID),
	FechaHoraAccion		DATETIME NOT NULL,
	Comentario			NVARCHAR(MAX) NULL,
	Observacion			NVARCHAR(MAX) NULL,
	Estado				BIT DEFAULT 1,
	FechaRegistro		DATETIME DEFAULT GETDATE(),
	
);



CREATE TABLE Derivado (
	DerivadoID					INT PRIMARY KEY IDENTITY(1,1),
	ResponsableID				INT NULL REFERENCES Responsable(ResponsableID),
	BitacoraPeticionID			INT NULL REFERENCES Bitacora(BitacoraID),
	BitacoraRespuestaPeticionID	INT NULL REFERENCES Bitacora(BitacoraID),
	Estado						BIT DEFAULT 1,
	FechaRegistro				DATETIME DEFAULT GETDATE(),

);


CREATE TABLE DocumentoAdjunto (
	DocumentoAdjuntoID		INT PRIMARY KEY IDENTITY(1,1),
	BitacoraID				INT NOT NULL REFERENCES Bitacora(BitacoraID),
	TipoDocumentoID			INT NOT NULL REFERENCES CatalogoTipoDocumento(TipoDocumentoID),
	NombreDocumento			VARCHAR(30) NOT NULL,
	Ruta					VARCHAR(200) NOT NULL,
	Estado					BIT DEFAULT 1,
	FechaRegistro			DATETIME DEFAULT GETDATE(),
);




BEGIN TRANSACTION;
BEGIN TRY

	INSERT INTO CatalogoTipoUsuario (
	DEscripcion) VALUES ('Funcionario'),('Responsable'), ('Derivado');

	COMMIT;
END TRY
BEGIN CATCH	
	ROLLBACK;
END CATCH;

--

BEGIN TRANSACTION;
BEGIN TRY

	INSERT INTO Area (TipoUsuarioID, Nombre) VALUES
	(1, 'FRAI'), (2, 'Mesa de partes'), (2, 'Responsable de clasificacion'), (3, 'Area 1'), (3, 'Area 2'), (3, 'Area 3');

	COMMIT;
END TRY
BEGIN CATCH	
	ROLLBACK;
END CATCH;


BEGIN TRANSACTION;
BEGIN TRY

	INSERT INTO CatalogoRol(NombreRol) VALUES
	('Administrado'), ('Responsable solicitud'), ('Gestor de reportes');

	COMMIT;
END TRY
BEGIN CATCH	
	ROLLBACK;
END CATCH;


BEGIN TRANSACTION;
BEGIN TRY

	INSERT INTO PersonaNatural(Nombres, ApellidoPaterno, ApellidoMaterno, NroDocumento, TipoDocumento) VALUES
	('Julio','Gonzales', 'Cueva','45678935','DNI'), ('Andres','Cavero', 'Rodriguez','44678935','DNI'), ('Marta','Bendezu', 'Camasca','45699935','DNI');

	COMMIT;
END TRY
BEGIN CATCH	
	ROLLBACK;
END CATCH;


BEGIN TRANSACTION;
BEGIN TRY

	INSERT INTO Usuario(Usuario, Pass, Correo, PersonaID) VALUES
	('admin','123','test@hotmail.com',1);

	COMMIT;
END TRY
BEGIN CATCH	
	ROLLBACK;
END CATCH;

BEGIN TRANSACTION;
BEGIN TRY

	INSERT INTO UsuarioRol(RolID, UsuarioID) VALUES
	(1,1);

	COMMIT;
END TRY
BEGIN CATCH	
	ROLLBACK;
END CATCH;


---------------
BEGIN TRANSACTION;
BEGIN TRY

	INSERT INTO Responsable(PersonaNaturalID, AreaID,Correo) VALUES
	(1,1,'test@hotmail.com');

	COMMIT;
END TRY
BEGIN CATCH	
	ROLLBACK;
END CATCH;

----------------------
BEGIN TRANSACTION;
BEGIN TRY

	INSERT INTO CatalogoEstado(Descripcion) VALUES
	('Registrado'),('Rechazado'),('En tramite'),('Derivado'),('Atendido'), ('Respondida');

	COMMIT;
END TRY
BEGIN CATCH	
	ROLLBACK;
END CATCH;

-------------------
BEGIN TRANSACTION;
BEGIN TRY

	INSERT INTO Tarea(Descripcion, EstadoID) VALUES
	('Registro por parte del Administrado',1), 
('Revision por parte del FRAI',2),
('Revision por parte del FRAI',3),
('Notificacion a MPV', 3),
('Registro del codigo SIGEDD', 3),
('Derivacion a la clasificacion de la informacion publica', 4),
('Notificacion del codigo SIGEDD al administrado', 2),
('Notificacion del codigo SIGEDD al administrado', 4),
('Resultado de la clasificacion de la informacion publica - Atendida', 5),
('Notificacion del resultado de la clasificacion al administrado', 5),
('Recepcion de la notificacion del resultado de la clasificiacion al administrado', 6),
('Resultado de la clasificacion de la informacion publica - Derivado', 4),
('Consulta individual a los responsables para disponer con la informacion requerida', 4),
('Repuesta individual sobre la disposicion de la informacion requerida', 4),
('Resultado de la consulta por la informacion total requerida', 5),
('Acopio de documentos por areas', 4),
('Solicitar a realizar el pago correspondiente', 4),
('Recepcion voucher', 4),
('Validacion conforme del pago', 4),
('Confirmacion de la recepcion', 6);

	COMMIT;
END TRY
BEGIN CATCH	
	ROLLBACK;
END CATCH;
----------
BEGIN TRANSACTION;
BEGIN TRY

	INSERT INTO CatalogoFormaEntrega(Descripcion,GeneraCosto) VALUES
	('Correo Electronico', 0), ('CD',1),('Copia Simple',1),('Copia Certificada',1);

	COMMIT;
END TRY
BEGIN CATCH	
	ROLLBACK;
END CATCH;


select * from CatalogoFormaEntrega;
select * from Area;



