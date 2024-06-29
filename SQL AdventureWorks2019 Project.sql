--Question1 -  Show products that were never purchased 
--             Show Columns: ProductID, Name (of product), Color, ListPrice, Size
USE AdventureWorks2019
SELECT P.ProductID, P.Name,P.Color, P.ListPrice,P.Size
FROM Production.Product AS P
	LEFT JOIN Sales.SalesOrderDetail AS S
	ON P.ProductID=S.ProductID
WHERE S.ProductID IS NULL

--Question 2 - Show customers that have not placed any orders
--             Show columns: CustomerID, FirstName, LastName in ascending order
--             If there is missing data in columns FirstName and LastName - show value "Unknown"
SELECT C.CustomerID,isnull(P.LastName ,'Unknown') AS 'LastName', isnull(P.FirstName, 'Unknown') AS 'FirstName'
FROM Sales.Customer AS C 
	LEFT JOIN Sales. SalesOrderHeader AS OD
	ON C.CustomerID=OD.CustomerID
		LEFT JOIN Person.Person AS P 
		ON C.CustomerID=P.BusinessEntityID
WHERE OD.SalesOrderID is null
ORDER BY C.CustomerID

--Question 3 - how the 10 customers that have placed the most orders
--             Show columns: CustomerID, FirstName, LastName and the amount of orders in descending order

SELECT TOP 10 C.CustomerID,C.FirstName, C.LastName,C.CountOfOrders
FROM (
		SELECT C.CustomerID,P.LastName , P.FirstName, COUNT(OD.SalesOrderID) AS CountOfOrders,
			DENSE_RANK() OVER ( ORDER BY COUNT(OD.SalesOrderID) DESC ) AS RNK
		FROM Sales.Customer AS C 
			JOIN Sales. SalesOrderHeader AS OD
			ON C.CustomerID=OD.CustomerID
				JOIN Person.Person AS P 
				ON C.CustomerID=P.BusinessEntityID
		GROUP BY C.CustomerID,P.LastName , P.FirstName) AS C
ORDER BY C.CountOfOrders DESC, C.CustomerID

--Question 4 - Show data regarding employees and their job titles
--             Show columns: FirstName, LastName, JobTitle, HireDate and the amount of employees that share the same job title
SELECT P.FirstName,P.LastName, E.JobTitle, E.HireDate,
	COUNT(E.BusinessEntityID) OVER (PARTITION BY E.JobTitle ) AS CountOfTiLE
FROM Person.Person AS P 
	JOIN HumanResources.Employee AS E
	ON P.BusinessEntityID=E.BusinessEntityID

--Question 5 - For every customer, show their most recent order date and the second most recent order date.
--             Show columns: SalesOrderID, CustomerID, LastName, FirstName, LastOrder, PreviousOrder
WITH ORDERS
AS 
(
SELECT SOH.SalesOrderID,C.CustomerID,P.LastName,P.FirstName,SOH.OrderDate AS LastOrder,C.PersonID,
	LAG(SOH.OrderDate)OVER (PARTITION BY C.CustomerID  ORDER BY SOH.OrderDate ASC) AS PreviousOrder,
	DENSE_RANK ()OVER (PARTITION BY C.CustomerID ORDER BY SOH.OrderDate DESC) AS DR
FROM Sales.SalesOrderHeader AS SOH
	  JOIN sales.Customer AS C
	  ON C.CustomerID=SOH.CustomerID
			 JOIN Person.Person AS P
			  ON P.BusinessEntityID=C.PersonID)
SELECT SalesOrderID,CustomerID,LastName,FirstName,LastOrder,PreviousOrder
FROM ORDERS AS O
WHERE DR =1
ORDER BY O.PersonID

--Question 6 - For every year, show the order with the highest total payment and which customer placed the order
--             Show columns: Year, SalesOrderID, LastName, FirstName, Total
SELECT DISTINCT Y AS 'YEAR', S.SalesOrderID,S.LastName,S.FirstName,FORMAT(Total,'#,#.0') AS 'TOTAL'
FROM (SELECT*, DENSE_RANK()over(partition by Y ORDER BY Total DESC) AS 'DENSE_RANK'
	  FROM (SELECT YEAR(SOH.OrderDate) as Y ,SOH.SalesOrderID,P.LastName,P.FirstName,
			SUM( SOD.UnitPrice*SOD.OrderQty*(1-SOD.UnitPriceDiscount)) OVER (PARTITION BY SOH.SalesOrderID)  AS Total	
			FROM Sales.SalesOrderDetail as SOD
				LEFT JOIN Sales.SalesOrderHeader AS SOH
				ON soh.SalesOrderID=sod.SalesOrderID
					LEFT JOIN sales.Customer AS C
					ON C.CustomerID=SOH.CustomerID
						LEFT JOIN Person.Person AS P
						ON P.BusinessEntityID=C.PersonID) AS O ) AS S
