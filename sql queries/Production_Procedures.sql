-------------------------------------------------------------------------------------------createItem
ALTER PROCEDURE createItems(@amountToCreate INT, @model VARCHAR(20), @productionId INT, @warehouseId INT, @price DECIMAL(19,2))
AS
BEGIN
	DECLARE @itemCount INT;
	SET @itemCount = @amountToCreate;

	DECLARE @findPrice DECIMAL(19,2);
	IF @price IS NULL
		BEGIN
			IF @model = 'MacBook'
				SET @findPrice = 2000.00
			ELSE
				SET @findPrice = 1200.00
		END
	ELSE 
		BEGIN
			SET @FindPrice = @price;
		END

	WHILE @itemCount > 0
	BEGIN
		DECLARE @itemId INT
		--create item
		INSERT INTO item(model, price) VALUES(@model, @price);
		SET @itemId = SCOPE_IDENTITY();

		--connect to productionHouse
		INSERT INTO item_productionHouse(itemId,productionId,birth,departure,initPrice)
		VALUES(@itemId,@productionId, GETDATE(), GETDATE(), @findPrice);

		--connect to warehouse
		INSERT INTO item_warehouse(itemId,warehouseId,arrival,currentPrice)
		VALUES(@itemId,@warehouseId,GETDATE(),@findPrice)
		
		SELECT @itemCount = @itemCount - 1;
	END
END

-------------------------------------------------------------------------------------------createItem
