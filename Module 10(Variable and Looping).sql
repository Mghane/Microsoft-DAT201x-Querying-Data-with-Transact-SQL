/* Module 10
*/
DECLARE @City varchar(20)='Toronto'
--SET @City='Calgary'
SELECT c.FirstName+' ' +c.LastName AS [FullName], a.City
FROM SalesLT.Customer AS c
JOIN SalesLT.CustomerAddress AS ca
ON c.CustomerID=ca.CustomerID
JOIN SalesLT.Address AS a
ON a.AddressID=ca.AddressID
WHERE a.City=@City
--
DECLARE @Result money
SELECT MAX(TotalDue) AS Result
FROM SalesLT.SalesOrderHeader
PRINT @Result
--
--Conditional Branching
UPDATE SalesLT.Product
SET DiscontinuedDate=GETDATE()
WHERE ProductID=680

IF @@ROWCOUNT>0
	BEGIN
		PRINT 'Product is updated'
	END
ELSE
	BEGIN
		PRINT 'Product is not found'
	END
--Looping
DECLARE @custid AS int=1, @lname AS varchar(20);
WHILE @custid<=5
	BEGIN 
		SELECT @lname=LastName FROM SalesLT.Customer
		WHERE CustomerID=@custid
		PRINT @lname
		SET @custid += 1
	END
--another while example
DECLARE @counter INT=1 
WHILE @counter<=10
	BEGIN
		INSERT INTO SalesLT.Calllog (SalesPerson, CustomerID, PhoneNumber, Notes)
		VALUES (CONCAT('adventure-works\John',CONVERT(nvarchar(5),@counter)), @counter,'404-404-4444', 'Via Loop')
		SET @counter = @counter + 1
		PRINT @@ROWCOUNT
	END

--Stored Procedure
CREATE PROCEDURE SalesLT.GetProductCategory(@CategoryID INT = NULL)
AS 
IF @CategoryID IS NULL
	SELECT ProductID, Size, ListPrice, Color
	FROM SalesLT.Product
ELSE
	SELECT ProductID, Size, ListPrice, Color
	FROM SalesLT.Product
	WHERE ProductCategoryID=@CategoryID

--without a parameter
EXECUTE SalesLT.GetProductCategory 
--with a parameter
EXEC SalesLT.GetProductCategory 8

--Lab Assignment 
DECLARE @OrderDate datetime = GETDATE();
DECLARE @DueDate datetime = DATEADD(dd, 7, GETDATE());
DECLARE @CustomerID int = 1;

INSERT INTO SalesLT.SalesOrderHeader (OrderDate, DueDate, CustomerID, ShipMethod)
VALUES (@OrderDate, @DueDate, @CustomerID, 'CARGO TRANSPORT 5');

PRINT SCOPE_IDENTITY();
--Lab
-- Code from previous exercise
DECLARE @OrderDate datetime = GETDATE();
DECLARE @DueDate datetime = DATEADD(dd, 7, GETDATE());
DECLARE @CustomerID int = 1;
INSERT INTO SalesLT.SalesOrderHeader (OrderDate, DueDate, CustomerID, ShipMethod)
VALUES (@OrderDate, @DueDate, @CustomerID, 'CARGO TRANSPORT 5');
DECLARE @OrderID int = SCOPE_IDENTITY();

-- Additional script to complete
DECLARE @ProductID int = 760;
DECLARE @Quantity int = 1;
DECLARE @UnitPrice money = 782.99;

IF EXISTS (SELECT * FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @OrderID)
BEGIN
	INSERT INTO SalesLT.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice)
	VALUES (@OrderID, @Quantity, @ProductID,@UnitPrice)
END
ELSE
BEGIN
	PRINT 'The order does not exist'
END
--Lab
DECLARE @MarketAverage money = 2000;
DECLARE @MarketMax money = 5000;
DECLARE @AWMax money;
DECLARE @AWAverage money;

SELECT @AWAverage = AVG(ListPrice), @AWMax = MAX(ListPrice)
FROM SalesLT.Product
WHERE ProductCategoryID IN
	(SELECT DISTINCT ProductCategoryID
	 FROM SalesLT.vGetAllCategories
	 WHERE ParentProductCategoryName = 'Bikes');

WHILE @AWAverage < @MarketAverage
BEGIN
   UPDATE SalesLT.Product
   SET ListPrice = ListPrice * 1.1
   WHERE ProductCategoryID IN
	(SELECT DISTINCT ProductCategoryID
	 FROM SalesLT.vGetAllCategories
	 WHERE ParentProductCategoryName = 'Bikes');

	SELECT @AWAverage = AVG(ListPrice), @AWMax = MAX(ListPrice)
	FROM SalesLT.Product
	WHERE ProductCategoryID IN
	(SELECT DISTINCT ProductCategoryID
	 FROM SalesLT.vGetAllCategories
	 WHERE ParentProductCategoryName = 'Bikes');

   IF @AWMax >= @MarketMax
      BREAK
   ELSE
      CONTINUE
END