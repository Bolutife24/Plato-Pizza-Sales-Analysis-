USE Portfolio

--To obtain information about the tables in the database
SELECT *
FROM Portfolio.INFORMATION_SCHEMA.TABLES

-- To obtain a list of the actual table names
SELECT TABLE_NAME
FROM Portfolio.INFORMATION_SCHEMA.TABLES

-- Exploring The Data

--1. Inspect each table in the  database by selecting the top 20 rows
SELECT TOP 20*
FROM orders_info

SELECT TOP 20*
FROM order_details_info

SELECT TOP 20*
FROM pizza

SELECT TOP 20*
FROM pizza_type

--2. How many records do we have in each table?
-- There are 21,350 records from the orders info table
SELECT 
	COUNT(*) AS orders_row_count
FROM orders_info

-- There are 48,620 records from the orders details info table
SELECT 
	COUNT(*) AS orders_details_row_count
FROM order_details_info

-- There are 96 records from the pizza row count table
SELECT 
	COUNT(*) AS pizza_row_count
FROM pizza

-- There are 32 records from the pizza type table
SELECT 
	COUNT(*) AS pizza_type_row_count
FROM pizza_type

--3. How many pizzas were ordered?
-- There are 48,620 pizzas ordered
SELECT 
	COUNT(*) AS pizza_order_count
FROM order_details_info

--4. How many unique customer orders were made?
-- There are 21,350 unique orders

SELECT 
	COUNT(DISTINCT order_id) AS unique_pizza_orders
FROM order_details_info

--5. Which pizza category is avaliable in the dataset and how many were ordered?
-- The four pizza categories are Chicken, classic, supreme, and veggie.

SELECT
	category,
	COUNT( category) AS category_count
FROM pizza_type
GROUP BY
	category

--6. How many ingredients are present in the pizza and list them?
-- There are 32 different ingredients present in the pizza
SELECT
	ingredients,
	COUNT(ingredients) OVER(PARTITION BY ingredients) AS ingredients_count
FROM pizza_type

--7. What is the total quantity of pizza sold?
-- There are 49,574 pizzas sold

SELECT
	SUM(quantity) AS total_pizza_sold
FROM (SELECT
		quantity AS quantity
	 FROM order_details_info) AS subquery

--8. What is the total revenue generated and the average price of the pizza sold?
-- Total revenue is $817860.05 and avg price is $16.49

WITH total_revenue AS (
SELECT
	orders.quantity,
	pizza.price,
	orders.quantity * pizza.price AS revenue
FROM order_details_info AS orders
INNER JOIN pizza AS pizza
	ON orders.pizza_id = pizza.pizza_id
)

SELECT 
	ROUND(SUM(revenue), 2) AS total_revenue,
	ROUND(AVG(price), 2) AS avg_price
FROM total_revenue

--9. What are the best and least sold pizzas?
-- The most sold pizza is the Classic Deluxe pizza and the least sold is the Brie Carre pizza

SELECT
	pizza_type.name,
	COUNT(orders.quantity) AS pizza_count
FROM pizza_type AS pizza_type
INNER JOIN pizza AS pizza
	ON pizza_type.pizza_type_id = pizza.pizza_type_id
INNER JOIN order_details_info AS orders
	ON pizza.pizza_id = orders.pizza_id
GROUP BY
	pizza_type.name
ORDER BY
	COUNT(orders.quantity)

-- 10. Which pize size was the most and least sold?
-- Based on the size, large pizzas were the most sold and the least sold is XXL 

SELECT
	pizza.size,
	COUNT(orders.quantity) AS quantity_sold
FROM pizza AS pizza
INNER JOIN order_details_info AS orders
	ON pizza.pizza_id = orders.pizza_id
GROUP BY
	pizza.size
ORDER BY
	COUNT(orders.quantity)

;

--create a temp table to answer the questions below
-- the # is added because i created a temp table. Removal of the # sign before the table name will create a permanent table to the database
IF OBJECT_ID('portfolio..#pizza_seasonility_info') IS NOT NULL 
    DROP TABLE #pizza_seasonility_info;
    
SELECT
	order_details_info.order_id,
	orders_info.date,
	YEAR(orders_info.date) AS Yr,
	DATEPART(QUARTER, orders_info.date) AS Quarter_of_yr,
	MONTH(orders_info.date) AS Month_of_yr,
	DATENAME(MONTH, orders_info.date) AS month_name,
	DATENAME(dw, orders_info.date) AS day_of_week_name,
	orders_info.time,
	DATEPART(HOUR, orders_info.time) AS Hour_of_day,
	order_details_info.quantity,
	pizza.price,
	order_details_info.quantity * pizza.price AS revenue
INTO #pizza_seasonility_info
FROM orders_info AS orders_info
INNER JOIN order_details_info AS order_details_info
	ON orders_info.order_id = order_details_info.order_id
INNER JOIN pizza AS pizza
	ON pizza.pizza_id = order_details_info.pizza_id

SELECT TOP 10*
FROM #pizza_seasonility_info

--use the temp table created above to answer the following questions

--11. What is the count and total quantity of unique pizza orders by quarter, month, day, and time(hour)?

-- a. By quarter
-- Quarter 4 had the lowest pizza orders and quantity sold.
--Quarter 3 had the highest number of orders while Quarter 2 had the highest quantity of pizza sold

SELECT  
		Quarter_of_yr,
		COUNT(DISTINCT order_id) AS unique_orders_count,
		SUM(quantity) AS total_qty
