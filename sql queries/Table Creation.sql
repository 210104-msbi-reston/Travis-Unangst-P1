CREATE DATABASE AppleInc;
USE AppleInc;

CREATE TABLE apple(
	id INT PRIMARY KEY IDENTITY(1,1)
);

CREATE TABLE continent(
	name VARCHAR(15) PRIMARY KEY,
	appleId INT FOREIGN KEY REFERENCES apple(id)
);

CREATE TABLE productionHouse(
	id INT PRIMARY KEY IDENTITY(1,1),
	continentName VARCHAR(15) FOREIGN KEY REFERENCES continent(name),
	tax DECIMAL(3,2) DEFAULT .1
);

CREATE TABLE country(
	name VARCHAR(20) PRIMARY KEY,
	continentName VARCHAR(15) FOREIGN KEY REFERENCES continent(name)
);

CREATE TABLE warehouse(
	id INT PRIMARY KEY IDENTITY(1,1),
	countryName VARCHAR(20) FOREIGN KEY REFERENCES country(name)
);

CREATE TABLE distributor(
	id INT PRIMARY KEY IDENTITY(1,1),
	countryName VARCHAR(20) FOREIGN KEY REFERENCES country(name),
	fName VARCHAR(20),
	lName VARCHAR(20)
);

CREATE TABLE subDistributor(
	id INT PRIMARY KEY IDENTITY(1,1),
	distributorId INT FOREIGN KEY REFERENCES distributor(id),
	fName VARCHAR(20),
	lName VARCHAR(20)
);

CREATE TABLE channelPartner(
	id INT PRIMARY KEY IDENTITY(1,1),
	subDistributorId INT FOREIGN KEY REFERENCES subDistributor(id),
	fName VARCHAR(20),
	lName VARCHAR(20)
);

CREATE TABLE store(
	id INT PRIMARY KEY IDENTITY(1,1),
	channelPartnerId INT FOREIGN KEY REFERENCES channelPartner(id),
	zone VARCHAR(20)
);

CREATE TABLE customer(
	pasportId INT PRIMARY KEY,
	storeId INT FOREIGN KEY REFERENCES store(id)
);

--ALTER TABLE customer
--ADD storeId INT FOREIGN KEY REFERENCES store(id);

CREATE TABLE item(
	serialNumber INT PRIMARY KEY IDENTITY(1,1),
	model VARCHAR(20),
	price DECIMAL(19,2)
);

CREATE TABLE item_productionHouse(
	id INT PRIMARY KEY IDENTITY(1,1),
	itemId INT FOREIGN KEY REFERENCES item(serialNumber),
	productionId INT FOREIGN KEY REFERENCES productionHouse(id),
	birth DATETIME DEFAULT GETDATE(),
	departure DATETIME
);
--ALTER TABLE item_productionHouse
--ADD birth DATETIME DEFAULT GETDATE();
--ALTER TABLE item_productionHouse
--ADD departure DATETIME;

CREATE TABLE item_warehouse(
	id INT PRIMARY KEY IDENTITY(1,1),
	itemId INT FOREIGN KEY REFERENCES item(serialNumber),
	warehouseId INT FOREIGN KEY REFERENCES warehouse(id),
	arrival DATETIME DEFAULT GETDATE(),
	departure DATETIME
);
--ALTER TABLE item_warehouse
--ALTER birth DATETIME DEFAULT GETDATE();
--sp_rename 'item_warehouse.birth', 'arrival', 'COLUMN';
--ALTER TABLE item_warehouse
--ADD departure DATETIME;

CREATE TABLE item_distributor(
	id INT PRIMARY KEY IDENTITY(1,1),
	itemId INT FOREIGN KEY REFERENCES item(serialNumber),
	distributorId INT FOREIGN KEY REFERENCES distributor(id),
	arrival DATETIME DEFAULT GETDATE(),
	departure DATETIME
	--distributionCharge DECIMAL(19,2) DEFAULT .08
);
--ALTER TABLE item_distributor
--ADD arrival DATETIME DEFAULT GETDATE(), departure DATETIME

CREATE TABLE item_subDistributor(
	id INT PRIMARY KEY IDENTITY(1,1),
	itemId INT FOREIGN KEY REFERENCES item(serialNumber),
	subDistributorId INT FOREIGN KEY REFERENCES subDistributor(id),
	arrival DATETIME DEFAULT GETDATE(),
	departure DATETIME
	--distributionCharge DECIMAL(19,2) DEFAULT .08
);
--ALTER TABLE item_subDistributor
--ADD arrival DATETIME DEFAULT GETDATE(), departure DATETIME

CREATE TABLE item_channelPartner(
	id INT PRIMARY KEY IDENTITY(1,1),
	itemId INT FOREIGN KEY REFERENCES item(serialNumber),
	channelPartnerId INT FOREIGN KEY REFERENCES channelPartner(id),
	arrival DATETIME DEFAULT GETDATE(),
	departure DATETIME
	--distributionCharge DECIMAL(19,2) DEFAULT .08
);
--ALTER TABLE item_channelPartner
--ADD arrival DATETIME DEFAULT GETDATE(), departure DATETIME

CREATE TABLE item_store(
	id INT PRIMARY KEY IDENTITY(1,1),
	itemId INT FOREIGN KEY REFERENCES item(serialNumber),
	storeId INT FOREIGN KEY REFERENCES store(id),
	arrival DATETIME DEFAULT GETDATE(),
	departure DATETIME
	--distributionCharge DECIMAL(19,2) DEFAULT .08
);
--ALTER TABLE item_store
--ADD arrival DATETIME DEFAULT GETDATE(), departure DATETIME

CREATE TABLE item_customer(
	id INT PRIMARY KEY IDENTITY(1,1),
	itemId INT FOREIGN KEY REFERENCES item(serialNumber),
	customerId INT FOREIGN KEY REFERENCES customer(pasportId),
	purchased DATETIME DEFAULT GETDATE(),
	--salePrice DECIMAL(19,2)
);
