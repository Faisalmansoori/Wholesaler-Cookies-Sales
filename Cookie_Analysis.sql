USE wholeseller;

SELECT *
FROM cookie;


-- 1. Find the product generating the highest revenue.
WITH Highest_Revenue AS 
						(
							SELECT `Product Name`, 
								    SUM(`Estimated Revenue`) AS Revenue
                            FROM cookie
                            GROUP BY `Product Name`
						)
SELECT `Product Name`, 
	    Revenue
FROM Highest_Revenue
WHERE Revenue = (
					SELECT MAX(Revenue)
                    FROM Highest_Revenue
				);
                
-- OR

SELECT `Product Name`, 
	   SUM(`Estimated Revenue`) AS Revenue
FROM cookie
GROUP BY `Product Name`
ORDER BY Revenue DESC
LIMIT 1;

-- 2. Find products whose revenue is above average revenue.
WITH Product_Revenue AS 
						(
							SELECT `Product Name`, SUM(`Estimated Revenue`) AS Revenue
							FROM cookie
                            GROUP BY `Product Name`
						)
SELECT `Product Name`, Revenue
FROM Product_Revenue
Where Revenue > 
				(
					SELECT AVG(Revenue)
                    FROM Product_Revenue
				);

-- OR

SELECT `Product Name`, SUM(`Estimated Revenue`) AS Revenue
FROM cookie
GROUP BY `Product Name`
HAVING SUM(`Estimated Revenue`) > 
									(
										SELECT AVG(Rev)
										FROM (	
												SELECT `Product Name`, 
													   SUM(`Estimated Revenue`) AS Rev
												FROM cookie
												GROUP BY `Product Name`
											 ) AS Average_Revenue
									);

-- 3. Find top 3 products by gross profit.
WITH Highest_Profit AS 
						(
							SELECT `Product Name`,
									SUM(`Gross Profit`) AS Profit
							FROM cookie
                            GROUP BY `Product Name`
					    )
SELECT `Product Name`,
	   `Profit`
FROM Highest_Profit
ORDER BY `Profit` DESC
LIMIT 3;

-- OR

SELECT `Product Name`,
	   ROUND(SUM(`Gross Profit`),2) AS Profit
FROM cookie
GROUP BY `Product Name`
ORDER BY Profit DESC
LIMIT 3;

-- 4. Calculate revenue contribution percentage of each product.
WITH Revenue_data AS 
					(
						SELECT `Product Name`,
						       SUM(`Estimated Revenue`) AS Revenue
						FROM cookie
						GROUP BY `Product Name`
					)
SELECT `Product Name`,
	   ROUND(Revenue*100/(SELECT SUM(Revenue) FROM Revenue_data),2) AS Revenue_Percent
FROM Revenue_data;
     
-- 5. Find products contributing more than 20% of total revenue.
WITH Product_Revenue AS (
							SELECT `Product Name`,
									SUM(`Estimated Revenue`) AS Revenue
							FROM cookie
                            GROUP BY `Product Name`
						)
SELECT `Product Name`,
		ROUND(Revenue*100/(SELECT SUM(Revenue) FROM Product_Revenue),2) AS Revenue_Percent
FROM Product_Revenue
GROUP BY `Product Name`
HAVING Revenue_Percent > 20;

-- 6. Find orders having revenue greater than average revenue.
SELECT `Order_ID`, 
	   ROUND(`Estimated Revenue`,2) AS Revenue
FROM cookie
WHERE `Estimated Revenue` > 
							(
								SELECT AVG(`Estimated Revenue`)
                                FROM cookie
							)
ORDER BY `Revenue`;

-- 7. Find the retailers who generated maximum revenue.
SELECT Customer_ID,
	   SUM(`Estimated Revenue`) AS Revenue
FROM cookie
GROUP BY Customer_ID
HAVING Revenue > 0
ORDER BY Revenue DESC
LIMIT 1;

-- OR

SELECT Customer_ID,
	   SUM(`Estimated Revenue`) AS Revenue
FROM cookie
GROUP BY Customer_ID
HAVING Revenue = 
				(
					SELECT MAX(Total_Revenue)
					FROM (
							SELECT Customer_ID,
								   SUM(`Estimated Revenue`) AS Total_Revenue
							FROM cookie
                            GROUP BY Customer_ID
						 ) X
				 );
                 
-- 8.Find products with profit higher than average profit.
WITH Product_Profit AS 
						(
							SELECT `Product Name`,
									SUM(`Gross Profit`) AS Profit
							FROM cookie
							GROUP BY `Product Name`
						)
SELECT `Product Name`,
	   Profit
FROM Product_Profit
WHERE Profit > 
				(
					SELECT AVG(Profit)
					FROM Product_Profit
				);
                
-- OR

SELECT `Product Name`,
	   SUM(`Gross Profit`) AS Profit