FROM #pizza_seasonility_info
GROUP BY 
	Quarter_of_yr
ORDER BY
	COUNT(DISTINCT order_id),
	SUM(quantity) DESC

-- b. By month 
-- July had the higest number of unique orders and the total quantity sold. 
-- October had the least number of orders and total quantity sold.
SELECT  
		month_name,
		COUNT(DISTINCT order_id) AS unique_orders_count,
		SUM(quantity) AS total_qty
FROM #pizza_seasonility_info
GROUP BY 
	month_name
ORDER BY
	COUNT(DISTINCT order_id),
	SUM(quantity) DESC

-- c. By day of week

-- Fridays had the greatest orders and total quantity sold, whereas Sundays had the least orders and total quantity sold.

SELECT  
		day_of_week_name,
		COUNT(DISTINCT order_id) AS unique_orders_count,
		SUM(quantity) AS total_qty
FROM #pizza_seasonility_info
GROUP BY 
	day_of_week_name
ORDER BY
	COUNT(DISTINCT order_id),
	SUM(quantity) DESC


--d. By hour of the day
-- The busiest time was by 12pm and the time with the least number of orders was by 9am
SELECT  
		Hour_of_day,
		COUNT(DISTINCT order_id) AS unique_orders_count,
		SUM(quantity) AS total_qty,
		AVG(quantity) AS avg_qty
FROM #pizza_seasonility_info
GROUP BY 
	Hour_of_day
ORDER BY
	Hour_of_day,
	COUNT(DISTINCT order_id),
	SUM(quantity) DESC


--12. What is the total revenue generated by quarter, month, and time(hour)?

--a. By quarter
-- Quarter 2 made the highest total revenue while Quarter 4 made the lowest revenue. 
-- There was a 1.4% increase in total revenue in Quarter 2, whereas Quarter 3 and 4 experienced a decrease in total revenue.
 
WITH reveue_quarter AS(
SELECT
	Quarter_of_yr,
	ROUND(SUM(revenue), 2) AS total_revenue
	
FROM #pizza_seasonility_info
GROUP BY
	Quarter_of_yr 
)
SELECT 
	Quarter_of_yr,
	total_revenue,
	LAG(total_revenue) OVER (ORDER BY Quarter_of_yr) AS prev_quarter_revenue,
	ROUND(((( total_revenue- LAG(total_revenue) OVER (ORDER BY Quarter_of_yr) )/ total_revenue) *100), 1) AS revenue_percent,
		
CASE
	WHEN LAG(total_revenue) OVER (ORDER BY Quarter_of_yr ) <  total_revenue THEN 'Total revenue increased'
	WHEN LAG(total_revenue) OVER (ORDER BY Quarter_of_yr) > total_revenue  THEN 'Total revenue decreased'
	ELSE 'Total revenue is same as last quarter' END AS 'Revenue Increase/Derease'

FROM reveue_quarter
;
--b.  By month
-- The month with the greatest total revenue was July but November had the most significant percentage increase in total revenue.
-- The lowest total revenue was generated in October.

WITH monthly_revenue AS(
SELECT
	Month_of_yr,
	month_name,
	ROUND(SUM(revenue), 2) AS total_revenue
	
FROM #pizza_seasonility_info
GROUP BY
	Month_of_yr,
	month_name
)
SELECT 
	month_name,
	total_revenue AS current_month_revenue,
	LAG(total_revenue) OVER (ORDER BY Month_of_yr) AS prev_month_revenue,
	ROUND(((( total_revenue- LAG(total_revenue) OVER (ORDER BY Month_of_yr) )/ total_revenue) *100), 1) AS revenue_percent,
		
CASE
	WHEN LAG(total_revenue) OVER (ORDER BY Month_of_yr) <  total_revenue THEN 'Total revenue increased'
	WHEN LAG(total_revenue) OVER (ORDER BY Month_of_yr) > total_revenue  THEN 'Total revenue decreased'
	ELSE 'Total revenue is same as last month' END AS 'Revenue Increase/Derease'
FROM monthly_revenue
ORDER BY Month_of_yr;
;

-- c. By hour
-- The hours of the day that experienced increased revenue were 10am, 11am, 12am, 4pm, 5pm and 6pm
-- The hour with the greatest revenue generated was by 12pm but the greatest percent increase in revenue was by 11am.
-- The hour with the least revenue generated was by 9am but the greatest percent decrease in revenue was by 11pm

WITH hourly_revenue AS(
SELECT
	Hour_of_day,
	ROUND(SUM(revenue), 2) AS total_revenue
	
FROM #pizza_seasonility_info
GROUP BY
	Hour_of_day
)
SELECT 
	Hour_of_day,
	total_revenue AS current_total_revenue,
	LAG(total_revenue) OVER (ORDER BY Hour_of_day) AS prev_hour_revenue,
	ROUND(((( total_revenue- LAG(total_revenue) OVER (ORDER BY Hour_of_day) )/ total_revenue) *100), 1) AS revenue_percent,
		
CASE
	WHEN LAG(total_revenue) OVER (ORDER BY Hour_of_day ) <  total_revenue THEN 'Total revenue increased'
	WHEN LAG(total_revenue) OVER (ORDER BY Hour_of_day) > total_revenue  THEN 'Total revenue decreased'
	ELSE 'Total revenue is same as last hour' END AS 'Revenue Increase/Derease'
FROM hourly_revenue
ORDER BY
	Hour_of_day 
;


	

