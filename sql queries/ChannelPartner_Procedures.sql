-------------------------------------------------------------------------------------------channelPartnerItemCount
ALTER PROCEDURE channelPartnerItemCount(@channelPartnerId INT)
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
-------------------------------------------------------------------------------------------channelPartnerItemCount

-------------------------------------------------------------------------------------------findMyStores
CREATE PROCEDURE findMyStores(@channelPartnerId INT)
AS
BEGIN
	SELECT s.id FROM store AS s
	JOIN channelPartner AS c
	ON s.channelPartnerId = c.id
	WHERE c.id = @channelPartnerId
END
-------------------------------------------------------------------------------------------findMyStores
-------------------------------------------------------------------------------------------channelPartnerPickPickUpItems
ALTER PROCEDURE channelPartnerPickUpItems(@channelPartnerId INT, @model VARCHAR(20), @count INT)
AS
BEGIN
--subdistributor
	DECLARE @subDistriId INT;
	SELECT @subDistriId = subDistributorId FROM channelPartner
	WHERE channelPartner.id = @channelPartnerId

	EXECUTE subDistributorDelvierItems @subDistriId, @model, @count, @channelPartnerId
	--subDistributorDelvierItems(@subDistributorId INT, @model VARCHAR(20), @count INT, @channelPartnerId INT)
	
END
-------------------------------------------------------------------------------------------channelPartnerPickUpItems
-------------------------------------------------------------------------------------------channelPartnerDeliverItems
ALTER PROCEDURE channelPartnerDelvierItems(@channelPartnerId INT, @model VARCHAR(20), @count INT, @storeId INT)
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
-------------------------------------------------------------------------------------------channelPartnerDeliverItems
-------------------------------------------------------------------------------------------parentDistributorItemCount
ALTER PROCEDURE parentSubDistributorItemCount(@channelPartnerId INT)
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
-------------------------------------------------------------------------------------------parentDistributorItemCount

DECLARE @chanPartId INT;
SET @chanPartId = 394971;
DECLARE @model VARCHAR(20);
SET @model = 'MacBook';
DECLARE @quant INT;
SET @quant = 300;

--get my inventory
EXECUTE channelPartnerItemCount @chanPartId;

--get subDistributor inventory
EXECUTE parentSubDistributorItemCount @chanPartId;

--pickup inventory
EXECUTE channelPartnerPickUpItems @chanPartId, @model, @quant;

--get my inventory
EXECUTE channelPartnerItemCount @chanPartId;

--get subDistributor inventory
EXECUTE parentSubDistributorItemCount @chanPartId;

--find underlings
EXECUTE findMyStores @chanPartId

--store one (15)