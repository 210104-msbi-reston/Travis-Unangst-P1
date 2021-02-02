-------------------------------------------------------------------------------------------findProductionHouses
CREATE PROCEDURE findProductionHouses(@warehouseId INT)
AS
BEGIN
	select 
	warehouse.id as [warehouse id],
	country.name as [country name],
	continent.name as [continent name],
	productionhouse.id as [production id]
	from country
	join continent
	on country.continentname = continent.name
	join warehouse
	on warehouse.countryName = country.name
	join productionhouse
	on productionhouse.continentname = continent.name
	where warehouse.id = @warehouseId
	order by productionhouse.id asc
END
-------------------------------------------------------------------------------------------findProductionHouses
-------------------------------------------------------------------------------------------findProductionHousesFunction
ALTER PROCEDURE findProductionHouse(@warehouseId INT)
AS
BEGIN
	DECLARE @result INT;

	SELECT 
	TOP(1)
	@result = productionhouse.id
	FROM country
	JOIN continent
	ON country.continentname = continent.name
	JOIN warehouse
	ON warehouse.countryName = country.name
	JOIN productionhouse
	ON productionhouse.continentname = continent.name
	WHERE warehouse.id = @warehouseId
	ORDER BY NEWID()
	
	RETURN @result;
END
-------------------------------------------------------------------------------------------findProductionHousesFunction

-------------------------------------------------------------------------------------------warehouseItemCount
CREATE PROCEDURE warehouseItemCount(@warehouseId INT)
AS
BEGIN
	WITH cte_warehouseItemBridge
	AS 
	(SELECT * FROM item AS i
	JOIN item_warehouse AS i_w
	ON i.serialNumber = i_w.itemId
	WHERE i_w.warehouseId = @warehouseId
	)

	SELECT model, COUNT(*) AS [Quantity]
	FROM cte_warehouseItemBridge
	GROUP BY model
END

EXECUTE warehouseItemCount 1
-------------------------------------------------------------------------------------------warehouseItemCount
-------------------------------------------------------------------------------------------warehouseorderProdcut
CREATE PROCEDURE orderProduct(@warehouseId INT, @model VARCHAR(20), @quantity INT, @price DECIMAL(19,2))
AS
BEGIN
	----find prodcutionHouse
	DECLARE @productionId INT;
	EXECUTE @productionId = findProductionHouse @warehouseId 
	----call productionHouse.createItem
	EXECUTE createItems @quantity, @model, @productionId, @warehouseId, @price
END
-------------------------------------------------------------------------------------------warehouseorderProdcut
-------------------------------------------------------------------------------------------orderProdcut

-------------------------------------------------------------------------------------------orderProdcut