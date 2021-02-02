ALTER VIEW [ItemToProduction] 
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

ALTER VIEW [ItemToWarehouse] 
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

ALTER VIEW [ItemToDistributor] 
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

ALTER VIEW [ItemToSubDistributor]
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

ALTER VIEW [ItemToChannelPartner]
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

ALTER VIEW [ItemToStore]
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

ALTER VIEW [ItemToCustomer]
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

---------------------------------------------------------------------- item - table
---------------------------------------------------------------------- item - return table
--CHANGE THESE TO itemtoRETURNproduction
CREATE VIEW [ItemToReturnProduction] 
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

CREATE VIEW [ItemToReturnWarehouse] 
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

CREATE VIEW [ItemToReturnDistributor] 
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

CREATE VIEW [ItemToReturnSubDistributor]
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

CREATE VIEW [ItemToReturnChannelPartner]
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

CREATE VIEW [ItemToReturnStore]
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
