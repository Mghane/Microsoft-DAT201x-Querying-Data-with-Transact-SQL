--Module 8
--Grouping Sets
SELECT soh.CustomerID,c.SalesPerson,  SUM(sod.LineTotal) AS Total
FROM SalesLT.Customer AS c
LEFT JOIN SalesLT.SalesOrderHeader AS soh
ON soh.CustomerID=c.CustomerID
JOIN SalesLT.SalesOrderDetail AS sod
ON sod.SalesOrderID=soh.SalesOrderID
GROUP BY GROUPING SETS (soh.CustomerID,c.SalesPerson,() )
--RollUp
SELECT p.ProductCategoryID, p.ProductID,SUM(LineTotal) AS Total
FROM SalesLT.Product AS p
JOIN SalesLT.SalesOrderDetail AS sod
ON sod.ProductID=p.ProductID
GROUP BY ROLLUP (p.ProductCategoryID, p.ProductID)
--CUBE
SELECT p.ProductCategoryID, p.ProductID,SUM(LineTotal) AS Total
FROM SalesLT.Product AS p
JOIN SalesLT.SalesOrderDetail AS sod
ON sod.ProductID=p.ProductID
GROUP BY CUBE (p.ProductCategoryID, p.ProductID)
--Grouping ID
SELECT GROUPING_ID(p.ProductCategoryID) AS CategoryGroupID,p.ProductCategoryID,GROUPING_ID(p.ProductID) AS ProductGroupID, p.ProductID,SUM(LineTotal) AS Total
FROM SalesLT.Product AS p
JOIN SalesLT.SalesOrderDetail AS sod
ON sod.ProductID=p.ProductID
GROUP BY ROLLUP (p.ProductCategoryID, p.ProductID)

--Pivoting
SELECT  SalesOrderID,Chains, Brakes, Socks , Helmets, Caps, Jerseys, [Mountain Frames] FROM
	(SELECT sod.SalesOrderID , pc.Name AS CategoryName, p.ListPrice FROM SalesLT.ProductCategory AS pc
	JOIN SalesLT.Product AS p ON pc.ProductCategoryID=p.ProductCategoryID
	JOIN SalesLT.SalesOrderDetail AS sod ON sod.ProductID=p.ProductID) AS Sales
	PIVOT (COUNT(ListPrice) FOR CategoryName IN ([Chains], [Brakes], [Socks],[Helmets],[Caps],[Jerseys],[Mountain Frames])) AS pvt

