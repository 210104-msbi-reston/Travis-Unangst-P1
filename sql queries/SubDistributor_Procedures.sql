
-------------------------------------------------------------------------------------------subDistributorItemCount
CREATE PROCEDURE subDistributorItemCount(@subDistributorId INT)
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

EXECUTE subDistributorItemCount 1

-------------------------------------------------------------------------------------------subDistributorItemCount
-------------------------------------------------------------------------------------------findMyChannelPartners
ALTER PROCEDURE findMyChannelPartners(@subDistributorId INT)
AS
BEGIN
	SELECT c.id FROM channelPartner AS c
	JOIN subDistributor AS s
	ON c.subDistributorId = s.id
	WHERE s.id = @subDistributorId
END
-------------------------------------------------------------------------------------------findMyChannelPartners

-------------------------------------------------------------------------------------------subDistributorPickPickUpItems 
ALTER PROCEDURE subDistributorPickUpItems(@subDistributorId INT, @model VARCHAR(20), @count INT)
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


-------------------------------------------------------------------------------------------subDistributorPickUpItems 
-------------------------------------------------------------------------------------------subDistributorDeliverItems
ALTER PROCEDURE subDistributorDelvierItems(@subDistributorId INT, @model VARCHAR(20), @count INT, @channelPartnerId INT)
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
-------------------------------------------------------------------------------------------subDistributorDeliverItems
-------------------------------------------------------------------------------------------parentDistributorItemCount
ALTER PROCEDURE parentDistributorItemCount(@subDistributorId INT)
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
-------------------------------------------------------------------------------------------parentDistributorItemCount



DECLARE @subDistId INT
SET @subDistId = 2
DECLARE @model VARCHAR(20);
SET @model = 'MacBook';
DECLARE @quant INT;
SET @quant = 400;

--show my items
EXECUTE subDistributorItemCount @subDistId

--show distributor's items
EXECUTE parentDistributorItemCount @subDistId

--request new items
EXECUTE subDistributorPickUpItems @subDistId, @model, @quant

--show my items
EXECUTE subDistributorItemCount @subDistId

--reshow distributors items
EXECUTE parentDistributorItemCount @subDistId;

--find underlings
EXECUTE findMyChannelPartners @subDistId

--save id number for next step (394971)