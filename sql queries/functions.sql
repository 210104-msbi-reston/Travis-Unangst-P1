
ALTER FUNCTION getOldestItemForPickup(@pickupLocationId INT, @model VARCHAR(20), @caller VARCHAR(20))
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

ALTER FUNCTION getOldestItemForDelivery(@userId INT, @model VARCHAR(20), @caller VARCHAR(20))
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

ALTER FUNCTION getPrice(@itemId INT, @location VARCHAR(20))
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