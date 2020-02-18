--First Exercise
--Q3
SELECT ProductName FROM dbo.Products
WHERE UnitsInStock>20
--Q4
SELECT TOP(10) ProductID, ProductName, UnitPrice FROM dbo.Products
ORDER BY UnitPrice DESC
--Q5
SELECT ProductID, ProductName, QuantityPerUnit FROM dbo.Products
ORDER BY ProductName
--Q6
SELECT ProductID, ProductName, UnitPrice FROM dbo.Products
ORDER BY UnitsInStock DESC OFFSET 10 ROWS FETCH FIRST 5 ROWS ONLY
--Q&
SELECT FirstName+' has an EmployeeID of'+STR(EmployeeID,1)+' and was born '+
CONVERT(NVARCHAR(30),BirthDate,126) FROM dbo.Employees
--Q8
SELECT ShipName + ' is from ' + COALESCE(ShipCity, ShipRegion,ShipCountry) FROM dbo.Orders
--Q9
SELECT ShipName, ISNULL(ShipPostalCode,'unknown') FROM dbo.Orders
--Q10
SELECT CompanyName,
CASE WHEN Fax IS NULL THEN 'modern' ELSE 'outdated' END AS Status
FROM dbo.Suppliers

--Second Exercise
/*Q1: Get the order ID and unit price for each order by joining the Orders table and the Order Details table.
Note that you need to use [Order Details] since the table name contains whitespace.*/
SELECT o.OrderID, od.UnitPrice FROM dbo.Orders AS o
JOIN dbo.[Order Details] AS od
ON o.OrderID=od.OrderID;

/*Q2: Get the order ID and first name of the associated employee by joining the Orders and Employees tables.*/
SELECT o.OrderID, e.FirstName FROM dbo.Orders AS o
JOIN dbo.Employees AS e
ON o.EmployeeID=e.EmployeeID

/*Q3: Get the employee ID and related territory description for each territory an employee is in, 
by joining the Employees, EmployeeTerritories and Territories tables.*/
SELECT e.EmployeeID, t.TerritoryDescription FROM dbo.Employees AS e
JOIN dbo.EmployeeTerritories AS et
ON et.EmployeeID=e.EmployeeID
JOIN dbo.Territories AS t
ON t.TerritoryID=et.TerritoryID

/*Q4: Select all the different countries from the Customers table and the Suppliers table using UNION.*/
SELECT Country FROM dbo.Customers
UNION 
SELECT Country FROM dbo.Suppliers

/*Q5: Select all the countries, including duplicates, from the Customers table and the Suppliers table using UNION ALL.*/
SELECT Country FROM dbo.Customers
UNION ALL
SELECT Country FROM dbo.Suppliers

/*Q6: Using the Products table, get the unit price of each product, rounded to the nearest dollar.*/
SELECT ROUND(UnitPrice,0) FROM dbo.Products

/*Q7: Using the Products table, get the total number of units in stock across all products.*/
SELECT SUM(UnitsInStock) FROM dbo.Products

/*Q8: Using the Orders table, get the order ID and year of the order by using YEAR(). Alias the year as OrderYear.*/
SELECT OrderID, YEAR(OrderDate) FROM dbo.Orders

/*Q9: Using the Orders table, get the order ID and month of the order by using DATENAME(). Alias the month as OrderMonth.*/
SELECT OrderID, DATENAME(MM,OrderDate) AS OrderMonth FROM dbo.Orders

/*Q10: Use LEFT() to get the first two letters of each region description from the Region table.*/
SELECT LEFT(RegionDescription,2) FROM dbo.Region;

/*Q11: Using the Suppliers table, select the city and postal code for each supplier, 
using WHERE and ISNUMERIC() to select only those postal codes which have no letters in them.*/
SELECT City, PostalCode FROM dbo.Suppliers
WHERE ISNUMERIC(PostalCode)=1

/*Q12: Use LEFT() and UPPER() to get the first letter (capitalized) of each region description from the Region table.*/
SELECT UPPER(LEFT(RegionDescription,1)) FROM dbo.Region;

--Third Exercise
/*Q1: Use a subquery to get the product name and unit price of products from the Products table 
which have a unit price greater than the average unit price from the Order Details table.
Note that you need to use [Order Details] since the table name contains whitespace.*/
SELECT ProductName, UnitPrice FROM dbo.Products
WHERE UnitPrice> (SELECT AVG(UnitPrice) FROM dbo.[Order Details]);

/*Q2: Select from the Employees and Orders tables. Use a subquery to get the first name and employee ID for employees 
who were associated with orders which shipped from the USA.*/
SELECT FirstName, EmployeeID FROM dbo.Employees
WHERE EmployeeID IN (SELECT EmployeeID FROM dbo.Orders
WHERE ShipCountry = 'USA')

/*Q3: Use the # to create a new temporary table called ProductNames which has one field called ProductName (a VARCHAR of max length 40).
Insert into this table the names of every product from the Products table. Note that there are two syntaxes for the INSERT INTO statement. 
Use the syntax that does not specify the column names since the table only has one field.
Select all columns from the ProductNames table you created.
Note: you need to specify the Products table as Products, not dbo.Products.*/
CREATE TABLE #ProductNames(ProductName varchar(40));
INSERT INTO #ProductNames 
SELECT ProductName FROM Products;
SELECT * FROM #ProductNames;

