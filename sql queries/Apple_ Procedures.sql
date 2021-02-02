-----------------------------------------------------------------------------issueDefect
ALTER PROCEDURE issueDefect(@itemId INT)
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
	WHERE item_productionHouse.id = @itemId;

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
-----------------------------------------------------------------------------issueDefect

-----------------------------------------------------------------------------issueRefund
ALTER PROCEDURE issueRefund(@itemId INT)
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
-----------------------------------------------------------------------------issueRefund
-----------------------------------------------------------------------------trackItem
ALTER PROCEDURE trackItem (@itemId INT)
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
-----------------------------------------------------------------------------trackItem
-----------------------------------------------------------------------------trackItemDefect

--CHANGE THESE TO itemtoRETURNproduction
ALTER PROCEDURE trackItemDefect (@itemId INT)
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
-----------------------------------------------------------------------------trackItemDefect

DECLARE @trackItemId INT;
SET @trackItemId = 5445338;

--track item
EXECUTE trackItem @trackItemId;

--track item defect
EXECUTE trackItemDefect @trackItemId;

--issue itemdefect
EXECUTE issueDefect @trackItemId;

--track item defect
EXECUTE trackItemDefect @trackItemId;

--track item 
EXECUTE trackItem @trackItemId;





delete from refund_store
delete from refund_channelPartner
delete from refund_subDistributor
delete from refund_distributor
delete from refund_warehouse
delete from refund_productionHouse

UPDATE  item_productionHouse
SET item_productionHouse.productionId = 10
WHERE item_productionHouse.itemId = 5447697 AND item_productionHouse.departure IS NULL