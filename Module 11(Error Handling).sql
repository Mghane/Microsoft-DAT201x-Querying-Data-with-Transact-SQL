UPDATE SalesLT.Product
SET Name='Test'
WHERE ProductID=110

IF @@ROWCOUNT<1
	RAISERROR('NO product found' ,16, 0)
--Alterntive using throw
UPDATE SalesLT.Product
SET Name='Test'
WHERE ProductID=110

IF @@ROWCOUNT<1
	THROW 50001, 'No product Found', 0;
--Catching Error
BEGIN TRY
	UPDATE SalesLT.Product 
	SET ProductNumber=ProductID/ISNULL(Weight,0)
END TRY
BEGIN CATCH
	PRINT	'The Following Error Occured:'
	PRINT	ERROR_MESSAGE()
END CATCH
--Use throw to show the error
BEGIN TRY
	UPDATE SalesLT.Product 
	SET ProductNumber=ProductID/ISNULL(Weight,0)
END TRY
BEGIN CATCH
	PRINT	'The Following Error Occured:';
	PRINT	ERROR_MESSAGE();
	THROW;
END CATCH
--Transaction - Try without Transcation first
BEGIN TRY
	INSERT INTO SalesLT.SalesOrderHeader (DueDate, CustomerID, ShipMethod)
	VALUES (DATEADD(dd,7,GETDATE()), 1, 'STD Delivery')
	DECLARE @SalesOrderID AS int=SCOPE_IDENTITY()
	
	INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount)
	VALUES (@SalesOrderID, 1, 99999, 1431.5, 0.00)
END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE()
END CATCH

--THis time we use Transaction
BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO SalesLT.SalesOrderHeader (DueDate, CustomerID, ShipMethod)
		VALUES 
		(DATEADD(dd,7,GETDATE()), 1, 'STD Delivery')

		DECLARE @SalesOrderID AS int=SCOPE_IDENTITY()
	
		INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount)
		VALUES 
		(@SalesOrderID, 1, 99999, 1431.5, 0.00)
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT >0
	BEGIN
		PRINT XACT_STATE();
		ROLLBACK TRANSACTION;
	END
	PRINT ERROR_MESSAGE();
	THROW 50001, 'An insert failed. The transaction was cancelled.', 0;
END CATCH
---Using Abort we can do exactly the same thing
SET XACT_ABORT ON 
BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO SalesLT.SalesOrderHeader (DueDate, CustomerID, ShipMethod)
		VALUES 
		(DATEADD(dd,7,GETDATE()), 1, 'STD Delivery')

		DECLARE @SalesOrderID AS int=SCOPE_IDENTITY()
	
		INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount)
		VALUES 
		(@SalesOrderID, 1, 99999, 1431.5, 0.00)
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
	THROW 50001, 'An insert failed. The transaction was cancelled.', 0;
END CATCH
SET XACT_ABORT OFF

-- Lab Assignment
-- Declare a custom error if the specified order doesn't exist
DECLARE @error VARCHAR(30) = 'Order #' + cast(@OrderID as VARCHAR) + ' does not exist';

IF NOT EXISTS (SELECT * FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @OrderID)
BEGIN
  THROW 50001, @error, 0;
END
ELSE
BEGIN
  DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @OrderID;
  DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @OrderID;
END
--lab
DECLARE @OrderID int = 71774
DECLARE @error VARCHAR(30) = 'Order #' + cast(@OrderID as VARCHAR) + ' does not exist';

-- Wrap IF ELSE in a TRY block
BEGIN TRY
  IF NOT EXISTS (SELECT * FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @OrderID)
  BEGIN
    THROW 50001, @error, 0
  END
  ELSE
  BEGIN
    DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @OrderID;
    DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @OrderID;
  END
END TRY
-- Add a CATCH block to print out the error
BEGIN CATCH
  PRINT ERROR_MESSAGE();
END CATCH
--lab
DECLARE @OrderID int = 0
DECLARE @error VARCHAR(30) = 'Order #' + cast(@OrderID as VARCHAR) + ' does not exist';

BEGIN TRY
  IF NOT EXISTS (SELECT * FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @OrderID)
  BEGIN
    THROW 50001, @error, 0
  END
  ELSE
  BEGIN
    BEGIN TRANSACTION
    DELETE FROM SalesLT.SalesOrderDetail
    WHERE SalesOrderID = @OrderID;
    DELETE FROM SalesLT.SalesOrderHeader
    WHERE SalesOrderID = @OrderID;
    COMMIT TRANSACTION
  END
END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 0
  BEGIN
    ROLLBACK TRANSACTION;
  END
  ELSE
  BEGIN
    PRINT ERROR_MESSAGE();
  END
END CATCH