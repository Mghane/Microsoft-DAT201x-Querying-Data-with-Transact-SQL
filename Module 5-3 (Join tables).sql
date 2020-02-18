SELECT Prod.Name, Prod.ProductCategoryID , Cat.ParentProductCategoryID,
CHOOSE (Cat.ParentProductCategoryID, 'Biking', 'Components', 'Clothing', 'Accessories')
FROM  SalesLT.Product AS Prod
JOIN SalesLT.ProductCategory AS Cat
ON Cat.ProductCategoryID=Prod.ProductCategoryID
SELECT p.Name AS productionName, c.Name AS CategoryName, RANK() OVER(PARTITION BY c.Name ORDER BY ListPrice DESC) AS RankOrder
FROM SalesLT.Product AS p
JOIN SalesLT.ProductCategory AS c
ON c. ProductCategoryID=p.ProductCategoryID
-- Aggregation
SELECT c.SalesPerson, CONCAT(c.FirstName,' ',c.LastName) AS CustomerName , ISNULL(Sum(sh.SubTotal),0) AS TotalOrder FROM  SalesLT.Customer AS c
LEFT JOIN SalesLT.SalesOrderHeader AS sh
ON c.CustomerID=sh.CustomerID
GROUP BY  CONCAT(c.FirstName,' ',c.LastName),c.SalesPerson
HAVING LEN(CONCAT(c.FirstName,' ',c.LastName))>15
ORDER BY TotalOrder DESC, CustomerName
-- Lab Assignment Module 5-3
SELECT CompanyName, TotalDue AS Revenue,
       -- get ranking and order by appropriate column
       RANK() OVER (ORDER BY TotalDue DESC) AS RankByRevenue
FROM SalesLT.SalesOrderHeader AS SOH
-- use appropriate join on appropriate table
JOIN SalesLT.Customer AS C
ON SOH.CustomerID = C.CustomerID;
--Lab Module 5-3
SELECT P.Name, SUM(SOD.LineTotal) AS TotalRevenue
FROM SalesLT.SalesOrderDetail AS SOD
-- use the appropriate join
JOIN SalesLT.Product AS P
-- join based on ProductID
ON P.ProductID = SOD.ProductID
GROUP BY P.Name
ORDER BY TotalRevenue DESC;
--lab Module 5-3
SELECT Name, SUM(LineTotal) AS TotalRevenue
FROM SalesLT.SalesOrderDetail AS SOD
JOIN SalesLT.Product AS P
ON SOD.ProductID = P.ProductID
-- filter as per the instructions
WHERE ListPrice > 1000
GROUP BY P.Name
ORDER BY TotalRevenue DESC;