--Another Pivoting
SELECT * FROM
(SELECT p.ProductCategoryID, ISNULL(p.Color,'Uncolored') AS Color, sod.LineTotal FROM SalesLT.Product AS p
JOIN [SalesLT].[SalesOrderDetail] AS sod ON sod.ProductID=p.ProductID) AS ProdTable
PIVOT (SUM(LineTotal) FOR Color IN ([Yellow], [Silver], [Black], [Silver/Black], [Blue], [Multi],[Uncolored])) AS pvt
-----------------------------
--Creating a table from Pivot
CREATE TABLE SalesLT.FromPivotTable (ProductCategoryID int, Yellow int, [Silver] int, [Black] int, [Silver/Black] int, [Blue] int, [Multi] int,[Uncolored] int)
INSERT INTO SalesLT.FromPivotTable
SELECT * FROM
(SELECT p.ProductCategoryID, ISNULL(p.Color,'Uncolored') AS Color, sod.LineTotal FROM SalesLT.Product AS p
JOIN [SalesLT].[SalesOrderDetail] AS sod ON sod.ProductID=p.ProductID) AS ProdTable
PIVOT (SUM(LineTotal) FOR Color IN ([Yellow], [Silver], [Black], [Silver/Black], [Blue], [Multi],[Uncolored])) AS pvt
--------------------------
--UnPiviting
SELECT ProductCategoryID, Color, Revenue FROM
--Pivoting from the original table
(SELECT * FROM
(SELECT p.ProductCategoryID, ISNULL(p.Color,'Uncolored') AS Color, sod.LineTotal FROM SalesLT.Product AS p
JOIN [SalesLT].[SalesOrderDetail] AS sod ON sod.ProductID=p.ProductID) AS ProdTable
PIVOT (SUM(LineTotal) FOR Color IN ([Yellow], [Silver], [Black], [Silver/Black], [Blue], [Multi],[Uncolored])) AS mypvt) AS pvt
--Unpivoting the pivoted table
UNPIVOT(REVENUE FOR Color IN ([Yellow], [Silver], [Black], [Silver/Black], [Blue], [Multi],[Uncolored])) AS unpvt
----------------
--Lab Assignment
SELECT a.CountryRegion, a.StateProvince, SUM(soh.TotalDue) AS Revenue
FROM SalesLT.Address AS a
JOIN SalesLT.CustomerAddress AS ca
ON a.AddressID = ca.AddressID
JOIN SalesLT.Customer AS c
ON ca.CustomerID = c.CustomerID
JOIN SalesLT.SalesOrderHeader as soh
ON c.CustomerID = soh.CustomerID
-- Modify GROUP BY to use ROLLUP
GROUP BY 
ROLLUP(a.CountryRegion, a.StateProvince)
ORDER BY a.CountryRegion, a.StateProvince;
--Lab
SELECT a.CountryRegion, a.StateProvince,
IIF(GROUPING_ID(a.CountryRegion) = 1 AND GROUPING_ID(a.StateProvince) = 1, 'Total', IIF(GROUPING_ID(a.StateProvince) = 1, a.CountryRegion + ' Subtotal', a.StateProvince + ' Subtotal')) AS Level,
SUM(soh.TotalDue) AS Revenue
FROM SalesLT.Address AS a
JOIN SalesLT.CustomerAddress AS ca
ON a.AddressID = ca.AddressID
JOIN SalesLT.Customer AS c
ON ca.CustomerID = c.CustomerID
JOIN SalesLT.SalesOrderHeader as soh
ON c.CustomerID = soh.CustomerID
GROUP BY ROLLUP(a.CountryRegion, a.StateProvince)
ORDER BY a.CountryRegion, a.StateProvince;
--lab
SELECT a.CountryRegion, a.StateProvince, a.City,
CHOOSE(1+GROUPING_ID(a.City) + GROUPING_ID(a.StateProvince) + GROUPING_ID(CountryRegion),
        a.City + ' Subtotal', a.StateProvince + ' Subtotal',
        a.CountryRegion + ' Subtotal', 'Total') AS Level,
SUM(soh.TotalDue) AS Revenue
FROM SalesLT.Address AS a
JOIN SalesLT.CustomerAddress AS ca
ON a.AddressID = ca.AddressID
JOIN SalesLT.Customer AS c
ON ca.CustomerID = c.CustomerID
JOIN SalesLT.SalesOrderHeader as soh
ON c.CustomerID = soh.CustomerID
GROUP BY ROLLUP(a.CountryRegion, a.StateProvince, a.City)
ORDER BY a.CountryRegion, a.StateProvince, a.City;
--lab
SELECT * FROM
(SELECT cat.ParentProductCategoryName, CompanyName, LineTotal
 FROM SalesLT.SalesOrderDetail AS sod
 JOIN SalesLT.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
 JOIN SalesLT.Customer AS cust ON cust.CustomerID = soh.CustomerID
 JOIN SalesLT.Product AS prod ON prod.ProductID = sod.ProductID
 JOIN SalesLT.vGetAllCategories AS cat ON prod.ProductcategoryID = cat.ProductCategoryID) AS catsales
PIVOT (SUM(LineTotal) FOR ParentProductCategoryName
IN ([Accessories], [Bikes], [Clothing], [Components])) AS pivotedsales
ORDER BY CompanyName;