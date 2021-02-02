-------------------------------------------------------------------------------------------distributorItemCount
ALTER PROCEDURE distributorItemCount(@distributorId INT)
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

EXECUTE distributorItemCount 1

EXECUTE findWarehouses 1
EXECUTE distributorPickUpItems 1, 'MacBook', 1, 1
DELETE FROM item_distributor
select * from item_distributor
select * from item_warehouse where item_warehouse.warehouseId = 1

--distributorPickUpItems(@distributorId INT, @model VARCHAR(20), @count INT, @warehouseId INT)
-------------------------------------------------------------------------------------------distributorItemCount
-------------------------------------------------------------------------------------------findWarehouses
ALTER PROCEDURE findWarehouses(@distributorId INT)
AS
BEGIN
	SELECT w.id AS [Warehouse Id] FROM warehouse AS w
	JOIN distributor AS d
	ON w.countryName = d.countryName
	WHERE d.id = @distributorId
END

EXECUTE findWarehouses 1
-------------------------------------------------------------------------------------------findWarehouses
-------------------------------------------------------------------------------------------findRandomWarehouse
ALTER PROCEDURE findRandomWarehouse(@distributorId INT)
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
-------------------------------------------------------------------------------------------findRandomWarehouse
-------------------------------------------------------------------------------------------findMySubDistributors
ALTER PROCEDURE findMySubDistributors(@distributorId INT)
AS
BEGIN
	SELECT s.id FROM subDistributor AS s
	JOIN distributor AS d
	ON s.distributorId = d.id
	WHERE d.id = @distributorId
END
-------------------------------------------------------------------------------------------findMySubDistributors
-------------------------------------------------------------------------------------------WarehouseItemCount
ALTER PROCEDURE warehouseItemCount(@warehouseId INT)
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

EXECUTE warehouseItemCount 2
select * FROM item_warehouse
-------------------------------------------------------------------------------------------WarehouseItemCount
-------------------------------------------------------------------------------------------distributorPickPickUpItems

--find warehouse with most items
ALTER PROCEDURE distributorPickUpItems(@distributorId INT, @model VARCHAR(20), @count INT, @warehouseId INT)
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

-------------------------------------------------------------------------------------------distributorPickUpItems
-------------------------------------------------------------------------------------------distributorDeliverItems
ALTER PROCEDURE distributorDelvierItems(@distributorId INT, @model VARCHAR(20), @count INT, @subDistributorID INT)
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
-------------------------------------------------------------------------------------------distributorDeliverItems
-------------------------------------------------------------------------------------------distributorRestock (INACTIVE)
--ALTER PROCEDURE distributorRestock(@distributorId INT, @model VARCHAR(20))
--AS
--BEGIN
--	DECLARE @countProduct INT;
--	SET @countProduct = (SELECT COUNT(*) FROM item AS i
--	JOIN item_distributor AS i_d
--	ON i.serialNumber = i_d.itemId
--	WHERE i_d.distributorId = @distributorId
--	AND i.model = @model
--	GROUP BY i_d.distributorId)
--
--	PRINT @countProduct
--	DECLARE @amountToOrder INT;
--	IF @countProduct < 800
--		BEGIN
--			SET @amountToOrder = 1000 - @countProduct;
--		END
--		--get warehouse id with most inv
--	DECLARE @findWarehouse INT;
--	EXECUTE @findWarehouse = findRandomWarehouse @distributorId;
--
--	PRINT 'findWarehouse ' + convert(varchar,@findWarehouse)
--	PRINT @amountToOrder
--	--get items
--	PRINT 'going to distributorpickupitems'
--	EXECUTE distributorPickUpItems @distributorId, @model, @amountToOrder, @findWarehouse
--	print 'AFTER PICKUP'
--END

--execute distributorRestock 1, 'MacBook'


--select* from item_warehouse WHERE departure IS NOT NULL
--alter TABLE  item_warehouse
--ADD  departure DATETIME
--DELETE FROM item_distributor

--select * from item_distributor
--select * from item_warehouse where item_warehouse.warehouseId = 1
-------------------------------------------------------------------------------------------distributorRestock (INACTIVE)



DECLARE @distrId INT;
SET @distrId = 2;
DECLARE @modelName VARCHAR(20);
SET @modelName = 'MacBook';
DECLARE @quant INT;
SET @quant = 500;
DECLARE @warehouseId INT

--get my item count
EXECUTE distributorItemCount @distrId;

--find my warehouses
EXECUTE findWarehouses @distrId;
--choose an id
SET @warehouseId = 5

--check stock of that warehouse
EXECUTE warehouseItemCount @warehouseId;

--pickup items for that wh
EXECUTE distributorPickUpItems @distrId, @modelName, @quant, @warehouseId

--show my new item count
EXECUTE distributorItemCount @distrId;

--show warehouse new item count
EXECUTE warehouseItemCount @warehouseId;

--fetch my underlings
EXECUTE findMySubDistributors @distrId;

--keep this number for next step (2)