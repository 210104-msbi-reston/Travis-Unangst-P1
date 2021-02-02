use appleInc
ALTER TABLE store
ADD name VARCHAR(50);
ALTER TABLE channelPartner
DROP COLUMN fName,lName

ALTER TABLE subDistributor
DROP COLUMN fName,lName
	

	DECLARE @distributorCount INT;
	SET @distributorCount = 



	DECLARE @subDistributorCount INT;
	SET @subDistributorCount = (SELECT  FLOOR(RAND() * (3 - 1+1) +1)); -- 1-3
	WHILE @subDistributorCount > 0
		BEGIN
			--id
			DECLARE @subDistributorId INT;
			SET @subDistributorId = @subDistributorCount + 1;
			--FK
			DECLARE @subDistributorFk INT;
			SET @subDistributorFk = @distributorId;
			--insert
			INSERT INTO subDistributor(id, distributorId) VALUES(@subDistributorId, @subDistributorFk);
			

			-----------------------------------------------------------channelPartner
			DECLARE @channelPartnerCount INT;
			SET @channelPartnerCount = (SELECT  FLOOR(RAND() * (7 - 5+1) +5)); -- 5-7
			WHILE @channelPartnerCount > 0
				BEGIN
					--id
					DECLARE @channelPartnerId INT;
					SET @channelPartnerid = @channelPartnerCount + 1;
					--FK
					DECLARE @channelPartnerFk INT;
					SET @channelPartnerFk = @subDistributorId;
					--insert
					INSERT INTO channelPartner(id,subDistributorId) VALUES(@channelPartnerId, @channelPartnerFk);

				-----------------------------------------------------------store
						DECLARE @storeCount INT;
						SET @storeCount = (SELECT  FLOOR(RAND() * (4+1) +1)); --1-4
						WHILE @storeCount > 0 
							BEGIN
								-- id
								DECLARE @storeId INT;
								SET @storeId = @storeCount + 1;
								-- FK
								DECLARE @storeFk INT;
								SET @storeFk = @channelPartnerId;
								-- name
								DECLARE @storeName VARCHAR(50);
								IF (@storeCount = 4)
									SELECT @storeName = 'Toms';
								ELSE IF(@storeCount = 3)
									SELECT @storeName = 'Tonys';
								ELSE IF (@storeCount = 2)
									SELECT @storeName = 'Tiffanys';
								ELSE
									SELECT @storeName = 'Joeys';
								--insert
								INSERT INTO store(id,channelPartnerId,name) VALUES(@storeId,@storeFk,@storeName);   -----------------------------------------------------------------
								-- increment
								SELECT @storeCount = @StoreCount -1;
							END
						--increment
						SELECT @channelPartnerCount = @channelPartnerCount - 1
				END
			--increment
			SELECT @subDistributorCount = @subDistributorCount - 1;
		END

	/*

	create procedure newflight
as
begin
declare @fno int = 0
declare @airlines varchar(20)
declare @source varchar(20)
declare @destination varchar(20)
declare @cost int
declare @randmcost int
while @fno < 900000
begin
	select @fno = @fno + 1
	if @fno % 2 = 0
	begin
		
		set @randmcost = (select  RAND() * 50000)
			if @randmcost < 20000
				begin
					set @cost = @randmcost
					set @source = 'Mumbai'
					set @destination = 'Nagpur'
					set @airlines = 'Air India'
				end
			else
				begin
					set @cost =(select  RAND() * 40000)
					set @source = 'Pune'
					set @destination = 'Mumbai'
					set @airlines = 'Indigo'
				end
					insert into flighttable values(@fno,@airlines,@source,@destination,@cost)	
			end 
	else
	begin
		if @randmcost < 20000
				begin
					set @cost = @randmcost
					set @source = 'Kochin'
					set @destination = 'Pune'
					set @airlines = 'Spice Jet'
				end
			else
				begin
					set @cost =(select  RAND() * 40000)
					set @source = 'Banglore'
					set @destination = 'Chennai'
					set @airlines = 'Jet Airways'
				end
					insert into flighttable values(@fno,@airlines,@source,@destination,@cost)	
			end 
	end

end


exec newflight
*/



-------------------------------------------------------------------------------------------PRODUCTION
CREATE PROCEDURE createProduction(@continent NVARCHAR(50))
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

EXECUTE createProduction ?

SELECT * FROM productionHouse

-------------------------------------------------------------------------------------------PRODUCTION
-------------------------------------------------------------------------------------------WAREHOUSE
CREATE PROCEDURE createWarehouse(@country NVARCHAR(50))
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

EXECUTE createWarehouse ?

SELECT * FROM warehouse
-------------------------------------------------------------------------------------------WAREHOUSE
-------------------------------------------------------------------------------------------DISTRIBUTOR
CREATE PROCEDURE createDistributor(@country NVARCHAR(50))
AS
BEGIN
	INSERT INTO distributor(countryName) VALUES(@country);
