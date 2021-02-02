-------------------------------------------------------------------------------------------storeItemCount
CREATE PROCEDURE storeItemCount(@storeId INT)
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
-------------------------------------------------------------------------------------------storeItemCount

-------------------------------------------------------------------------------------------findMyCustomers
CREATE PROCEDURE findMyCustomers(@storeId INT)
AS
BEGIN
	SELECT c.id FROM customer AS c
	JOIN store AS s
	ON c.storeId = s.id
	WHERE s.id = @storeId
END
-------------------------------------------------------------------------------------------findMyCustomers
-------------------------------------------------------------------------------------------sellToCustomer
ALTER PROCEDURE sellToCustomer(@storeId INT, @model VARCHAR(20))
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

-------------------------------------------------------------------------------------------sellToCustomer
-------------------------------------------------------------------------------------------seePreviousCustomers
ALTER PROCEDURE seeCustomers(@storeId INT)
AS
BEGIN
	SELECT 
	store.id AS [Store Number],
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
-------------------------------------------------------------------------------------------seePreviousCustomers
-------------------------------------------------------------------------------------------parentChannelPartnerItemCount
ALTER PROCEDURE parentChannelPartnerItemCount(@storeId INT)
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
-------------------------------------------------------------------------------------------parentChannelPartnerItemCount
-------------------------------------------------------------------------------------------storePickPickUpItems
ALTER PROCEDURE storePickUpItems(@storeId INT, @model VARCHAR(20), @count INT)
AS
BEGIN
	DECLARE @channelPId INT;
	SELECT @channelPId = channelPartnerId FROM store
	WHERE store.id = @storeId

	EXECUTE channelPartnerDelvierItems @channelPId, @model, @count, @storeId
	--subDistributorDelvierItems(@subDistributorId INT, @model VARCHAR(20), @count INT, @channelPartnerId INT)
	
END
-------------------------------------------------------------------------------------------storePickUpItems


DECLARE @myStoreId INT;
SET @myStoreId = 15;
DECLARE @MyModel VARCHAR(20);
SET @myModel = 'MacBook';
DECLARE @quant INT;
SET @quant = 100;

--see my inventory
EXECUTE storeItemCount @myStoreId;

--get channelPartner inventory
EXECUTE parentChannelPartnerItemCount @myStoreId;

--pickup inventory
EXECUTE storePickUpItems @myStoreId, @myModel, @quant;

--see my inventory
EXECUTE storeItemCount @myStoreId;

--get channelPartner inventory
EXECUTE parentChannelPartnerItemCount @myStoreId;



DECLARE @myStoreId INT;
SET @myStoreId = 15;
DECLARE @MyModel VARCHAR(20);
SET @myModel = 'MacBook';
--find customers
EXECUTE seeCustomers @myStoreId;

--sell item to a customer
EXECUTE sellToCustomer @myStoreId, @myModel;

--find customers
EXECUTE seeCustomers @myStoreId;

--record item serial(5445338)