--Forth Exercise
/*Q1:Use CHOOSE() and MONTH() to get the season in which each order was shipped from the Orders table. You should select the order ID, 
shipped date, and then the season aliased as ShippedSeason. You can copy and paste the below into your query.
Be careful to filter out any NULL shipped dates.*/
SELECT OrderID, ShippedDate, 
CHOOSE(MONTH(ShippedDate),'Winter', 'Winter', 'Spring', 'Spring', 'Spring', 'Summer', 'Summer', 'Summer', 'Autumn', 'Autumn', 'Autumn', 'Winter') AS ShippedSeason FROM dbo.Orders
WHERE ShippedDate IS NOT NULL; 

/*Q2 :Using the Suppliers table, select the company name and use 
a simple IIF expression to display 'outdated' if a company has a fax number, or 'modern' if it doesn't. 
Alias the result of the IIF expression to Status.*/
SELECT CompanyName, IIF(Fax IS NULL,'modern','outdated') AS Status FROM dbo.Suppliers

/*Q3 :Select from the Customers, Orders, and Order Details tables. Note that you need to use [Order Details] since the table name contains whitespace.
Use GROUP BY and ROLLUP() to get the total quantity ordered by all countries, while maintaining the total per country in your result set.
Your first column should be the country, and the second column the total quantity ordered by that country, aliased as TotalQuantity.*/
SELECT c.Country, SUM(od.Quantity) AS TotalQuantity FROM dbo.Customers AS c
JOIN dbo.Orders AS o
ON c.CustomerID=o.CustomerID
JOIN dbo.[Order Details] AS od
ON od.OrderID=o.OrderID
GROUP BY ROLLUP(c.Country);

/*Q4 : From the Customers table, use GROUP BY to select the country, contact title, 
and count of that contact title aliased as Count, grouped by country and contact title (in that order).
Then use CASE WHEN, GROUPING_ID(), and ROLLUP() to add a column called Legend, which shows one of two things:
When the GROUPING_ID is 0, show '' (i.e., nothing)
When the GROUPING_ID is 1, show Subtotal for << Country >>'
Do not use ORDER BY to order your results.*/
SELECT Country, ContactTitle,COUNT(ContactTitle) AS Count, 
CASE WHEN GROUPING_ID(ContactTitle)=0 THEN '' ELSE CONCAT('Subtotal for ',Country) END AS Legend FROM dbo.Customers
GROUP BY ROLLUP(Country,ContactTitle)
--or
SELECT Color, ProductCategoryID,COUNT(ProductCategoryID) AS Count, 
CASE  WHEN GROUPING_ID(ProductCategoryID)=0 THEN '' ELSE CONCAT('SUBTOTAL for ',Color) END AS Legend FROM SalesLT.Product
GROUP BY Color,ProductCategoryID WITH ROLLUP

/*Q5 :Convert the following query to be pivoted, using PIVOT().
SELECT CategoryID, AVG(UnitPrice)
FROM Products
GROUP BY CategoryID;*/
SELECT 'Average Unit Price' AS 'PerCategory' , [1],[2],[3],[4],[5],[6],[7],[8] FROM
(SELECT CategoryID, AVG(UnitPrice) AS [Average Unit Price]
FROM Products
GROUP BY CategoryID) AS core
PIVOT (AVG([Average Unit Price]) FOR CategoryID IN ([1],[2],[3],[4],[5],[6],[7],[8])) AS pvt

/*Q6 : Insert into the Region table the region ID 5 and the description 'Space'.
Then, in a second query, select the newly inserted data from the table using a WHERE clause.
Note: When you execute a query and the result is fetched, the database will be rolled back 
to its initial state. This means that you can click "Run Code" repeatedly, starting with a clean slate every time.*/
INSERT INTO dbo.Region(RegionID,RegionDescription)
VALUES (5, 'Space');
SELECT * FROM dbo.Region
WHERE RegionID=5

/*Q7 :Update the region descriptions in the Region table to be all uppercase, using SET and UPPER().
Next, select all data from the table to view your updates.
Note: When you execute a query and the result is fetched, the database will be rolled back to its initial state. 
This means that you can click "Run Code" repeatedly, starting with a clean slate every time.*/
UPDATE dbo.Region
SET RegionDescription=UPPER(RegionDescription);
SELECT * FROM dbo.Region

/*Q8 :Write a script that safely checks whether a certain region exists:
Declare a custom region @region called 'Space', of type NVARCHAR(25).
Use IF NOT EXISTS, ELSE, and BEGIN..END to:
throw an error with THROW 50001, 'Error!', 0 if no record whose RegionDescription matches @region exists.
select all columns for that region from the Region table if the record does exist.
Notes:
Specify the Region table as Region, not dbo.Region.
Use SELECT * FROM Region <fill in> everywhere.*/
DECLARE @region NVARCHAR(25)='Space'
IF NOT EXISTS (SELECT * FROM Region WHERE RegionDescription = @region)
BEGIN
  THROW 50001,'Error!', 0;
END
ELSE
BEGIN
  SELECT * FROM Region WHERE RegionDescription=@region
END