END
EXECUTE createDistributor ?
SELECT * FROM distributor
-------------------------------------------------------------------------------------------DISTRIBUTOR
-------------------------------------------------------------------------------------------SUBDISTRIBUTOR
CREATE PROCEDURE createSubDistributor(@distributorId INT)
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

EXECUTE createSubDistributor ?
SELECT * FROM subDistributor
-------------------------------------------------------------------------------------------SUBDISTRIBUTOR
-------------------------------------------------------------------------------------------CHANNELPARTNER
CREATE PROCEDURE createChannelPartner(@subDistributorId INT)
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

EXECUTE createChannelPartner ?
SELECT * FROM channelPartner
-------------------------------------------------------------------------------------------CHANNELPARTNER
-------------------------------------------------------------------------------------------STORE
CREATE PROCEDURE createStore(@channelPartnerId INT)
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

EXECUTE createStore ?
SELECT * FROM store;
-------------------------------------------------------------------------------------------STORE


-------------------------------------------------------------------------------------------WarehouseInitStock
CREATE PROCEDURE warehouseInitStock(@warehouseId INT)
AS
BEGIN
	DECLARE
	EXECUTE createItems amountToCreate INT, @model VARCHAR(20), @productionId INT, @warehouseId INT, @price DECIMAL(19,2))
	
	
	
	
	
	DECLARE @itemCount INT;
	SET @itemCount = 1000;
	--DECLARE @price DECIMAL(19,2);

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

EXECUTE warehouseInitStock ?

EXECUTE warehouseItemCount 1
-------------------------------------------------------------------------------------------WarehouseInitStock
-------------------------------- ssis tasks
select 
warehouse.id as [warehouse id],
productionhouse.id as [production id]
from country
join continent
on country.continentname = continent.name
join warehouse
on warehouse.countryName = country.name
join productionhouse
on productionhouse.continentname = continent.name
order by warehouse.id asc



--ALTER PROCEDURE createItems(@amountToCreate INT, @model NVARCHAR(20), @productionId INT, @warehouseId INT, @price DECIMAL(19,2))

EXECUTE createItems 400, 'MacBook', ?, ?, 2000.00 ;
EXECUTE createItems 350, 'iPhone', ?, ?, 1200.00 ;


EXECUTE warehouseItemCount 100

select * from item_productionHouse
select * from item_warehouse

delete from item_productionHouse
-------------------------------- ssis tasks





CREATE TABLE refund_store(
		id INT PRIMARY KEY IDENTITY(1,1),
		itemId INT FOREIGN KEY REFERENCES item(serialNumber),
		storeId INT FOREIGN KEY REFERENCES store(id),
		arrival DATETIME DEFAULT GETDATE(),
		departure DATETIME
	)
	CREATE TABLE refund_channelPartner(
		id INT PRIMARY KEY IDENTITY(1,1),
		itemId INT FOREIGN KEY REFERENCES item(serialNumber),
		channelPartnerId INT FOREIGN KEY REFERENCES channelPartner(id),
		arrival DATETIME DEFAULT GETDATE(),
		departure DATETIME
	)
	CREATE TABLE refund_subDistributor(
		id INT PRIMARY KEY IDENTITY(1,1),
		itemId INT FOREIGN KEY REFERENCES item(serialNumber),
		subDistributorId INT FOREIGN KEY REFERENCES subDistributor(id),
		arrival DATETIME DEFAULT GETDATE(),
		departure DATETIME
	)
	CREATE TABLE refund_distributor(
		id INT PRIMARY KEY IDENTITY(1,1),
		itemId INT FOREIGN KEY REFERENCES item(serialNumber),
		distributorId INT FOREIGN KEY REFERENCES distributor(id),
		arrival DATETIME DEFAULT GETDATE(),
		departure DATETIME
	)
	CREATE TABLE refund_warehouse(
		id INT PRIMARY KEY IDENTITY(1,1),
		itemId INT FOREIGN KEY REFERENCES item(serialNumber),
		warehouseId INT FOREIGN KEY REFERENCES warehouse(id),
		arrival DATETIME DEFAULT GETDATE(),
		departure DATETIME
	)
	CREATE TABLE refund_productionHouse(
		id INT PRIMARY KEY IDENTITY(1,1),
		itemId INT FOREIGN KEY REFERENCES item(serialNumber),
		productionHouseId INT FOREIGN KEY REFERENCES productionHouse(id),
		arrival DATETIME DEFAULT GETDATE(),
	)

ALTER TABLE refund_store DROP COLUMN departure
ALTER TABLE refund_channelPartner DROP COLUMN departure
ALTER TABLE refund_subDistributor DROP COLUMN departure
ALTER TABLE refund_Distributor DROP COLUMN departure
ALTER TABLE refund_Warehouse DROP COLUMN departure