--Module 6 - Section 3 & Module 7 - section 1
SELECT soh1.CustomerID, sod1.ProductID, sod1.LineTotal FROM SalesLT.SalesOrderHeader AS soh1
JOIN SalesLT.SalesOrderDetail AS sod1 
ON soh1.SalesOrderId=sod1.SalesOrderID
WHERE sod1.LineTotal=(SELECT MAX(sod2.LineTotal) FROM SalesLT.SalesOrderDetail AS sod2
JOIN SalesLT.SalesOrderHeader AS soh2
ON soh2.SalesOrderId=sod2.SalesOrderID
WHERE soh2.CustomerID=soh1.CustomerID)
ORDER BY CustomerID
-- Table valued Function
CREATE FUNCTION SalesLT.udfCustomerByCity
(@City AS VARCHAR(20))
RETURNS TABLE
AS 
RETURN
(SELECT c.CustomerID, c.FirstName, c.LastName, A.AddressLine1, A.City, A.StateProvince
FROM SalesLT.Customer c JOIN SalesLT.CustomerAddress ca
ON c.CustomerID=ca.CustomerID
JOIN SalesLT.Address A ON ca.AddressID=A.AddressID
WHERE City=@City)
--Use the above function
SELECT * FROM SalesLT.udfCustomerByCity('Bellevue')
-- Practice function to extract maximum purchase for each customer
CREATE FUNCTION SalesLT.udfFindMaxPurchaseForCustomer(@CustomerID AS VARCHAR(15))
RETURNS TABLE
AS
RETURN
(SELECT MAX(sod.LineTotal) AS MaxPurchase FROM SalesLT.SalesOrderDetail AS sod
JOIN SalesLT.SalesOrderHeader AS soh
ON soh.SalesOrderId=sod.SalesOrderID
WHERE soh.CustomerID=@CustomerID)
-- Use Function with CROSS APPLY
SELECT CA.CustomerID, MP.MaxPurchase,A.Addressline1, A.City
FROM SalesLT.Address AS A
JOIN SalesLT.CustomerAddress AS CA
-- join based on AddressID
ON A.AddressID = CA.AddressID
-- cross apply as per instructions
CROSS APPLY SalesLT.udfFindMaxPurchaseForCustomer(CA.CustomerID) AS MP
WHERE MP.MaxPurchase>0
ORDER BY CA.CustomerID;
--Derived Table
SELECT Category, COUNT(ProductID) AS Products
FROM
	(SELECT p.ProductID, p.Name AS product, c.Name AS Category 
	FROM SalesLT.Product AS p
	JOIN SalesLT.ProductCategory AS c
	ON p.ProductCategoryID=c.ProductCategoryID) AS ProdCats
GROUP BY Category
ORDER BY Category
--Common Table Expression
--Let's do the above example using CTE method
WITH ProdCats(ProductID, Product, Category)
AS
	(SELECT p.ProductID, p.Name AS Product, c.Name AS Category
	FROM SalesLT.Product AS p
	JOIN SalesLT.ProductCategory AS c
	ON p.ProductCategoryID=c.ProductCategoryID
	)
SELECT Category, COUNT(ProductID) AS Products
FROM ProdCats
GROUP BY Category
ORDER BY Category
--Another Example of CTE - Find the Maximum purchase value for each customer ID
WITH MaxPurchase (CustomerID, ProductID, LineTotal)
AS
	(SELECT soh.CustomerID, sod.ProductID, sod.LineTotal FROM SalesLT.SalesOrderHeader AS soh
	JOIN SalesLT.SalesOrderDetail AS sod 
	ON soh.SalesOrderId=sod.SalesOrderID
	)
SELECT CustomerID, Max(LineTotal) AS MaximumPurchase FROM MaxPurchase
GROUP BY CustomerID
ORDER BY CustomerID
---CTE with Recursion
WITH Hierarch(FirstName,LastName , EmployeeID, ManagerID, Level)
AS
--Anchor Level
	(SELECT e.FirstName,e.LastName,e.EmployeeID,e.ManagerID, 0  FROM dbo.Employees AS e
	WHERE ManagerID IS NULL
	UNION ALL
--Recursive Query
	SELECT e.FirstName,e.LastName,e.EmployeeID,e.ManagerID, Level+1 FROM dbo.Employees AS e
	JOIN Hierarch AS h ON e.ManagerID=h.EmployeeID
	)
SELECT * FROM Hierarch

--Module 7 Lab
DECLARE @Colors AS TABLE (Color NVARCHAR(15));

INSERT INTO @Colors
SELECT DISTINCT Color FROM SalesLT.product;

SELECT ProductID, Name, Color
FROM SalesLT.Product
WHERE Color IN (SELECT Color FROM @Colors);
--Lab
SELECT C.ParentProductCategoryName AS ParentCategory,
       C.ProductCategoryName AS Category,
       P.ProductID, P.name AS ProductName
FROM SalesLT.Product AS P
JOIN dbo.ufnGetAllCategories() AS C
ON P.ProductCategoryID = C.ProductCategoryID
ORDER BY ParentCategory, Category, ProductName;
--lab
SELECT CompanyContact, SUM(SalesAmount) AS Revenue
FROM
	(SELECT CONCAT(c.CompanyName, CONCAT(' (' + c.FirstName + ' ', c.LastName + ')')), SOH.TotalDue
	 FROM SalesLT.SalesOrderHeader AS SOH
	 JOIN SalesLT.Customer AS c
	 ON SOH.CustomerID = c.CustomerID) AS CustomerSales(CompanyContact, SalesAmount)
GROUP BY CompanyContact
ORDER BY CompanyContact;
