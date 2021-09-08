--*************************************************************************--
-- Title: Assignment07
-- Author: DStroshine
-- Desc: This file demonstrates how to use Functions
-- Change Log: September 4, 2021,Dayana Stroshine,Assignment 07
-- 2017-01-01,DStroshine,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_DStroshine')
	 Begin 
	  Alter Database [Assignment07DB_DStroshine] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_DStroshine;
	 End
	Create Database Assignment07DB_DStroshine;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_DStroshine;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- show a list of Product names and the price of each product
-- Use a function to format the price as US dollars?
-- Order the result by the product name.
/*
-- SHOW WORK --
-- view table
SELECT * FROM vProducts;
go
-- test function to convert Unit Price to needed format
SELECT
	Format(UnitPrice, 'C','en-US') AS UnitPrice
FROM vProducts;
go
*/

-- FINAL QUERY 
SELECT
	 ProductName
	,Format(UnitPrice, 'C','en-US') AS UnitPrice
FROM vProducts
ORDER BY 
	ProductName	
go 

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product
-- Format the price as US dollars.
-- Order the result by the Category and Product.
/*
-- SHOW WORK --
-- view tables
SELECT * FROM vProducts;
go 
SELECT * FROM vCategories;
go
-- test function to convert Unit Price to needed format
SELECT
	Format(UnitPrice, 'C','en-US') AS UnitPrice
FROM vProducts;
go
-- join tables and bring in needed fields
SELECT
	 CategoryName
	,ProductName
	,Format(UnitPrice, 'C','en-US') AS UnitPrice
FROM vProducts vp
JOIN vCategories vc 
	ON vp.CategoryID = vc.CategoryID
*/

-- FINAL QUERY 
SELECT
	 CategoryName
	,ProductName
	,Format(UnitPrice, 'C','en-US') AS UnitPrice
FROM vProducts vp
JOIN vCategories vc 
	ON vp.CategoryID = vc.CategoryID
ORDER BY 1,2
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count
-- Format the date like 'January, 2017'.
-- Order the results by the Product, Date, and Count.
/*
-- SHOW WORK 
-- view tables
SELECT * FROM vProducts;
go 
SELECT * FROM vInventories;
go
-- test function to convert Inventory Date to correct format
SELECT
    FORMAT(InventoryDate,'MMMM, yyyy','en-us') AS InventoryDate
FROM vInventories
go 
-- join tables and bring in needed fields
SELECT 
     ProductName
    ,DATENAME(mm,InventoryDate)+', '+DATENAME(yy,InventoryDate)  AS InventoryDate
    ,Count AS InventoryCount
FROM vProducts vp 
JOIN vInventories vi 
    ON vp.ProductID = vi.ProductID
go 
-- test functions to convert Inventory Date to a format that can be used in order by clause
SELECT
    FORMAT(InventoryDate,'d','en-us')
FROM vInventories;
go 
*/

-- FINAL QUERY  
SELECT 
     ProductName
    ,FORMAT(InventoryDate,'MMMM, yyyy','en-us') AS InventoryDate
    ,Count AS InventoryCount
FROM vProducts vp 
JOIN vInventories vi 
    ON vp.ProductID = vi.ProductID
ORDER BY 
     ProductName
    ,FORMAT(InventoryDate,'d','en-us')
    ,Count
go 

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count, 
-- Format the date like 'January, 2017'.
-- Order the results by the Product, Date, and Count!

--FINAL QUERY
-- re-used query from question 3 to create view
CREATE --drop
VIEW vProductInventories WITH SCHEMABINDING
AS
    SELECT TOP 1000000
         ProductName
        ,FORMAT(InventoryDate,'MMMM, yyyy','en-us') AS InventoryDate
        ,Count AS InventoryCount
    FROM dbo.vProducts vp 
    JOIN dbo.vInventories vi 
        ON vp.ProductID = vi.ProductID
    ORDER BY 
         ProductName
        ,FORMAT(InventoryDate,'d','en-us')
        ,Count 
go
-- Check that it works: Select * From vProductInventories;
go 

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
/*
--SHOW WORK
-- view tables
SELECT * FROM vCategories;
go 
SELECT * FROM vProducts;
go
SELECT * FROM vInventories;
go
-- test function to convert Inventory Date to correct format
SELECT
    FORMAT(InventoryDate,'MMMM, yyyy','en-us') AS InventoryDate
FROM vInventories
go
-- test subquery to get needed fields and join tables using GROUP BY (for reference, not used in final query)
SELECT
     CategoryName
    ,FORMAT(InventoryDate,'MMMM, yyyy','en-us') AS InventoryDate
    ,SUM(Count) AS InventoryCount
FROM vInventories vi 
JOIN vProducts vp 
    ON vi.ProductID = vp.ProductID
JOIN vCategories vc
    ON vp.CategoryID = vc.CategoryID
GROUP BY InventoryDate,CategoryName
go 
-- create subquery to get needed fields and join tables using WINDOW FUNCTION
SELECT DISTINCT
     CategoryName
    ,InventoryDate
    ,SUM(Count) OVER(PARTITION BY CategoryName, InventoryDate) AS InventoryCount
FROM vInventories vi 
JOIN vProducts vp 
    ON vi.ProductID = vp.ProductID
JOIN vCategories vc
    ON vp.CategoryID = vc.CategoryID
go 
-- bring everything together
SELECT 
     CategoryName
    ,FORMAT(InventoryDate,'MMMM, yyyy','en-us') AS InventoryDate
    ,InventoryCount
FROM 
    (SELECT DISTINCT
         CategoryName
        ,InventoryDate
        ,SUM(Count) OVER(PARTITION BY CategoryName, InventoryDate) AS InventoryCount
    FROM vInventories vi 
    JOIN vProducts vp 
        ON vi.ProductID = vp.ProductID
    JOIN vCategories vc
        ON vp.CategoryID = vc.CategoryID ) a
go 
*/
-- FINAL QUERY 
-- add view
CREATE --drop
VIEW vCategoryInventories WITH SCHEMABINDING
AS
    SELECT 
         CategoryName
        ,FORMAT(InventoryDate,'MMMM, yyyy','en-us') AS InventoryDate
        ,InventoryCount
    FROM 
        (SELECT DISTINCT
            CategoryName
            ,InventoryDate
            ,SUM(Count) OVER(PARTITION BY CategoryName, InventoryDate) AS InventoryCount
        FROM dbo.vInventories vi 
        JOIN dbo.vProducts vp 
            ON vi.ProductID = vp.ProductID
        JOIN dbo.vCategories vc
            ON vp.CategoryID = vc.CategoryID ) a