WHERE S.DENSE_RANK=1
ORDER BY YEAR 

--Question 7 - Show the number of orders for by month, for every year
--             Show Columns: Month and a column for every year
SELECT*
FROM (SELECT MONTH(S.OrderDate) AS 'Month',YEAR(S.OrderDate) AS 'YY', S.SalesOrderNumber
	  FROM Sales.SalesOrderHeader AS S) AS O
PIVOT (COUNT(SalesOrderNumber) FOR YY IN ([2011],[2012],[2013],[2014])) PVT
ORDER BY Month
--question 8 - Show employees sorted by their hire date in every department from most to least recent, name and hire date for the last employee hired before them 
--             and the number of days between the two hire dates
--             Show Columns: DepartmentName, EmployeeID, EmployeeFullName, HireDate, Seniority, PreviousEmpName, PreviousEmpHDate, DiffDays
 WITH MonthlyTotal as
(
 SELECT
     YEAR (soh.OrderDate) AS YEAR, MONTH(soh.OrderDate) AS Month,
     SUM(so.UnitPrice ) AS Sum_Price,
     SUM(SUM( so.UnitPrice)) OVER (PARTITION BY YEAR(OrderDate)
     ORDER BY YEAR(OrderDate), MONTH(OrderDate) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumSum
FROM Sales.SalesOrderHeader AS soh
	INNER JOIN Sales.SalesOrderDetail so ON soh.SalesOrderID = so.SalesOrderID
GROUP BY YEAR(soh.OrderDate), MONTH(soh.OrderDate)

),

YearlyTotal AS
( SELECT
        YEAR(soh.OrderDate) AS Year,'grand total' AS Month, NULL AS Sum_Price,
        SUM(SUM(ss.UnitPrice)) OVER (PARTITION BY YEAR(soh.OrderDate)) AS CumSum
    FROM Sales.SalesOrderHeader soh
    INNER JOIN Sales.SalesOrderDetail ss ON soh.SalesOrderID = ss.SalesOrderID
    GROUP BY YEAR(soh.OrderDate)
)
SELECT tb1.Year,tb1.Month, tb1.Sum_Price, tb1.CumSum
FROM ( SELECT mt.YEAR,CAST( mt.Month AS VARCHAR) AS Month, mt.Sum_Price, mt.CumSum
       FROM MonthlyTotal AS mt

          UNION ALL

       SELECT yt.year,yt.month, yt.Sum_Price, yt.CumSum
        FROM YearlyTotal AS yt) AS tb1

ORDER BY YEAR, CumSum,
    CASE WHEN MONTH = 'grand total' THEN 1 ELSE CAST(MONTH AS INT) END


--Q9
SELECT D.DepartmentName,D.[Employee'sId],D.[Employee'sFullName],D.HireDate,D.Seniority,D.PreviousEmpName,D.PreviousEmpDate,
	DATEDIFF(DD,D.PreviousEmpDate,D.HireDate) AS DiffDays
FROM (SELECT D.Name AS DepartmentName,E.BusinessEntityID AS "Employee'sId",CONCAT(P.FirstName,' ',P.LastName) AS "Employee'sFullName",E.HireDate,
			DATEDIFF(MM,E.HireDate,GETDATE()) AS Seniority, 
			LAG(CONCAT(P.FirstName,' ',P.LastName)) OVER ( PARTITION BY D.Name ORDER BY E.HireDate) AS PreviousEmpName,
			LAG(E.HireDate,1) OVER (PARTITION BY D.Name ORDER BY E.HireDate) AS PreviousEmpDate
	  FROM HumanResources.Employee AS E
			JOIN HumanResources.EmployeeDepartmentHistory AS ED
			ON E.BusinessEntityID=ED.BusinessEntityID
				JOIN Person.Person AS P
				ON E.BusinessEntityID=P.BusinessEntityID
					JOIN HumanResources.Department AS D
					ON D.DepartmentID=ED.DepartmentID) AS D
ORDER BY D.DepartmentName, D.HireDate DESC


--Q10
SELECT E.HireDate,E.DepartmentID, STRING_AGG(E.NM, ' , ') AS TeamEmployees
FROM(
	SELECT E.HireDate,ED.DepartmentID, ED.EndDate,
		CONCAT (CAST ( E.BusinessEntityID AS varchar) ,' ',(P.LastName + ' '+P.FirstName )) AS NM
	FROM HumanResources.Employee AS E
		JOIN HumanResources.EmployeeDepartmentHistory AS ED
		ON E.BusinessEntityID=ED.BusinessEntityID
			JOIN Person.Person AS P
			ON E.BusinessEntityID=P.BusinessEntityID
	WHERE ED.EndDate IS NULL) E
GROUP BY E.HireDate,E.DepartmentID
ORDER BY E.HireDate DESC
