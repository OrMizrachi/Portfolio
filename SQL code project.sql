--*******************************************************
----------------Total_Revenue by Rep---------------------
--*******************************************************
SELECT Region,
	   Rep,
	   COUNT(*) AS Number_of_Orders,
       SUM(Total) AS Total_Revenue  
FROM Office_Supply_Sales
where OrderDate between '2023-01-01' and '2023-02-01'
GROUP BY Region, Rep
HAVING SUM(Total)>10000
ORDER BY SUM(Total) DESC


--*******************************************************
-------------------------SalesRank-----------------------
--*******************************************************

WITH SalesSummary AS (
						SELECT Region, 
							   Rep, 
							   SUM(Total) AS Total_Revenue, 
							   AVG(Unit_Cost) AS AvgCost,
							   COUNT(DISTINCT Item) AS UniqueItemsSold
						FROM Office_Supply_Sales
						GROUP BY Region,Rep
					 ),
TopSalesRep AS (
				SELECT Region, 
					   Rep,
					   Total_Revenue,
					   RANK() OVER (PARTITION BY Region ORDER BY Total_Revenue DESC) AS SalesRank
				FROM SalesSummary
			   )
SELECT o.OrderDate,
       o.Region,
       o.Rep,
       o.Item,
       o.Units,
       o.Unit_Cost,
       o.Total,
       s.Total_Revenue,
       s.AvgCost,
       s.UniqueItemsSold,
       t.SalesRank
FROM Office_Supply_Sales o
JOIN SalesSummary s ON o.Region = s.Region AND o.Rep = s.Rep
JOIN TopSalesRep t ON o.Region = t.Region AND o.Rep = t.Rep
WHERE  t.SalesRank = 1  -- Show data only for the top sales rep in each region
AND o.OrderDate BETWEEN '2023-01-01' AND '2024-01-01'  -- Filter by date
ORDER BY o.Region, o.OrderDate