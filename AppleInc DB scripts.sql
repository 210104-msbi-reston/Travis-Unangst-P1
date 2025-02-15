USE [master]
GO
/****** Object:  Database [AppleInc]    Script Date: 2/4/2021 9:37:25 AM ******/
CREATE DATABASE [AppleInc]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'AppleInc', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.NYKSERVER\MSSQL\DATA\AppleInc.mdf' , SIZE = 466944KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'AppleInc_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.NYKSERVER\MSSQL\DATA\AppleInc_log.ldf' , SIZE = 2105344KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [AppleInc] SET COMPATIBILITY_LEVEL = 130
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [AppleInc].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [AppleInc] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [AppleInc] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [AppleInc] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [AppleInc] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [AppleInc] SET ARITHABORT OFF 
GO
ALTER DATABASE [AppleInc] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [AppleInc] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [AppleInc] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [AppleInc] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [AppleInc] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [AppleInc] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [AppleInc] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [AppleInc] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [AppleInc] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [AppleInc] SET  ENABLE_BROKER 
GO
ALTER DATABASE [AppleInc] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [AppleInc] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [AppleInc] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [AppleInc] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [AppleInc] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [AppleInc] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [AppleInc] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [AppleInc] SET RECOVERY FULL 
GO
ALTER DATABASE [AppleInc] SET  MULTI_USER 
GO
ALTER DATABASE [AppleInc] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [AppleInc] SET DB_CHAINING OFF 
GO
ALTER DATABASE [AppleInc] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [AppleInc] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [AppleInc] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'AppleInc', N'ON'
GO
ALTER DATABASE [AppleInc] SET QUERY_STORE = OFF
GO
USE [AppleInc]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
USE [AppleInc]
GO
/****** Object:  UserDefinedFunction [dbo].[getOldestItemForDelivery]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[getOldestItemForDelivery](@userId INT, @model VARCHAR(20), @caller VARCHAR(20))
RETURNS INT
AS
BEGIN
	DECLARE @calling VARCHAR(20);
	SET @calling = @caller;
	IF @calling = 'Distributor'
		BEGIN
			RETURN(
				 SELECT TOP(1) serialNumber FROM item AS i
				 JOIN item_distributor AS i_d
				 ON i.serialNumber = i_d.itemId
				 WHERE i_d.distributorId = @userId
				 AND i.model = @model
				 AND i_d.departure IS NULL
				 ORDER BY i_d.arrival ASC
			)
		END
	ELSE IF @calling = 'SubDistributor'
		BEGIN
			RETURN(
				 SELECT TOP(1) serialNumber FROM item AS i
				 JOIN item_subDistributor AS i_s
				 ON i.serialNumber = i_s.itemId
				 WHERE i_s.subDistributorId = @userId
				 AND i.model = @model
				 AND i_s.departure IS NULL
				 ORDER BY i_s.arrival ASC
			)
		END
	ELSE IF @calling = 'ChannelPartner'
		BEGIN
			RETURN(
				 SELECT TOP(1) serialNumber FROM item AS i
				 JOIN item_channelPartner AS i_c
				 ON i.serialNumber = i_c.itemId
				 WHERE i_c.channelPartnerId = @userId
				 AND i.model = @model
				 AND i_c.departure IS NULL
				 ORDER BY i_c.arrival ASC
			)
		END
	ELSE IF @calling = 'Store'
		BEGIN
			RETURN(
				 SELECT TOP(1) serialNumber FROM item AS i
				 JOIN item_store AS i_s
				 ON i.serialNumber = i_s.itemId
				 WHERE i_s.storeId = @userId
				 AND i.model = @model
				 AND i_s.departure IS NULL
				 ORDER BY i_s.arrival ASC
			)
		END
	RETURN NULL;
END
GO
/****** Object:  UserDefinedFunction [dbo].[getOldestItemForPickup]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[getOldestItemForPickup](@pickupLocationId INT, @model VARCHAR(20), @caller VARCHAR(20))
RETURNS INT
AS
BEGIN
	DECLARE @calling VARCHAR(20);
	SET @calling = @caller;
	IF @calling = 'Warehouse'
		BEGIN
			RETURN(
				SELECT TOP(1) serialNumber FROM item AS i
				JOIN item_warehouse AS i_w
				ON i.serialNumber = i_w.itemId
				WHERE i_w.warehouseId = @pickupLocationId
				AND i.model = @model
				AND i_w.departure IS NULL
				ORDER BY i_w.arrival ASC
			)
		END
	ELSE IF @calling = 'Distributor'
		BEGIN
			RETURN(
					SELECT TOP(1) serialNumber FROM item AS i
					JOIN item_warehouse AS i_w
					ON i.serialNumber = i_w.itemId
					WHERE i_w.warehouseId = @PickupLocationId
					AND i.model = @model
					AND i_w.departure IS NULL
					ORDER BY i_w.arrival ASC
			)
		END
	ELSE IF @calling = 'SubDistributor'
		BEGIN
			RETURN(
					SELECT TOP(1) serialNumber FROM item AS i
					JOIN item_distributor AS i_d
					ON i.serialNumber = i_d.itemId
					WHERE i_d.distributorId = @PickupLocationId
					AND i.model = @model
					AND i_d.departure IS NULL
					ORDER BY i_d.arrival ASC
			)
		END
	ELSE 
		BEGIN
			RETURN NULL
		END

		RETURN NULL
END
GO
/****** Object:  UserDefinedFunction [dbo].[getPrice]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[getPrice](@itemId INT, @location VARCHAR(20))
RETURNS DECIMAL(19,2)
AS
BEGIN
	DECLARE @result DECIMAL(19,2);
	DECLARE @callTo VARCHAR(20);
	SET @callTo = @location;
	IF @callTo = 'Warehouse'
		BEGIN
			RETURN(
				SELECT [Current Item Price] FROM [ItemToWarehouse]
				WHERE [Item Serial] = @itemId
			)
		END
	ELSE IF @callTo = 'Distributor'
		BEGIN
			RETURN(
				SELECT [Current Item Price] FROM [ItemToDistributor]
				WHERE [Item Serial] = @itemId
			)
		END
	ELSE IF @callTo = 'SubDistributor'
		BEGIN
			RETURN(
				SELECT [Current Item Price] FROM [ItemToSubDistributor]
				WHERE [Item Serial] = @itemId
			)
		END
	ELSE IF @callTo = 'ChannelPartner'
		BEGIN
			RETURN(
				SELECT [Current Item Price] FROM [ItemToChannelPartner]
				WHERE [Item Serial] = @itemId
			)
		END
	ELSE IF @callTo = 'Store'
		BEGIN
			RETURN(
				SELECT [Current Item Price] FROM [ItemToStore]
				WHERE [Item Serial] = @itemId
			)
		END

	RETURN NULL
END
GO
/****** Object:  Table [dbo].[refund_productionHouse]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[refund_productionHouse](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[itemId] [int] NULL,
	[productionId] [int] NULL,
	[arrival] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[productionHouse]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[productionHouse](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[continentName] [nvarchar](50) NULL,
	[tax] [decimal](3, 2) NULL,
 CONSTRAINT [PK__producti__3213E83F44A56037] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[item]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[item](
	[serialNumber] [int] IDENTITY(1,1) NOT NULL,
	[model] [varchar](20) NULL,
	[price] [decimal](19, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[serialNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ItemToReturnProduction]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ItemToReturnProduction] 
AS
SELECT i.serialNumber AS [Item Serial], 
i.model AS [Item Model], 
r_p.arrival AS [Arrival Date], 
'Production' AS [Location Name],
p.id AS [Location Number]
FROM item AS i
	INNER JOIN refund_productionHouse 
	AS r_p
	ON i.serialNumber = r_p.itemId
		INNER JOIN productionHouse 
		AS p
		ON r_p.productionId = p.id;
GO
/****** Object:  Table [dbo].[refund_warehouse]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[refund_warehouse](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[itemId] [int] NULL,
	[warehouseId] [int] NULL,
	[arrival] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[warehouse]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[warehouse](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[countryName] [nvarchar](50) NULL,
 CONSTRAINT [PK__warehous__3213E83F081AB9CD] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ItemToReturnWarehouse]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ItemToReturnWarehouse] 
AS
SELECT i.serialNumber AS [Item Serial], 
i.model AS [Item Model], 
r_w.arrival AS [Arrival Date], 
'Warehouse' AS [Location Name],
w.id AS [Location Number]
FROM item 
AS i
	INNER JOIN refund_warehouse
	AS r_w
	ON i.serialNumber = r_w.itemId
		INNER JOIN warehouse 
		AS w
		ON r_w.warehouseId = w.id;
GO
/****** Object:  Table [dbo].[distributor]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[distributor](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[countryName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK__distribu__3213E83F974E8B2B] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[refund_distributor]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[refund_distributor](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[itemId] [int] NULL,
	[distributorId] [int] NULL,
	[arrival] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ItemToReturnDistributor]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ItemToReturnDistributor] 
AS
SELECT i.serialNumber AS [Item Serial], 
i.model AS [Item Model], 
r_d.arrival AS [Arrival Date], 
'Distributor' AS [Location Name],
d.id AS [Location Number]
FROM item 
AS i
	INNER JOIN refund_distributor
	AS r_d
	ON i.serialNumber = r_d.itemId
		INNER JOIN distributor
		AS d
		ON r_d.distributorId = d.id;
GO
/****** Object:  Table [dbo].[subDistributor]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[subDistributor](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[distributorId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[refund_subDistributor]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[refund_subDistributor](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[itemId] [int] NULL,
	[subDistributorId] [int] NULL,
	[arrival] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ItemToReturnSubDistributor]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ItemToReturnSubDistributor]
AS
SELECT i.serialNumber AS [Item Serial], 
i.model AS [Item Model], 
r_s.arrival AS [Arrival Date], 
'SubDistributor' AS [Location Name],
s.id AS [Location Number]
FROM item
AS i
	INNER JOIN refund_subDistributor
	AS r_s
	ON i.serialNumber = r_s.itemId
		INNER JOIN subDistributor
		AS s
		ON r_s.subDistributorId = s.id;
GO
/****** Object:  Table [dbo].[channelPartner]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[channelPartner](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[subDistributorId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[refund_channelPartner]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[refund_channelPartner](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[itemId] [int] NULL,
	[channelPartnerId] [int] NULL,
	[arrival] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ItemToReturnChannelPartner]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ItemToReturnChannelPartner]
AS
SELECT i.serialNumber AS [Item Serial], 
i.model AS [Item Model], 
r_c.arrival AS [Arrival Date], 
'ChannelPartner' AS [Location Name],
c.id AS [Location Number]
FROM item
AS i
	INNER JOIN refund_channelPartner
	AS r_c
	ON i.serialNumber = r_c.itemId
		INNER JOIN channelPartner
		AS c
		ON r_c.channelPartnerId = c.id;
GO
/****** Object:  Table [dbo].[store]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[store](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[channelPartnerId] [int] NULL,
	[name] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[refund_store]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[refund_store](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[itemId] [int] NULL,
	[storeId] [int] NULL,
	[arrival] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ItemToReturnStore]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ItemToReturnStore]
AS
SELECT i.serialNumber AS [Item Serial],
i.model AS [Item Model], 
r_s.arrival AS [Arrival Date],
'Store' AS [Location Name],
s.id AS [Location Number]
FROM item
AS i
	INNER JOIN refund_store
	AS r_s
	ON i.serialNumber = r_s.itemId
		INNER JOIN store
		AS s
		ON r_s.storeId = s.id;
GO
/****** Object:  Table [dbo].[item_productionHouse]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[item_productionHouse](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[itemId] [int] NULL,
	[productionId] [int] NULL,
	[birth] [datetime] NULL,
	[departure] [datetime] NULL,
	[initPrice] [decimal](19, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ItemToProduction]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ItemToProduction] 
AS
SELECT i.serialNumber AS [Item Serial], 
i.model AS [Item Model], 
i_p.birth AS [Arrival Date], 
i_p.departure AS [Departure Date],
'Production' AS [Location Name],
p.id AS [Location Number], 
i_p.initPrice AS [Current Item Price]
FROM item AS i
	INNER JOIN item_productionHouse 
	AS i_p
	ON i.serialNumber = i_p.itemId
		INNER JOIN productionHouse 
		AS p
		ON i_p.productionId = p.id;
GO
/****** Object:  Table [dbo].[item_warehouse]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[item_warehouse](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[itemId] [int] NULL,
	[warehouseId] [int] NULL,
	[arrival] [datetime] NULL,
	[currentPrice] [decimal](19, 2) NOT NULL,
	[departure] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ItemToWarehouse]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ItemToWarehouse] 
AS
SELECT i.serialNumber AS [Item Serial], 
i.model AS [Item Model], 
i_w.arrival AS [Arrival Date], 
i_w.departure AS [Departure Date], 
'Warehouse' AS [Location Name],
w.id AS [Location Number], 
i_w.currentPrice AS [Current Item Price]
FROM item 
AS i
	INNER JOIN item_warehouse
	AS i_w
	ON i.serialNumber = i_w.itemId
		INNER JOIN warehouse 
		AS w
		ON i_w.warehouseId = w.id;
GO
/****** Object:  Table [dbo].[item_distributor]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[item_distributor](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[itemId] [int] NULL,
	[distributorId] [int] NULL,
	[arrival] [datetime] NULL,
	[departure] [datetime] NULL,
	[currentPrice] [decimal](19, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ItemToDistributor]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ItemToDistributor] 
AS
SELECT i.serialNumber AS [Item Serial], 
i.model AS [Item Model], 
i_d.arrival AS [Arrival Date], 
i_d.departure AS [Departure Date], 
'Distributor' AS [Location Name],
d.id AS [Location Number], 
i_d.currentPrice AS [Current Item Price]
FROM item 
AS i
	INNER JOIN item_distributor
	AS i_d
	ON i.serialNumber = i_d.itemId
		INNER JOIN distributor
		AS d
		ON i_d.distributorId = d.id;
GO
/****** Object:  Table [dbo].[item_subDistributor]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[item_subDistributor](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[itemId] [int] NULL,
	[subDistributorId] [int] NULL,
	[arrival] [datetime] NULL,
	[departure] [datetime] NULL,
	[currentPrice] [decimal](19, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ItemToSubDistributor]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ItemToSubDistributor]
AS
SELECT i.serialNumber AS [Item Serial], 
i.model AS [Item Model], 
i_s.arrival AS [Arrival Date], 
i_s.departure AS [Departure Date], 
'SubDistributor' AS [Location Name],
s.id AS [Location Number], 
i_s.currentPrice AS [Current Item Price]
FROM item
AS i
	INNER JOIN item_subDistributor
	AS i_s
	ON i.serialNumber = i_s.itemId
		INNER JOIN subDistributor
		AS s
		ON i_s.subDistributorId = s.id;
GO
/****** Object:  Table [dbo].[item_channelPartner]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[item_channelPartner](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[itemId] [int] NULL,
	[channelPartnerId] [int] NULL,
	[arrival] [datetime] NULL,
	[departure] [datetime] NULL,
	[currentPrice] [decimal](19, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ItemToChannelPartner]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ItemToChannelPartner]
AS
SELECT i.serialNumber AS [Item Serial], 
i.model AS [Item Model], 
i_c.arrival AS [Arrival Date], 
i_c.departure AS [Departure Date], 
'ChannelPartner' AS [Location Name],
c.id AS [Location Number], 
i_c.currentPrice AS [Current Item Price]
FROM item
AS i
	INNER JOIN item_channelPartner
	AS i_c
	ON i.serialNumber = i_c.itemId
		INNER JOIN channelPartner
		AS c
		ON i_c.channelPartnerId = c.id;
GO
/****** Object:  Table [dbo].[item_store]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[item_store](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[itemId] [int] NULL,
	[storeId] [int] NULL,
	[arrival] [datetime] NULL,
	[departure] [datetime] NULL,
	[currentPrice] [decimal](19, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ItemToStore]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ItemToStore]
AS
SELECT i.serialNumber AS [Item Serial],
i.model AS [Item Model], 
i_s.arrival AS [Arrival Date],
i_s.departure AS [Departure Date],
'Store' AS [Location Name],
s.id AS [Location Number], 
i_s.currentPrice AS [Current Item Price]
FROM item
AS i
	INNER JOIN item_store
	AS i_s
	ON i.serialNumber = i_s.itemId
		INNER JOIN store
		AS s
		ON i_s.storeId = s.id;
GO
/****** Object:  Table [dbo].[customer]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customer](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[storeId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[item_customer]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[item_customer](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[itemId] [int] NULL,
	[customerId] [int] NULL,
	[purchased] [datetime] NULL,
	[salePrice] [decimal](19, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ItemToCustomer]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ItemToCustomer]
AS
SELECT i.serialNumber AS [Item Serial],
i.model AS [Item Model],
i_c.purchased AS [Purchased Date], 
c.id AS [Customer ID], 
i_c.salePrice AS [Item Buying Price]
FROM item
AS i
	INNER JOIN item_customer
	AS i_c
	ON i.serialNumber = i_c.itemId
		INNER JOIN customer
		AS c
		ON i_c.customerId = c.id;
GO
/****** Object:  Table [dbo].[apple]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[apple](
	[id] [int] IDENTITY(1,1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[continent]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[continent](
	[name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK__continen__72E12F1AF8DDF65A] PRIMARY KEY CLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[country]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[country](
	[name] [nvarchar](50) NOT NULL,
	[continentName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK__country__72E12F1A34E8EF2A] PRIMARY KEY CLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[zone]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[zone](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[channelPartnerId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[item_channelPartner] ADD  DEFAULT (getdate()) FOR [arrival]
GO
ALTER TABLE [dbo].[item_distributor] ADD  DEFAULT (getdate()) FOR [arrival]
GO
ALTER TABLE [dbo].[item_productionHouse] ADD  DEFAULT (getdate()) FOR [birth]
GO
ALTER TABLE [dbo].[item_store] ADD  DEFAULT (getdate()) FOR [arrival]
GO
ALTER TABLE [dbo].[item_subDistributor] ADD  DEFAULT (getdate()) FOR [arrival]
GO
ALTER TABLE [dbo].[item_warehouse] ADD  DEFAULT (getdate()) FOR [arrival]
GO
ALTER TABLE [dbo].[productionHouse] ADD  CONSTRAINT [DF__productionH__tax__29572725]  DEFAULT ((0.1)) FOR [tax]
GO
ALTER TABLE [dbo].[refund_channelPartner] ADD  DEFAULT (getdate()) FOR [arrival]
GO
ALTER TABLE [dbo].[refund_distributor] ADD  DEFAULT (getdate()) FOR [arrival]
GO
ALTER TABLE [dbo].[refund_productionHouse] ADD  DEFAULT (getdate()) FOR [arrival]
GO
ALTER TABLE [dbo].[refund_store] ADD  DEFAULT (getdate()) FOR [arrival]
GO
ALTER TABLE [dbo].[refund_subDistributor] ADD  DEFAULT (getdate()) FOR [arrival]
GO
ALTER TABLE [dbo].[refund_warehouse] ADD  DEFAULT (getdate()) FOR [arrival]
GO
ALTER TABLE [dbo].[channelPartner]  WITH CHECK ADD FOREIGN KEY([subDistributorId])
REFERENCES [dbo].[subDistributor] ([id])
GO
ALTER TABLE [dbo].[country]  WITH CHECK ADD  CONSTRAINT [FK__country__contine__2C3393D0] FOREIGN KEY([continentName])
REFERENCES [dbo].[continent] ([name])
GO
ALTER TABLE [dbo].[country] CHECK CONSTRAINT [FK__country__contine__2C3393D0]
GO
ALTER TABLE [dbo].[customer]  WITH CHECK ADD FOREIGN KEY([storeId])
REFERENCES [dbo].[store] ([id])
GO
ALTER TABLE [dbo].[distributor]  WITH CHECK ADD  CONSTRAINT [FK__distribut__count__31EC6D26] FOREIGN KEY([countryName])
REFERENCES [dbo].[country] ([name])
GO
ALTER TABLE [dbo].[distributor] CHECK CONSTRAINT [FK__distribut__count__31EC6D26]
GO
ALTER TABLE [dbo].[item_channelPartner]  WITH CHECK ADD FOREIGN KEY([channelPartnerId])
REFERENCES [dbo].[channelPartner] ([id])
GO
ALTER TABLE [dbo].[item_channelPartner]  WITH CHECK ADD FOREIGN KEY([itemId])
REFERENCES [dbo].[item] ([serialNumber])
GO
ALTER TABLE [dbo].[item_customer]  WITH CHECK ADD FOREIGN KEY([customerId])
REFERENCES [dbo].[customer] ([id])
GO
ALTER TABLE [dbo].[item_customer]  WITH CHECK ADD FOREIGN KEY([itemId])
REFERENCES [dbo].[item] ([serialNumber])
GO
ALTER TABLE [dbo].[item_distributor]  WITH CHECK ADD  CONSTRAINT [FK__item_dist__distr__49C3F6B7] FOREIGN KEY([distributorId])
REFERENCES [dbo].[distributor] ([id])
GO
ALTER TABLE [dbo].[item_distributor] CHECK CONSTRAINT [FK__item_dist__distr__49C3F6B7]
GO
ALTER TABLE [dbo].[item_distributor]  WITH CHECK ADD FOREIGN KEY([itemId])
REFERENCES [dbo].[item] ([serialNumber])
GO
ALTER TABLE [dbo].[item_productionHouse]  WITH CHECK ADD FOREIGN KEY([itemId])
REFERENCES [dbo].[item] ([serialNumber])
GO
ALTER TABLE [dbo].[item_productionHouse]  WITH CHECK ADD  CONSTRAINT [FK__item_prod__produ__4222D4EF] FOREIGN KEY([productionId])
REFERENCES [dbo].[productionHouse] ([id])
GO
ALTER TABLE [dbo].[item_productionHouse] CHECK CONSTRAINT [FK__item_prod__produ__4222D4EF]
GO
ALTER TABLE [dbo].[item_store]  WITH CHECK ADD FOREIGN KEY([itemId])
REFERENCES [dbo].[item] ([serialNumber])
GO
ALTER TABLE [dbo].[item_store]  WITH CHECK ADD FOREIGN KEY([storeId])
REFERENCES [dbo].[store] ([id])
GO
ALTER TABLE [dbo].[item_subDistributor]  WITH CHECK ADD FOREIGN KEY([itemId])
REFERENCES [dbo].[item] ([serialNumber])
GO
ALTER TABLE [dbo].[item_subDistributor]  WITH CHECK ADD FOREIGN KEY([subDistributorId])
REFERENCES [dbo].[subDistributor] ([id])
GO
ALTER TABLE [dbo].[item_warehouse]  WITH CHECK ADD FOREIGN KEY([itemId])
REFERENCES [dbo].[item] ([serialNumber])
GO
ALTER TABLE [dbo].[item_warehouse]  WITH CHECK ADD  CONSTRAINT [FK__item_ware__wareh__45F365D3] FOREIGN KEY([warehouseId])
REFERENCES [dbo].[warehouse] ([id])
GO
ALTER TABLE [dbo].[item_warehouse] CHECK CONSTRAINT [FK__item_ware__wareh__45F365D3]
GO
ALTER TABLE [dbo].[productionHouse]  WITH CHECK ADD  CONSTRAINT [FK__productio__conti__286302EC] FOREIGN KEY([continentName])
REFERENCES [dbo].[continent] ([name])
GO
ALTER TABLE [dbo].[productionHouse] CHECK CONSTRAINT [FK__productio__conti__286302EC]
GO
ALTER TABLE [dbo].[refund_channelPartner]  WITH CHECK ADD FOREIGN KEY([channelPartnerId])
REFERENCES [dbo].[channelPartner] ([id])
GO
ALTER TABLE [dbo].[refund_channelPartner]  WITH CHECK ADD FOREIGN KEY([itemId])
REFERENCES [dbo].[item] ([serialNumber])
GO
ALTER TABLE [dbo].[refund_distributor]  WITH CHECK ADD FOREIGN KEY([distributorId])
REFERENCES [dbo].[distributor] ([id])
GO
ALTER TABLE [dbo].[refund_distributor]  WITH CHECK ADD FOREIGN KEY([itemId])
REFERENCES [dbo].[item] ([serialNumber])
GO
ALTER TABLE [dbo].[refund_productionHouse]  WITH CHECK ADD FOREIGN KEY([itemId])
REFERENCES [dbo].[item] ([serialNumber])
GO
ALTER TABLE [dbo].[refund_productionHouse]  WITH CHECK ADD FOREIGN KEY([productionId])
REFERENCES [dbo].[productionHouse] ([id])
GO
ALTER TABLE [dbo].[refund_store]  WITH CHECK ADD FOREIGN KEY([itemId])
REFERENCES [dbo].[item] ([serialNumber])
GO
ALTER TABLE [dbo].[refund_store]  WITH CHECK ADD FOREIGN KEY([storeId])
REFERENCES [dbo].[store] ([id])
GO
ALTER TABLE [dbo].[refund_subDistributor]  WITH CHECK ADD FOREIGN KEY([itemId])
REFERENCES [dbo].[item] ([serialNumber])
GO
ALTER TABLE [dbo].[refund_subDistributor]  WITH CHECK ADD FOREIGN KEY([subDistributorId])
REFERENCES [dbo].[subDistributor] ([id])
GO
ALTER TABLE [dbo].[refund_warehouse]  WITH CHECK ADD FOREIGN KEY([itemId])
REFERENCES [dbo].[item] ([serialNumber])
GO
ALTER TABLE [dbo].[refund_warehouse]  WITH CHECK ADD FOREIGN KEY([warehouseId])
REFERENCES [dbo].[warehouse] ([id])
GO
ALTER TABLE [dbo].[store]  WITH CHECK ADD FOREIGN KEY([channelPartnerId])
REFERENCES [dbo].[channelPartner] ([id])
GO
ALTER TABLE [dbo].[subDistributor]  WITH CHECK ADD  CONSTRAINT [FK__subDistri__distr__34C8D9D1] FOREIGN KEY([distributorId])
REFERENCES [dbo].[distributor] ([id])
GO
ALTER TABLE [dbo].[subDistributor] CHECK CONSTRAINT [FK__subDistri__distr__34C8D9D1]
GO
ALTER TABLE [dbo].[warehouse]  WITH CHECK ADD  CONSTRAINT [FK__warehouse__count__2F10007B] FOREIGN KEY([countryName])
REFERENCES [dbo].[country] ([name])
GO
ALTER TABLE [dbo].[warehouse] CHECK CONSTRAINT [FK__warehouse__count__2F10007B]
GO
ALTER TABLE [dbo].[zone]  WITH CHECK ADD FOREIGN KEY([channelPartnerId])
REFERENCES [dbo].[channelPartner] ([id])
GO
/****** Object:  StoredProcedure [dbo].[channelPartnerDelvierItems]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[channelPartnerDelvierItems](@channelPartnerId INT, @model VARCHAR(20), @count INT, @storeId INT)
AS
BEGIN
	DECLARE @incrementCount INT;
	SET @incrementCount = @count;

	WHILE @incrementCount > 0
		BEGIN
			DECLARE @getItemId INT;
			--Select @getItemId = 
			SELECT @getItemId = dbo.getOldestItemForDelivery(@channelPartnerId, @model, 'ChannelPartner');
			--update item_distributor
			UPDATE item_channelPartner
			SET item_channelPartner.departure = GETDATE()
			WHERE item_channelPartner.itemId = @getItemId

			--get old price
			DECLARE @currentPrice DECIMAL(19,2);
			SELECT @currentPrice = dbo.getPrice(@getItemId, 'ChannelPartner');
			--old price * .08 + oldprice
			DECLARE @newPrice DECIMAL(19,2);
			SET @newPrice = @currentPrice * .08 + @currentPrice;

			--store will have to pick up
			INSERT INTO item_store(itemId,storeId,arrival, currentPrice)VALUES(@getItemId,@storeId,GETDATE(), @newPrice);

			SELECT @incrementCount = @incrementCount - 1;
		END
END
GO
/****** Object:  StoredProcedure [dbo].[channelPartnerItemCount]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[channelPartnerItemCount](@channelPartnerId INT)
AS
BEGIN
	WITH cte_channelPartnerItemBridge
	AS 
	(SELECT * FROM item AS i
	JOIN item_channelPartner AS i_c
	ON i.serialNumber = i_c.itemId
	WHERE i_c.channelPartnerId = @channelPartnerId
	)

	SELECT model, COUNT(*) AS [Quantity]
	FROM cte_channelPartnerItemBridge
	GROUP BY model
END
GO
/****** Object:  StoredProcedure [dbo].[channelPartnerPickUpItems]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[channelPartnerPickUpItems](@channelPartnerId INT, @model VARCHAR(20), @count INT)
AS
BEGIN
--subdistributor
	DECLARE @subDistriId INT;
	SELECT @subDistriId = subDistributorId FROM channelPartner
	WHERE channelPartner.id = @channelPartnerId

	EXECUTE subDistributorDelvierItems @subDistriId, @model, @count, @channelPartnerId
	--subDistributorDelvierItems(@subDistributorId INT, @model VARCHAR(20), @count INT, @channelPartnerId INT)
	
END
GO
/****** Object:  StoredProcedure [dbo].[createChannelPartner]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[createChannelPartner](@subDistributorId INT)
AS
BEGIN
	DECLARE @channelPartnerCount INT;
	SET @channelPartnerCount = (SELECT  FLOOR(RAND() * (7 - 5+1) +5)); -- 5-7
			WHILE @channelPartnerCount > 0
				BEGIN
					INSERT INTO channelPartner(subDistributorId) VALUES(@subDistributorId);
					SELECT @channelPartnerCount = @channelPartnerCount - 1;
				END
END
GO
/****** Object:  StoredProcedure [dbo].[createDistributor]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[createDistributor](@country NVARCHAR(50))
AS
BEGIN
	INSERT INTO distributor(countryName) VALUES(@country);
END
GO
/****** Object:  StoredProcedure [dbo].[createItems]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[createItems](@amountToCreate INT, @model VARCHAR(20), @productionId INT, @warehouseId INT, @price DECIMAL(19,2))
AS
BEGIN
	DECLARE @itemCount INT;
	SET @itemCount = @amountToCreate;

	DECLARE @findPrice DECIMAL(19,2);
	IF @price IS NULL
		BEGIN
			IF @model = 'MacBook'
				SET @findPrice = 2000.00
			ELSE
				SET @findPrice = 1200.00
		END
	ELSE 
		BEGIN
			SET @FindPrice = @price;
		END

	WHILE @itemCount > 0
	BEGIN
		DECLARE @itemId INT
		--create item
		INSERT INTO item(model, price) VALUES(@model, @price);
		SET @itemId = SCOPE_IDENTITY();

		--connect to productionHouse
		INSERT INTO item_productionHouse(itemId,productionId,birth,departure,initPrice)
		VALUES(@itemId,@productionId, GETDATE(), GETDATE(), @findPrice);

		--connect to warehouse
		INSERT INTO item_warehouse(itemId,warehouseId,arrival,currentPrice)
		VALUES(@itemId,@warehouseId,GETDATE(),@findPrice)
		
		SELECT @itemCount = @itemCount - 1;
	END
END
GO
/****** Object:  StoredProcedure [dbo].[createProduction]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[createProduction](@continent NVARCHAR(50))
AS
BEGIN
	DECLARE @productionCount INT;
	SET @productionCount = 3;

	WHILE @productionCount > 0
		BEGIN
			--FK
			--DECLARE @productionFk NVARCHAR(50);
			--SET @subDistributorFk = ''varname'';
			--insert
			INSERT INTO productionHouse(continentName) VALUES(@continent);
			SELECT @productionCount = @productionCount - 1;
		END
END
GO
/****** Object:  StoredProcedure [dbo].[createProducts]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[createProducts] 
AS
BEGIN
	DECLARE @count INT = 0;
	--serialNumber is issued by db
	DECLARE @model VARCHAR(20);
	DECLARE @price DECIMAL(19,2);

	WHILE @count < 50
	BEGIN
		SELECT @count = @count +1
		IF @count % 2 = 0
			BEGIN
				SET @model = 'MacBook';
				SET @price = '2000';
			END
		ELSE 
			BEGIN
				SET @model = 'IPhone';
				set @price = '1200';
			END

		INSERT INTO item VALUES(@model, @price);
	END
END
GO
/****** Object:  StoredProcedure [dbo].[createStore]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[createStore](@channelPartnerId INT)
AS
BEGIN
	DECLARE @storeCount INT;
	SET @storeCount = (SELECT  FLOOR(RAND() * (4+1) +1)); --1-4
	WHILE @storeCount > 0 
		BEGIN
			DECLARE @storeName VARCHAR(50);
			IF (@storeCount = 4)
				SET @storeName = 'Toms';
			ELSE IF(@storeCount = 3)
				SET @storeName = 'Tonys';
			ELSE IF (@storeCount = 2)
				SET @storeName = 'Tiffanys';
			ELSE
				SET @storeName = 'Joeys';

			INSERT INTO store(channelPartnerId,name) VALUES(@channelPartnerId,@storeName);   -----------------------------------------------------------------
			SELECT @storeCount = @StoreCount -1;
		END
END
GO
/****** Object:  StoredProcedure [dbo].[createSubDistributor]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[createSubDistributor](@distributorId INT)
AS
BEGIN

	DECLARE @subDistributorCount INT;
	SET @subDistributorCount = (SELECT  FLOOR(RAND() * (3 - 1+1) +1)); -- 1-3
	WHILE @subDistributorCount > 0
		BEGIN
			INSERT INTO subDistributor(distributorId) VALUES(@distributorId);
			SELECT @subDistributorCount = @subDistributorCount - 1;
		END
END
GO
/****** Object:  StoredProcedure [dbo].[createWarehouse]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[createWarehouse](@country NVARCHAR(50))
AS
BEGIN
	DECLARE @warehouseCount INT;
	SET @warehouseCount = 4;

	WHILE @warehouseCount > 0
		BEGIN
			--FK
			--DECLARE @productionFk NVARCHAR(50);
			--SET @subDistributorFk = ''varname'';
			--insert
			INSERT INTO warehouse(countryName) VALUES(@country);
			SELECT @warehouseCount = @warehouseCount - 1;
		END
END
GO
/****** Object:  StoredProcedure [dbo].[distributorDelvierItems]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[distributorDelvierItems](@distributorId INT, @model VARCHAR(20), @count INT, @subDistributorID INT)
AS
BEGIN
	DECLARE @incrementCount INT;
	SET @incrementCount = @count;

	WHILE @incrementCount > 0
		BEGIN
			DECLARE @getItemId INT;
			SELECT @getItemId = dbo.getOldestItemForDelivery(@distributorId, @model, 'Distributor');
			--update item_distributor
			UPDATE item_distributor
			SET item_distributor.departure = GETDATE()
			WHERE item_distributor.itemId = @getItemId

			--get old price
			DECLARE @currentPrice DECIMAL(19,2);
			SELECT @currentPrice = dbo.getPrice(@getItemId, 'Distributor');
			--old price * .08 + oldprice
			Declare @newPrice DECIMAL(19,2);
			SET @newPrice = @currentPrice * .08 + @currentPrice;

			--subdistributor will have to pick up
			INSERT INTO item_subDistributor(itemId,subDistributorId,arrival, currentPrice)VALUES(@getItemId,@subDistributorId,GETDATE(), @newPrice);

			SELECT @incrementCount = @incrementCount - 1;
		END
END
GO
/****** Object:  StoredProcedure [dbo].[distributorItemCount]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[distributorItemCount](@distributorId INT)
AS
BEGIN
	WITH cte_distributorItemBridge
	AS 
	(SELECT * FROM item AS i
	JOIN item_distributor AS i_d
	ON i.serialNumber = i_d.itemId
	WHERE i_d.distributorId = @distributorId
	)

	SELECT model, COUNT(*) AS [Quantity]
	FROM cte_distributorItemBridge
	GROUP BY model
END
GO
/****** Object:  StoredProcedure [dbo].[distributorPickUpItems]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[distributorPickUpItems](@distributorId INT, @model VARCHAR(20), @count INT, @warehouseId INT)
AS
BEGIN
	PRINT 'in distributor pick up'
	DECLARE @counter INT;
	SELECT @counter = @count;
	WHILE @counter > 0
		BEGIN
			--PRINT @counter
			SELECT @counter = @counter - 1;
			DECLARE @itemId INT;
			--get oldest
			WITH cte_itemsInWarehouse
			AS
			(SELECT TOP(1) serialNumber FROM item AS i
			JOIN item_warehouse AS i_w
			ON i.serialNumber = i_w.itemId
			WHERE i_w.warehouseId = @warehouseId
			AND i.model = @model
			AND i_w.departure IS NULL
			ORDER BY i_w.arrival ASC)
			
			--place into variable
			select @itemId = (SELECT * from cte_itemsInWarehouse)

			--PRINT @itemId

			--update warehouse item
			UPDATE item_warehouse
			SET departure = GETDATE()
			WHERE item_warehouse.itemId = @itemId


			--get old price
			DECLARE @currentPrice DECIMAL(19,2);
			SELECT @currentPrice = dbo.getPrice(@itemId, 'Warehouse');
			--old price * .08 + oldprice
			DECLARE @newPrice DECIMAL(19,2);
			SET @newPrice = @currentPrice * .08 + @currentPrice;
			--create distributor item bridge

			--PRINT @newPrice
			--PRINT 'insert into item_distributor'
			INSERT INTO item_distributor(itemId,distributorId, arrival, currentPrice) VALUES(@itemId, @distributorId, GETDATE(), @newPrice);
			 

		END

END
GO
/****** Object:  StoredProcedure [dbo].[distributorPickUpItemsTriggerCall]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[distributorPickUpItemsTriggerCall](@distributorId INT, @model VARCHAR(20), @count INT, @warehouseId INT)
AS
BEGIN
	ALTER TABLE item_distributor DISABLE TRIGGER tr_distributorRestock

	DECLARE @counter INT;
	SET @counter = @count;
	WHILE @counter > 0
		BEGIN
			SET @counter = @counter - 1;
			DECLARE @itemId INT;
			--get oldest
			WITH cte_itemsInWarehouse
			AS
			(SELECT TOP(1) serialNumber FROM item AS i
			JOIN item_warehouse AS i_w
			ON i.serialNumber = i_w.itemId
			WHERE i_w.warehouseId = @warehouseId
			AND i.model = @model
			AND i_w.departure IS NULL
			ORDER BY i_w.arrival ASC)
			
			--place into variable
			select @itemId = (SELECT * from cte_itemsInWarehouse)

			ALTER TABLE item_warehouse DISABLE TRIGGER tr_warehouseRestock
			--update warehouse item
			UPDATE item_warehouse
			SET departure = GETDATE()
			WHERE item_warehouse.itemId = @itemId

			ALTER TABLE item_warehouse ENABLE TRIGGER tr_warehouseRestock

			--get old price
			DECLARE @currentPrice DECIMAL(19,2);
			SELECT @currentPrice = dbo.getPrice(@itemId, 'Warehouse');
			--old price * .08 + oldprice
			Declare @newPrice DECIMAL(19,2);
			SET @newPrice = @currentPrice * .08 + @currentPrice;
			--create distributor item bridge
			DECLARE @startDate DATETIME;
			SET @startDate = GETDATE();

			PRINT 'insert into item_distributor'

			ALTER TABLE item_distributor DISABLE TRIGGER tr_distributorRestock
			INSERT INTO item_distributor(itemId,distributorId, arrival, currentPrice) VALUES(@itemId, @distributorId, @startDate, @newPrice);
			ALTER TABLE item_distributor ENABLE TRIGGER tr_distributorRestock
			   
		END

		ALTER TABLE item_distributor ENABLE TRIGGER tr_distributorRestock
END
GO
/****** Object:  StoredProcedure [dbo].[distributorRestock]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[distributorRestock](@distributorId INT, @model VARCHAR(20))
AS
BEGIN
	DECLARE @countProduct INT;
	SET @countProduct = (SELECT COUNT(*) FROM item AS i
	JOIN item_distributor AS i_d
	ON i.serialNumber = i_d.itemId
	WHERE i_d.distributorId = @distributorId
	AND i.model = @model
	GROUP BY i_d.distributorId)

	PRINT @countProduct
	DECLARE @amountToOrder INT;
	IF @countProduct < 800
		BEGIN
			SET @amountToOrder = 1000 - @countProduct;
		END
		--get warehouse id with most inv
	DECLARE @findWarehouse INT;
	EXECUTE @findWarehouse = findRandomWarehouse @distributorId;

	PRINT 'findWarehouse ' + convert(varchar,@findWarehouse)
	PRINT @amountToOrder
	--get items
	PRINT 'going to distributorpickupitems'
	EXECUTE distributorPickUpItems @distributorId, @model, @amountToOrder, @findWarehouse
	print 'AFTER PICKUP'
END
GO
/****** Object:  StoredProcedure [dbo].[findMyChannelPartners]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[findMyChannelPartners](@subDistributorId INT)
AS
BEGIN
	SELECT c.id FROM channelPartner AS c
	JOIN subDistributor AS s
	ON c.subDistributorId = s.id
	WHERE s.id = @subDistributorId
END
GO
/****** Object:  StoredProcedure [dbo].[findMyStores]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[findMyStores](@channelPartnerId INT)
AS
BEGIN
	SELECT s.id FROM store AS s
	JOIN channelPartner AS c
	ON s.channelPartnerId = c.id
	WHERE c.id = @channelPartnerId
END
GO
/****** Object:  StoredProcedure [dbo].[findMySubDistributors]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[findMySubDistributors](@distributorId INT)
AS
BEGIN
	SELECT s.id FROM subDistributor AS s
	JOIN distributor AS d
	ON s.distributorId = d.id
	WHERE d.id = @distributorId
END
GO
/****** Object:  StoredProcedure [dbo].[findProductionHouse]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[findProductionHouse](@warehouseId INT)
AS
BEGIN
	DECLARE @result INT;

	SELECT 
	TOP(1)
	@result = productionhouse.id
	FROM country
	JOIN continent
	ON country.continentname = continent.name
	JOIN warehouse
	ON warehouse.countryName = country.name
	JOIN productionhouse
	ON productionhouse.continentname = continent.name
	WHERE warehouse.id = @warehouseId
	ORDER BY NEWID()
	
	RETURN @result;
END
GO
/****** Object:  StoredProcedure [dbo].[findProductionHouses]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[findProductionHouses](@warehouseId INT)
AS
BEGIN
	select 
	warehouse.id as [warehouse id],
	country.name as [country name],
	continent.name as [continent name],
	productionhouse.id as [production id]
	from country
	join continent
	on country.continentname = continent.name
	join warehouse
	on warehouse.countryName = country.name
	join productionhouse
	on productionhouse.continentname = continent.name
	where warehouse.id = @warehouseId
	order by productionhouse.id asc
END
GO
/****** Object:  StoredProcedure [dbo].[findRandomWarehouse]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[findRandomWarehouse](@distributorId INT)
AS
BEGIN
	DECLARE @result INT;
	
	--random warehouse
	SELECT 
	TOP(1)
	@result = warehouse.id
	FROM distributor
	JOIN warehouse
	ON distributor.countryName = warehouse.countryName

	WHERE distributor.id = 2 
	ORDER BY NEWID()
	
	RETURN @result;
END
GO
/****** Object:  StoredProcedure [dbo].[findWarehouse]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[findWarehouse](@distributorId INT)
AS
BEGIN
	DECLARE @result INT;

	SELECT 
	TOP(1)
	@result = warehouse.id
	FROM distributor
	JOIN warehouse
	ON distributor.countryName = warehouse.countryName
	WHERE distributor.id = @distributorId
	ORDER BY NEWID()
	
	RETURN @result;
END
GO
/****** Object:  StoredProcedure [dbo].[findWarehouses]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[findWarehouses](@distributorId INT)
AS
BEGIN
	SELECT w.id AS [Warehouse Id] FROM warehouse AS w
	JOIN distributor AS d
	ON w.countryName = d.countryName
	WHERE d.id = @distributorId
END
GO
/****** Object:  StoredProcedure [dbo].[issueDefect]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[issueDefect](@itemId INT)
AS
BEGIN
	--variables
	DECLARE @foundCustomer INT;
	DECLARE @foundStore INT;
	DECLARE @foundChannelPartner INT;
	DECLARE @foundSubDistributor INT;
	DECLARE @foundDistributor INT;
	DECLARE @foundWarehouse INT;
	DECLARE @foundProductionHouse INT;
	DECLARE @refundPrice INT;
	SET @refundPrice = 0;

	--get customer
	SELECT customerId from item_customer
	WHERE item_customer.itemId = @itemId;
	--get storeid
	SELECT @foundStore = storeId FROM item_store
	WHERE item_store.itemId = @itemId;
	--get channelPartner
	SELECT @foundChannelPartner = channelPartnerId FROM item_channelPartner
	WHERE item_channelPartner.itemId = @itemId;
	--get subDistributor
	SELECT @foundSubDistributor = subDistributorId FROM item_subDistributor
	WHERE item_subDistributor.itemId = @itemId;
	--get distributor
	SELECT @foundDistributor = distributorId FROM item_distributor
	WHERE item_distributor.itemId = @itemId;
	--get warehouse
	SELECT @foundWarehouse = warehouseId FROM item_warehouse
	WHERE item_warehouse.itemId = @itemId;
	--get productionHouse
	SELECT @foundProductionHouse = productionId FROM item_productionHouse
	WHERE item_productionHouse.itemId = @itemId;

	PRINT @foundStore
	PRINT @foundChannelPartner
	PRINT @foundSubDistributor
	PRINT @foundDistributor
	PRINT @foundWarehouse
	PRINT @foundProductionHouse

	--get item from customer
	UPDATE item_customer
	SET itemId = NULL
	WHERE item_customer.customerId = @foundCustomer

	--ship item back to production
	INSERT INTO refund_store(itemId,storeId,arrival)VALUES(@itemId,@foundStore,GETDATE());
	INSERT INTO refund_channelPartner(itemId,channelPartnerId,arrival)VALUES(@itemId,@foundChannelPartner,GETDATE());
	INSERT INTO refund_subDistributor(itemId,subDistributorId,arrival)VALUES(@itemId,@foundSubDistributor,GETDATE());
	INSERT INTO refund_distributor(itemId,distributorId,arrival)VALUES(@itemId,@foundDistributor,GETDATE());
	INSERT INTO refund_warehouse(itemId,warehouseId,arrival)VALUES(@itemId,@foundWarehouse,GETDATE());
	INSERT INTO refund_productionHouse(itemId,productionId,arrival)VALUES(@itemId,@foundProductionHouse,GETDATE());
	PRINT 'ship back to customer'
	--give item back to customerchain
	INSERT INTO item_productionHouse(itemId,productionId,birth, initPrice)VALUES(@itemId,@foundProductionHouse,GETDATE(), @refundPrice);
	INSERT INTO item_warehouse(itemId,warehouseId,arrival,currentPrice)VALUES(@itemId,@foundWarehouse,GETDATE(), @refundPrice);
	INSERT INTO item_distributor(itemId,distributorId,arrival,currentPrice)VALUES(@itemId,@foundDistributor,GETDATE(),@refundPrice);
	INSERT INTO item_subDistributor(itemId,subDistributorId,arrival,currentPrice)VALUES(@itemId,@foundSubDistributor,GETDATE(),@refundPrice);
	INSERT INTO item_channelPartner(itemId,channelPartnerId,arrival,currentPrice)VALUES(@itemId,@foundChannelPartner,GETDATE(),@refundPrice);
	INSERT INTO item_store(itemId,storeId,arrival,currentPrice)VALUES(@itemId,@foundStore,GETDATE(),@refundPrice);

	--get item from customer
	UPDATE item_customer
	SET itemId = @itemId
	WHERE item_customer.customerId = @foundCustomer
	
END
GO
/****** Object:  StoredProcedure [dbo].[issueRefund]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[issueRefund](@itemId INT)
AS
BEGIN
	--variables
	DECLARE @foundCustomer INT;
	DECLARE @foundStore INT;
	DECLARE @foundChannelPartner INT;
	DECLARE @foundSubDistributor INT;
	DECLARE @foundDistributor INT;
	DECLARE @foundWarehouse INT;
	DECLARE @foundProductionHouse INT;

	--get customer
	SELECT @foundCustomer = customerId from item_customer
	WHERE item_customer.itemId = @itemId;
	--get storeid
	SELECT @foundStore = storeId FROM item_store
	WHERE item_store.itemId = @itemId;
	--get channelPartner
	SELECT @foundChannelPartner = channelPartnerId FROM item_channelPartner
	WHERE item_channelPartner.itemId = @itemId;
	--get subDistributor
	SELECT @foundSubDistributor = subDistributorId FROM item_subDistributor
	WHERE item_subDistributor.itemId = @itemId;
	--get distributor
	SELECT @foundDistributor = distributorId FROM item_distributor
	WHERE item_distributor.itemId = @itemId;
	--get warehouse
	SELECT @foundWarehouse = warehouseId FROM item_warehouse
	WHERE item_warehouse.itemId = @itemId;
	--get productionHouse
	SELECT @foundProductionHouse = productionId FROM item_productionHouse
	WHERE item_productionHouse.itemId = @itemId;

	--get item from customer
	UPDATE item_customer
	SET itemId = NULL
	WHERE item_customer.customerId = @foundCustomer

	--ship item back to production
	INSERT INTO refund_store(itemId,storeId,arrival)VALUES(@itemId,@foundStore,GETDATE());
	INSERT INTO refund_channelPartner(itemId,channelPartnerId,arrival)VALUES(@itemId,@foundChannelPartner,GETDATE());
	INSERT INTO refund_subDistributor(itemId,subDistributorId,arrival)VALUES(@itemId,@foundSubDistributor,GETDATE());
	INSERT INTO refund_distributor(itemId,distributorId,arrival)VALUES(@itemId,@foundDistributor,GETDATE());
	INSERT INTO refund_warehouse(itemId,warehouseId,arrival)VALUES(@itemId,@foundWarehouse,GETDATE());
	INSERT INTO refund_productionHouse(itemId,productionId,arrival)VALUES(@itemId,@foundProductionHouse,GETDATE());

END
GO
/****** Object:  StoredProcedure [dbo].[orderProduct]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[orderProduct](@warehouseId INT, @model VARCHAR(20), @quantity INT, @price DECIMAL(19,2))
AS
BEGIN
	----find prodcutionHouse
	DECLARE @productionId INT;
	EXECUTE @productionId = findProductionHouse @warehouseId 
	----call productionHouse.createItem
	EXECUTE createItems @quantity, @model, @productionId, @warehouseId, @price
END
GO
/****** Object:  StoredProcedure [dbo].[parentChannelPartnerItemCount]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[parentChannelPartnerItemCount](@storeId INT)
AS
BEGIN
	DECLARE @channelPartner INT;
	SELECT @channelPartner = store.channelPartnerId FROM store
	WHERE store.id = @storeId;

	WITH cte_itemChannelPartnerBridge
	AS
	(SELECT * FROM item AS i
	JOIN item_channelPartner AS i_c
	ON i.serialNumber = i_c.itemId
	WHERE i_c.channelPartnerId = @channelPartner
	AND i_c.departure IS NULL)

	SELECT 
	model,
	COUNT(*) AS [Quantity]
	FROM cte_itemChannelPartnerBridge
	GROUP BY model
END
GO
/****** Object:  StoredProcedure [dbo].[parentDistributorItemCount]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[parentDistributorItemCount](@subDistributorId INT)
AS
BEGIN
	DECLARE @distribId INT;
	SELECT @distribId = subDistributor.distributorId FROM subDistributor
	WHERE subDistributor.id = @subDistributorId;

	WITH cte_itemDistributorBridge
	AS
	(SELECT * FROM item AS i
	JOIN item_distributor AS i_d
	ON i.serialNumber = i_d.itemId
	WHERE i_d.distributorId = @distribId
	AND i_d.departure IS NULL)

	SELECT 
	model,
	COUNT(*) AS [Quantity]
	FROM cte_itemDistributorBridge
	GROUP BY model
END
GO
/****** Object:  StoredProcedure [dbo].[parentSubDistributorItemCount]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[parentSubDistributorItemCount](@channelPartnerId INT)
AS
BEGIN
	DECLARE @subDistribId INT;
	SELECT @subDistribId = channelPartner.subDistributorId FROM channelPartner
	WHERE channelPartner.id = @channelPartnerId;

	WITH cte_itemSubDistributorBridge
	AS
	(SELECT * FROM item AS i
	JOIN item_subDistributor AS i_s
	ON i.serialNumber = i_s.itemId
	WHERE i_s.subDistributorId = @subDistribId
	AND i_s.departure IS NULL)

	SELECT 
	model,
	COUNT(*) AS [Quantity]
	FROM cte_itemSubDistributorBridge
	GROUP BY model
END
GO
/****** Object:  StoredProcedure [dbo].[seeCustomers]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[seeCustomers](@storeId INT)
AS
BEGIN
	SELECT store.id AS [Store Number],
	store.name AS [Store Name], 
	customer.id AS [Customer ID],  
	item_customer.purchased AS [Purchased Date],
	item_customer.salePrice AS [Item Sell Price],
	item.serialNumber AS [Item Serial],
	item.model AS [Model]
	FROM store
	JOIN customer
	ON store.id = customer.storeId
	JOIN item_customer
	ON customer.id = item_customer.customerId
	JOIN item
	ON item_customer.itemId = item.serialNumber
	WHERE store.id = @storeId
END
GO
/****** Object:  StoredProcedure [dbo].[sellToCustomer]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sellToCustomer](@storeId INT, @model VARCHAR(20))
AS
BEGIN
	--find oldest of model
	DECLARE @itemToSell INT;
	SELECT @itemToSell = dbo.getOldestItemForDelivery(@storeId, @model, 'Store');

	--update
		UPDATE item_store
		SET item_store.departure = GETDATE()
		WHERE item_store.itemId = @itemToSell

		--get old price
		DECLARE @currentPrice DECIMAL(19,2);
		SELECT @currentPrice = dbo.getPrice(@itemToSell, 'Store');
		--old price * .08 + oldprice
		Declare @newPrice DECIMAL(19,2);
		SET @newPrice = @currentPrice * .08 + @currentPrice;

		--create customer
		DECLARE @customerInserted INT;
		INSERT INTO customer(storeId)VALUES(@storeId);
		--sell
		SET @customerInserted = SCOPE_IDENTITY();
		


		INSERT INTO item_customer(itemId,customerId,purchased, salePrice) VALUES(@itemToSell, @customerInserted, GETDATE(), @newPrice);
END
GO
/****** Object:  StoredProcedure [dbo].[storeItemCount]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[storeItemCount](@storeId INT)
AS
BEGIN
	WITH cte_storeItemBridge
	AS 
	(SELECT * FROM item AS i
	JOIN item_store AS i_s
	ON i.serialNumber = i_s.itemId
	WHERE i_s.storeId = @storeId
	)

	SELECT model, COUNT(*) AS [Quantity]
	FROM cte_storeItemBridge
	GROUP BY model
END
GO
/****** Object:  StoredProcedure [dbo].[storePickUpItems]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[storePickUpItems](@storeId INT, @model VARCHAR(20), @count INT)
AS
BEGIN
--subdistributor
	DECLARE @channelPId INT;
	SELECT @channelPId = channelPartnerId FROM store
	WHERE store.id = @storeId

	EXECUTE channelPartnerDelvierItems @channelPId, @model, @count, @storeId
	--subDistributorDelvierItems(@subDistributorId INT, @model VARCHAR(20), @count INT, @channelPartnerId INT)
	
END
GO
/****** Object:  StoredProcedure [dbo].[subDistributorDelvierItems]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[subDistributorDelvierItems](@subDistributorId INT, @model VARCHAR(20), @count INT, @channelPartnerId INT)
AS
BEGIN

	DECLARE @incrementCount INT;
	SET @incrementCount = @count;

	WHILE @incrementCount > 0
		BEGIN
			DECLARE @getItemId INT;
			SELECT @getItemId = dbo.getOldestItemForDelivery(@subDistributorId, @model, 'SubDistributor');
			--update item_distributor
			UPDATE item_subDistributor
			SET item_subDistributor.departure = GETDATE()
			WHERE item_subDistributor.itemId = @getItemId

			--get old price
			DECLARE @currentPrice DECIMAL(19,2);
			SELECT @currentPrice = dbo.getPrice(@getItemId, 'SubDistributor');
			--old price * .08 + oldprice
			DECLARE @newPrice DECIMAL(19,2);
			SET @newPrice = @currentPrice * .08 + @currentPrice;
			--PRINT 'currentprice'
			--PRINT @currentPrice
			--PRINT 'newprice'
			--PRINT @newPrice

			--channelPartner will have to pick up
			INSERT INTO item_channelPartner(itemId,channelPartnerId,arrival, currentPrice)VALUES(@getItemId,@channelPartnerId,GETDATE(), @newPrice);

			SELECT @incrementCount = @incrementCount - 1;
		END
END
GO
/****** Object:  StoredProcedure [dbo].[subDistributorItemCount]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[subDistributorItemCount](@subDistributorId INT)
AS
BEGIN
	WITH cte_subDistributorItemBridge
	AS 
	(SELECT * FROM item AS i
	JOIN item_subDistributor AS i_s
	ON i.serialNumber = i_s.itemId
	WHERE i_s.subDistributorId = @subDistributorId
	)

	SELECT model, COUNT(*) AS [Quantity]
	FROM cte_subDistributorItemBridge
	GROUP BY model
END
GO
/****** Object:  StoredProcedure [dbo].[subDistributorPickUpItems]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[subDistributorPickUpItems](@subDistributorId INT, @model VARCHAR(20), @count INT)
AS
BEGIN
	DECLARE @distriId INT;
	SELECT @distriId = distributorId FROM subDistributor
	WHERE subDistributor.id = @subDistributorId
	SELECT subDistributor.distributorId FROM subDistributor
	WHERE subDistributor.id = @subDistributorId

	EXECUTE distributorDelvierItems @distriId, @model, @count, @subDistributorId

	--distributorDelvierItems(@distributorId INT, @model VARCHAR(20), @count INT, @subDistributorID INT)
END
GO
/****** Object:  StoredProcedure [dbo].[TrackItem]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TrackItem] (@itemId INT)
AS
BEGIN
	--search production
	(SELECT * FROM ItemToProduction
	WHERE [Item Serial] = @itemId)
		UNION
	--search warehouse
	(SELECT * FROM ItemToWarehouse
	WHERE [Item Serial] = @itemId)
		UNION
	--search distributor
	SELECT * FROM ItemToDistributor
	WHERE [Item Serial] = @itemId
		UNION
	--search subDistributor
	SELECT * FROM ItemToSubDistributor
	WHERE [Item Serial] = @itemId
		UNION
	--search channelPartner
	SELECT * FROM ItemToChannelPartner
	WHERE [Item Serial] = @itemId
		UNION
	--search store
	SELECT * FROM ItemToStore
	WHERE [Item Serial] = @itemId
	ORDER BY [Arrival Date]

	--get customer info
	SELECT CONCAT('Customer id: ',[Customer ID]) AS [Customer Id], 
	[Item Serial],
	[Purchased Date], 
	[Item Buying Price]
	FROM [ItemToCustomer]
	WHERE [Item Serial] = @itemId

END
GO
/****** Object:  StoredProcedure [dbo].[trackItemDefect]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[trackItemDefect] (@itemId INT)
AS
BEGIN
	--search production
	(SELECT * FROM ItemToReturnProduction
	WHERE [Item Serial] = @itemId)
		UNION
	--search warehouse
	(SELECT * FROM ItemToReturnWarehouse
	WHERE [Item Serial] = @itemId)
		UNION
	--search distributor
	SELECT * FROM ItemToReturnDistributor
	WHERE [Item Serial] = @itemId
		UNION
	--search subDistributor
	SELECT * FROM ItemToReturnSubDistributor
	WHERE [Item Serial] = @itemId
		UNION
	--search channelPartner
	SELECT * FROM ItemToReturnChannelPartner
	WHERE [Item Serial] = @itemId
		UNION
	--search store
	SELECT * FROM ItemToReturnStore
	WHERE [Item Serial] = @itemId
	ORDER BY [Arrival Date]

	--get customer info
	SELECT CONCAT('Customer id: ',[Customer ID]) AS [Customer Id], 
	[Item Serial],
	[Purchased Date], 
	[Item Buying Price]
	FROM [ItemToCustomer]
	WHERE [Item Serial] = @itemId

END
GO
/****** Object:  StoredProcedure [dbo].[warehouseInitStock]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[warehouseInitStock](@warehouseId INT)
AS
BEGIN
	DECLARE @itemCount INT;
	SET @itemCount = 1000;
	DECLARE @price DECIMAL(19,2);

	WHILE @itemCount > 0
	BEGIN
		SELECT @itemCount = @itemCount - 1;
		--item
		INSERT INTO item(model, price) VALUES('MacBook', 2000.);
		--item_warehouse
		INSERT INTO item_warehouse(itemId, warehouseId, arrival) VALUES(SCOPE_IDENTITY(),@warehouseId, GETDATE());
	END
	SET @itemCount = 1000;
	WHILE @itemCount > 0
	BEGIN
		SELECT @itemCount = @itemCount - 1;
		--item
		INSERT INTO item(model, price) VALUES('IPhone', 1200.);
		--item_warehouse
		INSERT INTO item_warehouse(itemId, warehouseId, arrival) VALUES(SCOPE_IDENTITY(),@warehouseId, GETDATE());
	END
END
GO
/****** Object:  StoredProcedure [dbo].[warehouseItemCount]    Script Date: 2/4/2021 9:37:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[warehouseItemCount](@warehouseId INT)
AS
BEGIN
	WITH cte_itemWarehouseBridge
	AS
	(SELECT * FROM item AS i
	JOIN item_warehouse AS i_w
	ON i.serialNumber = i_w.itemId
	WHERE i_w.warehouseId = @warehouseId
	AND i_w.departure IS NULL
	)

	SELECT 
	model,
	COUNT(*) AS [Quantity]
	FROM cte_itemWarehouseBridge
	GROUP BY model
END;
GO
USE [master]
GO
ALTER DATABASE [AppleInc] SET  READ_WRITE 
GO