FROM cookie
GROUP BY `Product Name`
HAVING Profit > 
				(
					SELECT AVG(Product_Profit)
                    FROM (
							SELECT `Product Name`,
								   SUM(`Gross Profit`) AS Product_Profit
							FROM cookie
                            GROUP BY `Product Name`
						 ) X
				);

-- 9. Find products selling more units than average units sold.
WITH Product_Sold AS (
						SELECT `Product Name`,
							   SUM(`Units Sold`) AS Units
						FROM cookie
                        GROUP BY `Product Name`
					 )
SELECT `Product Name`,
	   Units
FROM Product_Sold
WHERE Units > (
				SELECT AVG(Units)
                FROM Product_Sold
			  );

-- 10. Find orders with the highest revenue.
SELECT *
FROM cookie
ORDER BY `Estimated Revenue` Desc
LIMIT 1;

-- 11. Find products with total units sold above dataset average.
SELECT `Product Name`,
	   SUM(`Units Sold`) AS Units
FROM cookie
GROUP BY `Product Name`
HAVING Units > 
				(
					SELECT AVG(`Units Sold`)
                    FROM cookie
				);
                
-- 12. Find months generating revenue above overall monthly average.
SELECT MONTH(Date) Month_No,
       SUM(`Estimated Revenue`) Revenue
FROM cookie
GROUP BY MONTH(Date)
HAVING Revenue >
				(
					SELECT AVG(MonthRevenue)
					FROM (
						SELECT SUM(`Estimated Revenue`) MonthRevenue
						FROM cookie
						GROUP BY MONTH(Date)
					     ) x
				);

-- 13. Find the second highest revenue-generating product.
SELECT `Product Name`,
	   SUM(`Estimated Revenue`) AS Revenue
FROM cookie
GROUP BY `Product Name`
ORDER BY `Revenue` DESC
LIMIT 1 OFFSET 1;

-- 14. Find products whose revenue is higher than Snickerdoodle.
WITH CCRevenue AS 
				  (
					SELECT `Product Name`,
							SUM(`Estimated Revenue`) AS Revenue
					FROM cookie
                    WHERE `Product Name` = 'Snickerdoodle'
                    GROUP BY `Product Name`
				  )
SELECT `Product Name`,
	   SUM(`Estimated Revenue`) AS Revenue
FROM cookie
GROUP BY `Product Name`
HAVING Revenue > 
				 (
					SELECT Revenue
                    FROM CCRevenue
				 );
                 
-- 15. Find customer revenue ranking.
WITH Customer_Revenue AS 
						 (
							SELECT `Customer_ID`,
								   SUM(`Estimated Revenue`) AS Revenue
							FROM cookie
                            GROUP BY `Customer_ID`
						 )
SELECT ROW_NUMBER() 
	   OVER (ORDER BY Revenue DESC) AS Revenue_Rank,
	   Customer_ID,
       Revenue
FROM Customer_Revenue;

-- 16. Find products whose profit margin exceeds average margin.
WITH Product_Margin AS 
						(
							SELECT `Product Name`,
								   ROUND(SUM(`Gross Profit`)*100/SUM(`Estimated Revenue`),2) AS Margin
							FROM cookie
                            GROUP BY `Product Name`
						)
SELECT `Product Name`,
	   Margin
FROM Product_Margin
WHERE Margin > 
				(
					SELECT AVG(Margin)
                    FROM Product_Margin
				);

-- 17. Find Products Contributing to the Top 20% of Revenue.
WITH ProductRevenue AS 
					   (
							SELECT `Product Name`,
								   SUM(`Estimated Revenue`) AS Revenue
							FROM cookie
							GROUP BY `Product Name`
					   ),
RevenueRank AS 		
					(
						SELECT `Product Name`,
							   Revenue,
							   SUM(Revenue) OVER (ORDER BY Revenue DESC) AS Current_Revenue,
							   SUM(Revenue) OVER () AS Total_Revenue
						FROM ProductRevenue
					)
SELECT `Product Name`,
       Revenue,
       ROUND(Current_Revenue * 100.0 / Total_Revenue, 2) AS Cumulative_Revenue_Pct
FROM RevenueRank
WHERE Current_Revenue <= Total_Revenue * 0.20
ORDER BY Revenue DESC;

# Frequently Asked Interview Question
-- 18. Find duplicate Order IDs.
SELECT `Order_ID`,
	   COUNT(*) cnt
FROM cookie
GROUP BY `Order_ID`
HAVING cnt > 1;

-- 19. Find customers purchasing more than one product type.
SELECT `Customer_ID`,
		COUNT(DISTINCT(`Product Name`)) AS Products
FROM cookie
GROUP BY `Customer_ID`
HAVING Products > 1;

-- 20 Find monthly gross profit trend.
SELECT MONTH(Date) Month_No,
       ROUND(SUM(`Gross Profit`),2) Profit
FROM cookie
GROUP BY MONTH(Date)
ORDER BY Month_No;