go 
-- Check that it works: Select * From vCategoryInventories;
go 

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product, Date, and Count. 
-- This new view must use your vProductInventories view!
/*
--SHOW WORK
-- view tables
SELECT * FROM vProductInventories;
go
-- create subquery to get needed previous month count field using a WINDOW FUNCTION
SELECT
     ProductName
    ,InventoryDate
    ,SUM(InventoryCount) AS InventoryCount
    ,LAG(SUM(InventoryCount)) OVER(ORDER BY ProductName,YEAR(InventoryDate), MONTH(InventoryDate)) AS PreviousMonthCount
FROM vProductInventories 
GROUP BY ProductName, InventoryDate, InventoryCount
go
-- add IIF statement to look for Jan NULL values and replace with 0
SELECT
     ProductName
    ,InventoryDate
    ,SUM(InventoryCount) AS InventoryCount
    ,IIF(MONTH(InventoryDate) = 1,0,LAG(SUM(InventoryCount)) OVER(ORDER BY ProductName,YEAR(InventoryDate), MONTH(InventoryDate))) AS PreviousMonthCount
FROM vProductInventories 
GROUP BY ProductName, InventoryDate, InventoryCount
go
*/ 
-- FINAL QUERY 
-- add view
CREATE --drop
VIEW vProductInventoriesWithPreviousMonthCounts WITH SCHEMABINDING
AS
    SELECT
        ProductName
        ,InventoryDate
        ,SUM(InventoryCount) AS InventoryCount
        ,IIF(MONTH(InventoryDate) = 1,0,LAG(SUM(InventoryCount)) OVER(ORDER BY ProductName,YEAR(InventoryDate), MONTH(InventoryDate))) AS PreviousMonthCount
    FROM dbo.vProductInventories 
    GROUP BY ProductName, InventoryDate, InventoryCount
go 
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
go 

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Order the results by the Product, Date, and Count!
/*
--SHOW WORK
-- view tables
SELECT * FROM vProductInventoriesWithPreviousMonthCounts;
go 
-- Create a CASE statement to show KPI with values
SELECT
     ProductName
    ,InventoryDate
    ,InventoryCount
    ,PreviousMonthCount
    ,CASE
        WHEN InventoryCount > PreviousMonthCount THEN 1
        WHEN InventoryCount = PreviousMonthCount THEN 0
        WHEN InventoryCount < PreviousMonthCount THEN -1
    END AS CountVsPreviousCountKPI
FROM vProductInventoriesWithPreviousMonthCounts
go 
-- order by ProductName, InventoryDate, InventoryCount
SELECT
     ProductName
    ,InventoryDate
    ,InventoryCount
    ,PreviousMonthCount
    ,CASE
        WHEN InventoryCount > PreviousMonthCount THEN 1
        WHEN InventoryCount = PreviousMonthCount THEN 0
        WHEN InventoryCount < PreviousMonthCount THEN -1
    END AS CountVsPreviousCountKPI
FROM vProductInventoriesWithPreviousMonthCounts
ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate), InventoryCount
go
*/ 
-- FINAL QUERY 
-- add view
CREATE --drop
VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs WITH SCHEMABINDING
AS
    SELECT TOP 10000000
     ProductName
    ,InventoryDate
    ,InventoryCount
    ,PreviousMonthCount
    ,CASE
        WHEN InventoryCount > PreviousMonthCount THEN 1
        WHEN InventoryCount = PreviousMonthCount THEN 0
        WHEN InventoryCount < PreviousMonthCount THEN -1
    END AS CountVsPreviousCountKPI
    FROM dbo.vProductInventoriesWithPreviousMonthCounts
    ORDER BY ProductName, YEAR(InventoryDate), MONTH(InventoryDate), InventoryCount
go 
-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go 

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view!
/*
--SHOW WORK
-- view tables
SELECT * FROM vProductInventoriesWithPreviousMonthCountsWithKPIs;
go 
*/
-- FINAL QUERY
-- create in-line table function
CREATE FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs
(
    @CountVsPreviousCountKPI INT
)
RETURNS TABLE
AS
RETURN
    SELECT 
        ProductName
        ,InventoryDate
        ,InventoryCount
        ,PreviousMonthCount
        ,CountVsPreviousCountKPI = @CountVsPreviousCountKPI
    FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
go

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/