--Create a table for test
CREATE TABLE SalesLT.Calllog
(
CallID int IDENTITY PRIMARY KEY NOT NULL,
CallTime datetime  DEFAULT GETDATE() NOT NULL,
SalesPerson nvarchar(256) NOT NULL,
CustomerID int NOT NULL REFERENCES SalesLT.Customer(CustomerID),
PhoneNumber nvarchar(25) NOT NULL,
Notes nvarchar(max) NULL
);
GO

--Insert row
INSERT INTO SalesLT.Calllog
VALUES 
('2015-01-01T12:30:00', 'adventure-works\pamela0', 1, '245-555-0173','Returning call re:enquiry about something')
INSERT INTO SalesLT.Calllog VALUES(DEFAULT,'adventure-works\david08', 2, '170-555-0127', NULL)
INSERT INTO SalesLT.Calllog(SalesPerson, CustomerID, PhoneNumber)
VALUES ('adventure-works\Jillian0',3,'279-555-0130')

--insert multiple rows
INSERT INTO SalesLT.Calllog VALUES
(DATEADD(mi,-2,GETDATE()), 'adventure-works\Jillian0',4,'710-555-0173', NULL),
(DEFAULT, 'adventure-works\shu0',5,'828-555-0186', 'Called to arrange deliver of order 10987')

--Insert the result of another query
INSERT INTO SalesLT.Calllog (SalesPerson, CustomerID, PhoneNumber, Notes)
SELECT SalesPerson, CustomerID, Phone, 'Sales Promotion Call' 
FROM SalesLT.Customer
WHERE CompanyName='Sharp Bikes';

--find the last identity
SELECT SCOPE_IDENTITY()
--Overriding Identy
SET IDENTITY_INSERT SalesLT.Calllog ON;
INSERT INTO SalesLT.Calllog (CallID, SalesPerson, CustomerID, PhoneNumber, Notes)
VALUES (9, 'adventure-works\Raavi02', 100, '401-600-5789', 'Change callID')
SET IDENTITY_INSERT SalesLT.Calllog OFF;

SELECT * FROM SalesLT.Calllog ORDER BY CustomerID

--Updating a table
UPDATE SalesLT.Calllog
SET Notes='Call for fun'
WHERE Notes IS NULL;

UPDATE SalesLT.Calllog
SET SalesPerson='', PhoneNumber='';

UPDATE SalesLT.Calllog
SET SalesPerson=c.SalesPerson, PhoneNUmber=c.Phone
FROM SalesLT.Customer AS c
WHERE SalesLT.Calllog.CustomerID=c.CustomerID

--if I am only interested in the class within last week
DELETE FROM SalesLT.Calllog
WHERE CallTime < DATEADD(dd,-7,GETDATE());

--Merging into a table
MERGE INTO SalesLT.Calllog AS cal
	USING SalesLT.Customer AS c
	ON c.CustomerID=cal.CustomerID
WHEN MATCHED THEN
	UPDATE SET Notes='Exisitng from the beggining'
WHEN NOT MATCHED THEN 
	INSERT (SalesPerson, CustomerID,PhoneNumber, Notes)
	VALUES(c.SalesPerson, c.CustomerID, c.Phone,'Update from Customer Table');


--Truncate the table
TRUNCATE TABLE SalesLT.Calllog

--Lab Assignment 9
-- Finish the INSERT statement
INSERT INTO SalesLT.Product (Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID	, SellStartDate)
VALUES
('LED Lights', 'LT-L123', 2.56, 12.99, 37, GETDATE());

-- Get last identity value that was inserted
SELECT SCOPE_IDENTITY();

-- Finish the SELECT statement
SELECT * FROM SalesLT.Product 
WHERE ProductID = SCOPE_IDENTITY();

--Lab
-- Insert product category
INSERT INTO SalesLT.ProductCategory (ParentProductCategoryID, Name)
VALUES
(4, 'Bells and Horns');

-- Insert 2 products
INSERT INTO SalesLT.Product (Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate)
VALUES
('Bicycle Bell', 'BB-RING', 2.47, 4.99, IDENT_CURRENT('SalesLT.ProductCategory'), GETDATE()),
('Bicycle Horn', 'BB-PARP', 1.29, 3.75, IDENT_CURRENT('SalesLT.ProductCategory'), GETDATE());

-- Check if products are properly inserted
SELECT c.Name As Category, p.Name AS Product
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory as c ON p.ProductCategoryID = c.ProductCategoryID
WHERE p.ProductCategoryID = IDENT_CURRENT('SalesLT.ProductCategory');

--lab
-- Update the SalesLT.Product table
UPDATE SalesLT.Product
SET ListPrice = ListPrice * 1.1
WHERE ProductCategoryID =
  (SELECT ProductCategoryID FROM SalesLT.ProductCategory WHERE Name = 'Bells and Horns');

SELECT ProductNumber FROM SalesLT.Product WHERE Name='LED Light'