-- 21. Find products whose revenue is between minimum and maximum product revenue.
WITH ProductRevenue AS (
							SELECT `Product Name`,
								   SUM(`Estimated Revenue`) Revenue
							FROM cookie
							GROUP BY `Product Name`
					   )
SELECT *
FROM ProductRevenue
WHERE Revenue > 
				(
					SELECT MIN(Revenue)
					FROM ProductRevenue
			    )
AND
Revenue < 
			(
				SELECT MAX(Revenue)
				FROM ProductRevenue
		    );

-- 22. Find customers generating revenue above average customer revenue.
SELECT Customer_ID,
       SUM(`Estimated Revenue`) AS Revenue
FROM cookie
GROUP BY Customer_ID
HAVING SUM(`Estimated Revenue`) >
									(
										SELECT AVG(CustomerRevenue)
										FROM (
												SELECT SUM(`Estimated Revenue`) AS CustomerRevenue
												FROM cookie
												GROUP BY Customer_ID
											 ) t
									);

-- 23. Find customers with more orders than average customer orders.
SELECT Customer_ID,
       COUNT(Order_ID) AS OrdersCount
FROM cookie
GROUP BY Customer_ID
HAVING COUNT(Order_ID) >
						(
							SELECT AVG(OrderCount)
							FROM (
								SELECT COUNT(Order_ID) AS OrderCount
								FROM cookie
								GROUP BY Customer_ID
							) t
						);

-- 24. Find products contributing more than 15% of total revenue
WITH ProductRevenue AS (
						SELECT `Product Name`,
							   SUM(`Estimated Revenue`) AS Revenue
						FROM cookie
						GROUP BY `Product Name`
						)
SELECT *
FROM ProductRevenue
WHERE Revenue >
				(
					SELECT SUM(Revenue) * 0.15
					FROM ProductRevenue
				);
                
-- 25. Find customers whose revenue is above the highest single order revenue.
SELECT Customer_ID,
       SUM(`Estimated Revenue`) Revenue
FROM cookie
GROUP BY Customer_ID
HAVING Revenue >
				(
					SELECT MAX(`Estimated Revenue`)
					FROM cookie
				);
                
-- 26. Find products whose average profit per product exceeds overall average.
SELECT `Product Name`,
       ROUND(AVG(`Profit Per Product`),2) AvgProfit
FROM cookie
GROUP BY `Product Name`
HAVING AVG (`Profit Per Product`) >
									(
										SELECT AVG(`Profit Per Product`)
										FROM cookie
									);
                                    
-- 27. Find customers whose order count is below average.
SELECT Customer_ID,
       COUNT(Order_ID) OrdersCount
FROM cookie
GROUP BY Customer_ID
HAVING OrdersCount <
						(
							SELECT AVG(OrderCount)
							FROM (
									SELECT COUNT(Order_ID) OrderCount
									FROM cookie
									GROUP BY Customer_ID
								 ) x
						);

-- 28. Find customers whose average order value exceeds overall average order value.
SELECT Customer_ID,
       ROUND(AVG(`Estimated Revenue`),2) AvgOrderValue
FROM cookie
GROUP BY Customer_ID
HAVING AvgOrderValue >
						(
							SELECT AVG(`Estimated Revenue`)
							FROM cookie
						);
                        
-- 29. Find products contributing to the first 80% of total revenue.
WITH ProductRevenue AS (
						SELECT `Product Name`,
							   SUM(`Estimated Revenue`) AS Revenue
						FROM cookie
						GROUP BY `Product Name`
					   ),
Pareto AS (
			SELECT `Product Name`,
				   Revenue,
				   SUM(Revenue) OVER (ORDER BY Revenue DESC) AS Running_Revenue,
				   SUM(Revenue) OVER () AS Total_Revenue
			FROM ProductRevenue
		  )
          
SELECT `Product Name`,
       Revenue,
       ROUND(Running_Revenue * 100.0 / Total_Revenue, 2) AS Cumulative_Percentage
FROM Pareto
WHERE Running_Revenue <= Total_Revenue * 0.80
ORDER BY Revenue DESC;

-- 30. Find the top 3 most profitable products.
WITH ProductProfit AS (
						SELECT `Product Name`,
							   ROUND(SUM(`Gross Profit`),2) AS Total_Profit
						FROM cookie
						GROUP BY `Product Name`
					  ),
RankedProducts AS 
				  (
					SELECT ROW_NUMBER() OVER (ORDER BY Total_Profit DESC) AS rn,
						   `Product Name`,
						   Total_Profit
					FROM ProductProfit
				  )
SELECT *
FROM RankedProducts
WHERE rn <= 3;

-- 31. Find Top 3 order IDs with most Revenue
WITH order_rev AS 
				  (
					SELECT RANK() OVER(ORDER BY `Estimated Revenue` DESC) AS Ranking,
						   `Order_ID`,
						   `Estimated Revenue` AS Total_Revenue
					FROM cookie
				  )
SELECT *
FROM order_rev
WHERE Ranking <= 3;