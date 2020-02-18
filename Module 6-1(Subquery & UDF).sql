---Module 6-1
SELECT * FROM SalesLT.Product
WHERE ListPrice=(SELECT MAX(ListPrice) FROM SalesLT.Product)
--correlated subquery
SELECT soh1.CustomerID, sod1.ProductID, sod1.LineTotal FROM SalesLT.SalesOrderHeader AS soh1
JOIN SalesLT.SalesOrderDetail AS sod1 
ON soh1.SalesOrderId=sod1.SalesOrderID
WHERE sod1.LineTotal=(SELECT MAX(sod2.LineTotal) FROM SalesLT.SalesOrderDetail AS sod2
JOIN SalesLT.SalesOrderHeader AS soh2
ON soh2.SalesOrderId=sod2.SalesOrderID
WHERE soh2.CustomerID=soh1.CustomerID)
ORDER BY CustomerID
---Lab 
SELECT ProductID, Name, ListPrice
FROM SalesLT.Product
WHERE ProductID IN
  -- select ProductID from the appropriate table
  (SELECT ProductID FROM SalesLT.SalesOrderDetail
   WHERE UnitPrice < 100)
AND ListPrice >= 100
ORDER BY ProductID;
--Lab
SELECT ProductID, Name, StandardCost, ListPrice,
-- get the average UnitPrice
(SELECT AVG(UnitPrice)
 -- from the appropriate table, aliased as SOD
 FROM SalesLT.SalesOrderDetail AS SOD
 -- filter when the appropriate ProductIDs are equal
 WHERE P.ProductID = SOD.ProductID) AS AvgSellingPrice
FROM SalesLT.Product AS P
ORDER BY P.ProductID;
--lab
SELECT ProductID, Name, StandardCost, ListPrice,
(SELECT AVG(UnitPrice)
 FROM SalesLT.SalesOrderDetail AS SOD
 WHERE P.ProductID = SOD.ProductID) AS AvgSellingPrice
FROM SalesLT.Product AS P
-- filter based on StandardCost
WHERE StandardCost >1000
-- get the average UnitPrice
(SELECT AVG(UnitPrice)
 -- from the appropriate table aliased as SOD
 FROM SalesLT.SalesOrderDetail AS SOD
 -- filter when the appropriate ProductIDs are equal
 WHERE P.ProductID = SOD.ProductID)
ORDER BY P.ProductID;
--lab
-- select SalesOrderID, CustomerID, FirstName, LastName, TotalDue from the appropriate tables
SELECT SOH.SalesOrderID, SOH.CustomerID, CI.FirstName, CI.LastName, SOH.TotalDue
FROM SalesLT.SalesOrderHeader AS SOH
-- cross apply as per the instructions
CROSS APPLY dbo.ufnGetCustomerInformation(SOH.CustomerID) AS CI
-- finish the clause
ORDER BY SOH.SalesOrderID;
--lab
-- select the CustomerID, FirstName, LastName, Addressline1, and City columns from the appropriate tables
SELECT CA.CustomerID, CI.FirstName, CI.LastName, A.Addressline1, A.City
FROM SalesLT.Address AS A
JOIN SalesLT.CustomerAddress AS CA
-- join based on AddressID
ON A.AddressID = CA.AddressID
-- cross apply as per instructions
CROSS APPLY dbo.ufnGetCustomerInformation(CA.CustomerID) AS CI
ORDER BY CA.CustomerID;