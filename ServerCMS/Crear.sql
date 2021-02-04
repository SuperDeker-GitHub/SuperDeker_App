
USE [DossierAcceso]
GO



/****** Object:  Table [dbo].[DossierCreds]    Script Date: 12/4/2020 9:30:47 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DossierCreds](
	[userid] [nvarchar](50) NOT NULL,
	[pwd] [nvarchar](255) NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[email] [nchar](255) NOT NULL,
	[status] [nvarchar](50) NOT NULL,
	[Notifications] [nvarchar](255) NULL,
	[Incorporado] [datetime] NULL,
	[Perfil] [nvarchar](50) NULL
) ON [PRIMARY]
GO

INSERT INTO [dbo].[DossierCreds]
           ([userid]
           ,[pwd]
           ,[name]
           ,[email]
           ,[status]
           ,[Notifications]
           ,[Incorporado]
           ,[Perfil])
     VALUES
           ('adminsaime'
           ,'$2y$10$sqDpgMMqylWlCbyH6Zvcs.Thi0FSoDFSje9iNSA0cr709NEli5Zpu'
           ,'Visitantes Saime'
           ,'xxx@gmail.com'                                                                                                                                                                                                                                                  
           ,'1'
           ,NULL
           ,'2020-02-17 00:00:00.000'
           ,'administrador')
GO



-- ================================
-- Created 
--    by: dbo
--    on: Tuesday, August 05, 2014 8:51 PM
-- Description: No se permiten multiples updates en grupo, evitamos asi sql injections
-- ================================
CREATE TRIGGER [dbo].[NoMultiUpdateDossierCreds]
   ON  [dbo].[DossierCreds] 
   AFTER UPDATE
AS 
BEGIN
   SET NOCOUNT ON;
   -- Insert statements for trigger here
   IF (SELECT COUNT(*) FROM INSERTED) > 1 
        OR (SELECT COUNT(*) FROM DELETED) > 1
    BEGIN
      ROLLBACK TRAN;
   END;
END
GO

ALTER TABLE [dbo].[DossierCreds] ENABLE TRIGGER [NoMultiUpdateDossierCreds]
GO


/****** Object:  Table [dbo].[grupo]    Script Date: 12/4/2020 9:32:26 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[grupo](
	[id] [bigint] NOT NULL,
	[name] [varchar](50) NOT NULL,
	[icon] [varchar](50) NULL,
	[creado] [date] NULL,
 CONSTRAINT [PK__grupo] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[grupo] ADD  DEFAULT ((0)) FOR [id]
GO



-- ================================
-- Created 
--    by: dbo
--    on: Tuesday, August 05, 2014 8:51 PM
-- Description: No se permiten multiples updates en grupo, evitamos asi sql injections
-- ================================
CREATE TRIGGER [dbo].[NoMultiUpdateGrupo]
   ON  [dbo].[grupo] 
   AFTER UPDATE
AS 
BEGIN
   SET NOCOUNT ON;
   -- Insert statements for trigger here
   IF (SELECT COUNT(*) FROM INSERTED) > 1 
        OR (SELECT COUNT(*) FROM DELETED) > 1
    BEGIN
      ROLLBACK TRAN;
   END;
END
GO

ALTER TABLE [dbo].[grupo] ENABLE TRIGGER [NoMultiUpdateGrupo]
GO




/****** Object:  Table [dbo].[repciDCs]    Script Date: 12/4/2020 9:33:50 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[repciDCs](
	[id] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[repciId] [numeric](18, 0) NULL,
	[comment] [nvarchar](512) NULL,
	[fromUser] [nvarchar](50) NULL,
	[emocion] [numeric](18, 0) NULL,
	[when_date] [datetime] NULL,
	[fileId] [nvarchar](50) NULL,
	[DCType] [varchar](50) NULL,
	[longitud] [varchar](50) NULL,
	[latitud] [varchar](50) NULL,
	[altura] [varchar](50) NULL,
	[accuracy] [varchar](50) NULL,
	[status] [int] NULL,
	[responseobs] [nvarchar](512) NULL,
	[filepath] [nvarchar](100) NULL,
	[PrevDC] [numeric](18, 0) NULL,
	[NextDC] [numeric](18, 0) NULL,
	[IP] [nvarchar](50) NULL,
	[ServerTime] [datetime] NULL,
	[LocationOrigin] [nvarchar](10) NULL,
	[OriginalDC] [numeric](18, 0) NULL,
	[SelloImage] [nvarchar](50) NULL,
 CONSTRAINT [PK__repciDCss] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[repciDCs] ADD  DEFAULT ((0)) FOR [status]
GO


-- ================================
-- Created 
--    by: dbo
--    on: Monday, August 04, 2014 3:31 PM
-- Description: <Description>
-- ================================
CREATE TRIGGER [dbo].[ActRepciDcs] 
   ON  [dbo].[repciDCs] 
   AFTER INSERT
AS 
BEGIN
   SET NOCOUNT ON;
   -- Insert statements for trigger here
UPDATE repcis
   SET q_attached = q_attached + 1,
          mod_date = inserted.when_date
   FROM INSERTED
   WHERE inserted.repciId = repcis.repciId 

END

GO

ALTER TABLE [dbo].[repciDCs] ENABLE TRIGGER [ActRepciDcs]
GO


-- ================================
-- Created 
--    by: dbo
--    on: Tuesday, August 05, 2014 9:19 PM
-- Description: to avoid sql injections no multi updates permited
-- ================================
CREATE TRIGGER [dbo].[NoMultiUpdatesrepciDCs] 
   ON  [dbo].[repciDCs] 
   AFTER UPDATE
AS 
BEGIN
   SET NOCOUNT ON;
   -- Insert statements for trigger here
   IF (SELECT COUNT(*) FROM INSERTED) > 1 
        OR (SELECT COUNT(*) FROM DELETED) > 1
    BEGIN
      ROLLBACK TRAN;
   END;
END
GO

ALTER TABLE [dbo].[repciDCs] ENABLE TRIGGER [NoMultiUpdatesrepciDCs]
GO




/****** Object:  Table [dbo].[repciDCTuplas]    Script Date: 12/4/2020 9:35:23 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[repciDCTuplas](
	[id] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[idDC] [numeric](18, 0) NOT NULL,
	[value1] [varchar](255) NULL,
	[value2] [varchar](1000) NULL,
	[value3] [varchar](255) NULL,
	[value4] [varchar](255) NULL,
	[value5] [varchar](255) NULL,
	[Req] [bit] NULL,
 CONSTRAINT [PK__repciDCTuplass] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


-- ================================
-- Created 
--    by: dbo
--    on: Tuesday, August 05, 2014 9:31 PM
-- Description: No multi updates permited to avoid sqlinjection
-- ================================
CREATE TRIGGER [dbo].[NoMultiUpdates] 
   ON  [dbo].[repciDCTuplas] 
   AFTER UPDATE
AS 
BEGIN
   SET NOCOUNT ON;
   -- Insert statements for trigger here
   IF (SELECT COUNT(*) FROM INSERTED) > 1 
        OR (SELECT COUNT(*) FROM DELETED) > 1
    BEGIN
      ROLLBACK TRAN;
   END;
END
GO

ALTER TABLE [dbo].[repciDCTuplas] ENABLE TRIGGER [NoMultiUpdates]
GO


/****** Object:  Table [dbo].[repciFilePlace]    Script Date: 12/4/2020 9:53:04 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[repciFilePlace](
	[id] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[path] [nvarchar](100) NULL,
	[comment] [nvarchar](100) NULL,
	[bytesize] [bigint] NULL,
 CONSTRAINT [PK__repciFilePlace] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


-- ================================
-- Created 
--    by: dbo
--    on: Tuesday, August 05, 2014 9:43 PM
-- Description: NoMulti updates to avoid sql injections
-- ================================
CREATE TRIGGER [dbo].[NoMultiUpdatesrepciFilePlace] 
   ON  [dbo].[repciFilePlace] 
   AFTER UPDATE
AS 
BEGIN
   SET NOCOUNT ON;
   -- Insert statements for trigger here
   IF (SELECT COUNT(*) FROM INSERTED) > 1 
        OR (SELECT COUNT(*) FROM DELETED) > 1
    BEGIN
      ROLLBACK TRAN;
   END;
END
GO

ALTER TABLE [dbo].[repciFilePlace] ENABLE TRIGGER [NoMultiUpdatesrepciFilePlace]
GO



/****** Object:  Table [dbo].[repciMedia]    Script Date: 12/4/2020 9:55:13 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[repciMedia](
	[id] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[repciId] [numeric](18, 0) NOT NULL,
	[fileId] [numeric](18, 0) NULL,
	[when_date] [date] NULL,
	[longitud] [nvarchar](50) NULL,
	[latitud] [nvarchar](50) NULL,
	[heading] [nvarchar](50) NULL,
	[tilt] [nvarchar](50) NULL,
	[source] [nvarchar](50) NULL,
	[cover] [int] NULL,
	[comment] [nvarchar](100) NULL,
 CONSTRAINT [PK__repciMedia] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



/****** Object:  Table [dbo].[repcis]    Script Date: 12/4/2020 9:56:50 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[repcis](
	[repciId] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
	[titulo] [nvarchar](200) NOT NULL,
	[descrip] [nvarchar](255) NULL,
	[when_date] [datetime] NULL,
	[longitud] [nvarchar](50) NULL,
	[latitud] [nvarchar](50) NULL,
	[accuracy] [nvarchar](50) NULL,
	[altitud] [nvarchar](50) NULL,
	[bearing] [nvarchar](50) NULL,
	[provider] [nvarchar](50) NULL,
	[owner] [nvarchar](50) NULL,
	[creator] [nvarchar](50) NULL,
	[repciType] [nvarchar](50) NULL,
	[ranking] [int] NULL,
	[comments] [nvarchar](50) NULL,
	[status] [varchar](50) NULL,
	[mod_date] [datetime] NULL,
	[q_attached] [int] NULL,
	[NotificationType] [nvarchar](50) NULL,
	[grupo] [bigint] NULL,
	[CuadLong] [bigint] NULL,
	[CuadLat] [bigint] NULL,
	[cuadid] [varchar](50) NULL,
	[Images] [varchar](500) NULL,
	[IP] [varchar](50) NULL,
	[ServerTime] [datetime] NULL,
	[LocationOrigin] [nvarchar](10) NULL,
 CONSTRAINT [PK__repcis] PRIMARY KEY CLUSTERED 
(
	[repciId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[repcis] ADD  DEFAULT ((0)) FOR [grupo]
GO



-- ================================
-- Created 
--    by: dbo
--    on: Tuesday, August 05, 2014 8:38 PM
-- Description: <Description>
-- ================================
CREATE TRIGGER [dbo].[NoMultiUpdate] 
   ON  [dbo].[repcis] 
   AFTER UPDATE
AS 
BEGIN
   SET NOCOUNT ON;
   -- Insert statements for trigger here
   IF (SELECT COUNT(*) FROM INSERTED) > 1 
        OR (SELECT COUNT(*) FROM DELETED) > 1
   BEGIN
      ROLLBACK TRAN;
   END;

END
GO

ALTER TABLE [dbo].[repcis] ENABLE TRIGGER [NoMultiUpdate]
GO



/****** Object:  Table [dbo].[sellos]    Script Date: 12/4/2020 10:07:04 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sellos](
	[grupo] [int] NOT NULL,
	[dctype] [nchar](30) NOT NULL,
	[valor] [int] NOT NULL,
	[src] [nchar](100) NOT NULL
) ON [PRIMARY]
GO


-- ================================
-- Created 
--    by: dbo
--    on: Tuesday, August 05, 2014 8:38 PM
-- Description: <Description>
-- ================================
CREATE TRIGGER [dbo].[NoMultiUpdateSellos] 
   ON  [dbo].[sellos] 
   AFTER UPDATE
AS 
BEGIN
   SET NOCOUNT ON;
   -- Insert statements for trigger here
   IF (SELECT COUNT(*) FROM INSERTED) > 1 
        OR (SELECT COUNT(*) FROM DELETED) > 1
   BEGIN
      ROLLBACK TRAN;
   END;

END
GO

ALTER TABLE [dbo].[sellos] ENABLE TRIGGER [NoMultiUpdateSellos]
GO



/****** Object:  Table [dbo].[usuariosgrupo]    Script Date: 12/4/2020 10:13:09 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TABLE [dbo].[usuariosgrupo](
	[_id] [bigint] IDENTITY(1,1) NOT NULL,
	[grupo] [bigint] NOT NULL,
	[userid] [nvarchar](50) NOT NULL,
	[desde] [date] NULL,
	[perfil] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK__usergroups] PRIMARY KEY CLUSTERED 
(
	[userid] ASC,
	[grupo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



-- ================================
-- Created 
--    by: dbo
--    on: Tuesday, August 05, 2014 8:38 PM
-- Description: <Description>
-- ================================
CREATE TRIGGER [dbo].[NoMultiUpdateUsuariosGrupo] 
   ON  [dbo].[usuariosgrupo] 
   AFTER UPDATE
AS 
BEGIN
   SET NOCOUNT ON;
   -- Insert statements for trigger here
   IF (SELECT COUNT(*) FROM INSERTED) > 1 
        OR (SELECT COUNT(*) FROM DELETED) > 1
   BEGIN
      ROLLBACK TRAN;
   END;

END
GO

ALTER TABLE [dbo].[usuariosgrupo] ENABLE TRIGGER [NoMultiUpdateUsuariosGrupo]
GO

USE [DossierAcceso]
GO

INSERT [dbo].[grupo] ([id], [name], [icon], [creado]) VALUES (150, N'Acceso', N'150.png', CAST(N'2020-02-17' AS Date))
GO
INSERT [dbo].[grupo] ([id], [name], [icon], [creado]) VALUES (160, N'Empleados', N'160.png', CAST(N'2020-02-17' AS Date))
GO
INSERT [dbo].[grupo] ([id], [name], [icon], [creado]) VALUES (170, N'Lista Negra', N'170.png', CAST(N'2020-02-17' AS Date))
GO
INSERT [dbo].[grupo] ([id], [name], [icon], [creado]) VALUES (180, N'Personal Autorizado', N'180.png', CAST(N'2020-02-20' AS Date))
GO
INSERT [dbo].[grupo] ([id], [name], [icon], [creado]) VALUES (185, N'Novedades', N'185.png', CAST(N'2020-02-20' AS Date))
GO
INSERT [dbo].[grupo] ([id], [name], [icon], [creado]) VALUES (190, N'Usuarios Dossier', N'190.png', CAST(N'2020-02-20' AS Date))
GO
SET IDENTITY_INSERT [dbo].[usuariosgrupo] ON 
GO
INSERT [dbo].[usuariosgrupo] ([_id], [grupo], [userid], [desde], [perfil]) VALUES (1, 150, N'adminsaime', CAST(N'2020-02-17' AS Date), N'administrador')
GO
INSERT [dbo].[usuariosgrupo] ([_id], [grupo], [userid], [desde], [perfil]) VALUES (2, 160, N'adminsaime', CAST(N'2020-02-17' AS Date), N'administrador')
GO
INSERT [dbo].[usuariosgrupo] ([_id], [grupo], [userid], [desde], [perfil]) VALUES (3, 170, N'adminsaime', CAST(N'2020-02-17' AS Date), N'administrador')
GO
INSERT [dbo].[usuariosgrupo] ([_id], [grupo], [userid], [desde], [perfil]) VALUES (5, 180, N'adminsaime', CAST(N'2020-02-28' AS Date), N'administrador')
GO
INSERT [dbo].[usuariosgrupo] ([_id], [grupo], [userid], [desde], [perfil]) VALUES (6, 185, N'adminsaime', CAST(N'2020-02-28' AS Date), N'administrador')
GO
INSERT [dbo].[usuariosgrupo] ([_id], [grupo], [userid], [desde], [perfil]) VALUES (8, 190, N'adminsaime', CAST(N'2020-02-28' AS Date), N'administrador')
GO
SET IDENTITY_INSERT [dbo].[usuariosgrupo] OFF
GO


