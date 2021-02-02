ALTER TRIGGER tr_warehouseNotify
ON item_warehouse
AFTER UPDATE, INSERT
AS
BEGIN

	--vars
	DECLARE @insertedWarehouseId INT;
	SET @insertedWarehouseId = (SELECT warehouseId FROM INSERTED);
	DECLARE @insertedItemId INT;
	SET @insertedItemId = (SELECT itemId FROM INSERTED);

	DECLARE @insertedModel VARCHAR(20);
	SET @insertedModel =(SELECT DISTINCT model FROM item where item.serialNumber = @insertedItemId);
	--vars

	--find remaining products
	DECLARE @countProduct INT;

	(SELECT @countProduct = count(*) FROM item AS i
	JOIN item_warehouse AS i_w
	ON i.serialNumber = i_w.itemId
	WHERE i_w.warehouseId = @insertedWarehouseId
	AND i.model = @insertedModel
	GROUP BY i_w.warehouseId)
		

	PRINT 'warehouse notify'
	DECLARE @Msg VARCHAR(300)= CONCAT('# ', @insertedWarehouseId, ' ', @insertedModel, ' count: ', @countProduct);
	PRINT @Msg;
END
-------------------------------------------------------------------------------------------warehouseNotify
-------------------------------------------------------------------------------------------distributorNotify
ALTER TRIGGER tr_distributorNotify
ON item_distributor
AFTER UPDATE, INSERT
AS
BEGIN

	--vars
	DECLARE @insertedDistributorId INT;
	SET @insertedDistributorId = (SELECT distributorId FROM INSERTED);
	DECLARE @insertedItemId INT;
	SET @insertedItemId = (SELECT itemId FROM INSERTED);

	DECLARE @insertedModel VARCHAR(20);
	SET @insertedModel =(SELECT DISTINCT model FROM item where item.serialNumber = @insertedItemId);
	--vars

	--find remaining products
	DECLARE @countProduct INT;

	SELECT @countProduct = count(*) FROM item AS i
	JOIN item_distributor AS i_d
	ON i.serialNumber = i_d.itemId
	WHERE i_d.distributorId = @insertedDistributorId
	AND i.model = @insertedModel
	GROUP BY i_d.distributorId
		

	PRINT 'distributor notify'
	DECLARE @Msg VARCHAR(300)= CONCAT('# ', @insertedDistributorId, ' ', @insertedModel, ' count: ', @countProduct);
	PRINT @Msg;

END
-------------------------------------------------------------------------------------------distributorNotify
-------------------------------------------------------------------------------------------subDistributorNotify
ALTER TRIGGER tr_subDistributorNotify
ON item_subDistributor
AFTER UPDATE, INSERT
AS
BEGIN

	--vars
	DECLARE @insertedSubDistributorId INT;
	SET @insertedSubDistributorId = (SELECT subDistributorId FROM INSERTED);
	DECLARE @insertedItemId INT;
	SET @insertedItemId = (SELECT itemId FROM INSERTED);

	DECLARE @insertedModel VARCHAR(20);
	SET @insertedModel =(SELECT DISTINCT model FROM item where item.serialNumber = @insertedItemId);
	--vars

	--find remaining products
	DECLARE @countProduct INT;

	(SELECT @countProduct = count(*) FROM item AS i
	JOIN item_subDistributor AS i_s
	ON i.serialNumber = i_s.itemId
	WHERE i_s.subDistributorId = 2 
	AND i.model = @insertedModel
	GROUP BY i_s.subDistributorId)
		
	PRINT 'subDistributor notify'
	DECLARE @Msg VARCHAR(300)= CONCAT('# ', @insertedSubDistributorId, ' ', @insertedModel, ' count: ', @countProduct);
	PRINT @Msg;
END
-------------------------------------------------------------------------------------------subDistributorNotify
-------------------------------------------------------------------------------------------channelPartnerNotify
ALTER TRIGGER tr_channelPartnerNotify
ON item_channelPartner
AFTER UPDATE, INSERT
AS
BEGIN

	--vars
	DECLARE @insertedChannelPartnerId INT;
	SET @insertedChannelPartnerId = (SELECT channelPartnerId FROM INSERTED);
	DECLARE @insertedItemId INT;
	SET @insertedItemId = (SELECT itemId FROM INSERTED);

	DECLARE @insertedModel VARCHAR(20);
	SET @insertedModel =(SELECT DISTINCT model FROM item where item.serialNumber = @insertedItemId);
	--vars

	--find remaining products
	DECLARE @countProduct INT;

	(SELECT @countProduct = count(*) FROM item AS i
	JOIN item_channelPartner AS i_c
	ON i.serialNumber = i_c.itemId
	WHERE i_c.channelPartnerId = 2 
	AND i.model = @insertedModel
	GROUP BY i_c.channelPartnerId)
		
	PRINT 'channelPartner notify'
	DECLARE @Msg VARCHAR(300)= CONCAT('# ', @insertedChannelPartnerId, ' ', @insertedModel, ' count: ', @countProduct);
	PRINT @Msg;
END
-------------------------------------------------------------------------------------------channelPartnerNotify
-------------------------------------------------------------------------------------------storeNotify
ALTER TRIGGER tr_storeNotify
ON item_store
AFTER UPDATE, INSERT
AS
BEGIN

	--vars
	DECLARE @insertedStoreId INT;
	SET @insertedStoreId = (SELECT storeId FROM INSERTED);
	DECLARE @insertedItemId INT;
	SET @insertedItemId = (SELECT itemId FROM INSERTED);

	DECLARE @insertedModel VARCHAR(20);
	SET @insertedModel =(SELECT DISTINCT model FROM item where item.serialNumber = @insertedItemId);
	--vars

	--find remaining products
	DECLARE @countProduct INT;

	(SELECT @countProduct = count(*) FROM item AS i
	JOIN item_store AS i_s
	ON i.serialNumber = i_s.itemId
	WHERE i_s.storeId = 2 
	AND i.model = @insertedModel
	GROUP BY i_s.storeId)
		
	PRINT 'store notify'
	DECLARE @Msg VARCHAR(300)= CONCAT('# ', @insertedStoreId, ' ', @insertedModel, ' count: ', @countProduct);
	PRINT @Msg;

END
-------------------------------------------------------------------------------------------storeNotify


	--if below
	IF @countProduct < 500
		DECLARE @amountToOrder INT;
		SET @amountToOrder = 1000 - @countProduct;
		--order 1000 - @countProduct of @insertedModel
		EXECUTE orderProduct @insertedWarehouseId, @insertedModel, @amountToOrder, NULL
		