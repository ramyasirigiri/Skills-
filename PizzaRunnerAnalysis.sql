/* PizzaRunner Challenge--Danny Dataset*/
USE trainingsql
Go
SELECT * FROM PizzaRunner.customer_orders
SELECT * FROM PizzaRunner.runner_orders

----------**PIZZA METRICS**------------

--1.How many pizzas were ordered?
--The customer order table represents each pizza sold.
SELECT COUNT(pizza_id) 
FROM PizzaRunner.customer_orders

--2.How many unique customer orders were made?
SELECT COUNT(DISTINCT(customer_id)) 
FROM PizzaRunner.customer_orders

--3.How many successful orders were delivered by each runner?
SELECT runner_id,COUNT(order_id) [NumberOfOrders] 
FROM PizzaRunner.runner_orders
WHERE cancellation NOT IN('Restaurant Cancellation','Customer Cancellation')
GROUP BY runner_id

--4.How many of each type of pizza was delivered?
SELECT pizza_id, COUNT(order_id) 
FROM PizzaRunner.customer_orders
WHERE order_id IN (SELECT order_id 
				   FROM PizzaRunner.runner_orders 
				   WHERE cancellation NOT IN ('Restaurant Cancellation','Customer Cancellation'))
GROUP BY pizza_id

--5.How many Vegetarian and Meatlovers were ordered by each customer?
--Result: Most selling product is Meatlovers pizza, ordered atleat 2 and more 
SELECT customer_id
	  ,piz.PizzaName
	  ,COUNT(Pizza_id) [number Of Orders] 
FROM PizzaRunner.customer_orders ord
LEFT OUTER JOIN PizzaRunner.PizzaNames piz ON ord.pizza_id=piz.ID
WHERE ord.order_id IN (SELECT order_id 
					   FROM PizzaRunner.runner_orders 
				       WHERE cancellation NOT IN ('Restaurant Cancellation','Customer Cancellation'))
GROUP BY customer_id, piz.PizzaName

--6.What was the maximum number of pizzas delivered in a single order?
--maximum 2 pizzas are deliveried 
SELECT customer_id
	  ,COUNT(Pizza_id) [number Of Orders] 
FROM PizzaRunner.customer_orders ord
LEFT OUTER JOIN PizzaRunner.PizzaNames piz ON ord.pizza_id=piz.ID
WHERE ord.order_id IN (SELECT order_id 
					   FROM PizzaRunner.runner_orders 
				       WHERE cancellation NOT IN ('Restaurant Cancellation','Customer Cancellation'))
GROUP BY customer_id
ORDER BY COUNT(Pizza_id)

--7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
--Only one customer didn't Change,ordered 2 Pizzas and rest of them Changed atleast 1
SELECT customer_id,sum( CASE
					WHEN exclusions = '0' THEN 0
				    ELSE 1
					END) AS exclusion,
					sum( 
						CASE 
							WHEN extras = '0' THEN 0
							ELSE 1
						END
						) 
						AS extras,COUNT(pizza_id) [NumberOfPizzas] 
FROM PizzaRunner.customer_orders 
WHERE order_id IN (SELECT order_id 
				   FROM PizzaRunner.runner_orders 
				   WHERE cancellation NOT IN ('Restaurant Cancellation','Customer Cancellation'))
GROUP BY customer_id

--8.How many pizzas were delivered that had both exclusions and extras?
--No pizzas were delivered that had both exclusions and extras
WITH DeliveryPizza
AS
(
SELECT customer_id,sum( CASE
					WHEN exclusions = '0' THEN 0
				    ELSE 1
					END) AS exclusion,
					sum( 
						CASE 
							WHEN extras = '0' THEN 0
							ELSE 1
						END
						) 
						AS extras,COUNT(pizza_id) [NumberOfPizzas] 
FROM PizzaRunner.customer_orders 
WHERE order_id IN (SELECT order_id FROM PizzaRunner.runner_orders 
				  WHERE cancellation NOT IN ('Restaurant Cancellation','Customer Cancellation'))
GROUP BY customer_id
)
SELECT SUM(CASE
		WHEN exclusion >0 AND extras>0 THEN NumberOfPizzas
		ELSE 0
		END) AS [Total Number OF Pizzas] From DeliveryPizza
--9.What was the total volume of pizzas ordered for each hour of the day?
--got some orders in between 6:00PM-11:00PM
SELECT DAY(order_time) AS [Day]
	  ,DATEPART(HOUR,order_time) AS [hour] 
	  ,COUNT(pizza_id) [Number Of Pizzas]
FROM PizzaRunner.customer_orders
GROUP BY DAY(order_time) 
	  ,DATEPART(HOUR,order_time) 
ORDER BY DAY(order_time) 

--10.What was the volume of orders for each day of the week?
SELECT  DATEPART(WEEK,order_time) AS [Week] 
	   ,DAY(order_time) AS [Day]
	   ,COUNT(pizza_id) [Number Of Pizzas]
FROM PizzaRunner.customer_orders
GROUP BY DATEPART(WEEK,order_time),DAY(order_time)  
ORDER BY DATEPART(WEEK,order_time)

--------**Runner And Cusomer Experience**----------

--1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
--Total 4 runners joined, One runner joined on start of the week, 2 in the following week and in next week 1.
SELECT * FROM PizzaRunner.Runner
SELECT * FROM PizzaRunner.runner_orders
SELECT DATEDIFF(WEEK,'2021-01-01',registration_date) [Week]
      ,COUNT(runner_id) AS[NumberOfRunners] 
FROM PizzaRunner.Runner
GROUP BY DATEDIFF(WEEK,'2021-01-01',registration_date)

--2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
--excluding the future oders( orders placed to pick up next day or after two days)
--
SELECT duration FROM PizzaRunner.runner_orders
SELECT * FROM PizzaRunner.customer_orders
SELECT run.runner_id
	  ,AVG(
	      CASE 
		  WHEN DAY(cust.order_time)!=DAY(run.pickup_time) THEN 0
		  ELSE DATEDIFF(MINUTE,cust.order_time,run.pickup_time) 
		  END) AS [AverageTimeInMinutes]
FROM PizzaRunner.runner_orders AS run
INNER JOIN PizzaRunner.customer_orders AS cust ON run.order_id=cust.order_id 
GROUP BY run.runner_id
ORDER BY run.runner_id

--3.Is there any relationship between the number of pizzas and how long the order takes to prepare?
--We can not analyse the realtionship as they is no data of order peparation time

--4.What was the average distance travelled for each customer?
SELECT cust.customer_id
	   ,AVG(cast(distance AS FLOAT))
From PizzaRunner.customer_orders AS cust
INNER JOIN PizzaRunner.runner_orders AS run ON run.order_id=cust.order_id 
GROUP BY cust.customer_id
--5. What was the difference between the longest and shortest delivery times for all orders?

SELECT  order_id
	   ,duration
	   ,duration-FIRST_VALUE (duration) OVER(ORDER BY duration) AS [Shortest_TimeDiff]
	   ,FIRST_VALUE(duration) OVER(ORDER BY duration DESC)-duration AS [Longest_TimeDiff]
FROM PizzaRunner.runner_orders
WHERE duration IS NOT NULL
ORDER BY order_id

--6.What was the average speed for each runner for each delivery and do you notice any trend for these values?
--Yes, on average, 

SELECT run.runner_id,cust.customer_id
,AVG(distance/cast(duration AS FLOAT)) AS SPEED
FROM PizzaRunner.runner_orders run
INNER JOIN PizzaRunner.customer_orders cust ON run.order_id=cust.order_id
WHERE cancellation NOT IN('Restaurant Cancellation','Customer Cancellation')
GROUP BY run.runner_id,customer_id
ORDER BY run.runner_id

--7.What is the successful delivery percentage for each runner?
--Total Orders 10(inclusing the cancelled order), 2 orders were cancelled.
--ALL Runners delivery % was 100 with not including the cancelled orders.
--IF we include the cancelled orders,only runner_id =1 was 100%
WITH TotalNumberOfDeliveriesASSIGNED
AS
(
SELECT run.runner_id,
count(*) AS [TotalNumberOfDeliveries]
FROM PizzaRunner.runner_orders run
INNER JOIN PizzaRunner.customer_orders cust ON run.order_id=cust.order_id
GROUP BY run.runner_id
),
NumberOfDeliveriesDone
AS
(
SELECT run.runner_id,
COUNT(*) AS [NumberOfDeliveries]
FROM PizzaRunner.runner_orders run
INNER JOIN PizzaRunner.customer_orders cust ON run.order_id=cust.order_id
WHERE cancellation NOT IN('Restaurant Cancellation','Customer Cancellation')
GROUP BY run.runner_id
)
SELECT tot.runner_id,
CAST((num.NumberOfDeliveries/(cast(tot.TotalNumberOfDeliveries AS DECIMAL(8,2)))) AS DECIMAL(10,2))  AS total
FROM NumberOfDeliveriesDone num
INNER JOIN TotalNumberOfDeliveriesASSIGNED tot ON tot.runner_id=num.runner_id

------**Ingredient Optimisation**-----------

--1.What are the standard ingredients for each pizza?
--SELECT * FROM [PizzaRunner].[Pizza_Toppings]
--SELECT * FROM [PizzaRunner].[PizzaReceipes]

SELECT PizzaID,
       s.VALUE,
	   t.ToppingName
INTO #t1
FROM [PizzaRunner].[PizzaReceipes]
--Split the column data by delimeter into rows
CROSS APPLY string_split(CONVERT(nvarchar(25),Toppings),',') s 
INNER JOIN [PizzaRunner].[Pizza_Toppings] AS t ON s.value=t.ToppingID

--temporary table display the list of ingredients for each pizza
SELECT * FROM #t1
 
--2 What was the most commonly added extra?

SELECT VALUE,ToppingName FROM #t1
WHERE VALUE IN( 
SELECT distinct(value) FROM [PizzaRunner].[customer_orders]
CROSS APPLY string_split(CONVERT(nvarchar(25),extras),',')
WHERE extras<>'0')  

--3.What was the most common exclusion?

SELECT VALUE,ToppingName FROM #t1
WHERE VALUE IN( 
SELECT distinct(value) FROM [PizzaRunner].[customer_orders]
CROSS APPLY string_split(CONVERT(nvarchar(25),exclusions),',')
WHERE extras<>'0')  

--4.Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
SELECT * from [PizzaRunner].[customer_orders]
--SELECT * FROM [PizzaRunner].[PizzaNames]
--SELECT * FROM  [PizzaRunner].[Pizza_Toppings]

INSERT INTO [PizzaRunner].[customer_orders](customer_id,pizza_id,exclusions,extras,order_time)
VALUES (105,(SELECT ID FROM [PizzaRunner].[PizzaNames] WHERE PizzaName='MeatLovers'),0,0,GETDATE()), 
	   (105,(SELECT ID FROM [PizzaRunner].[PizzaNames] WHERE PizzaName='MeatLovers'),
	           (SELECT ToppingID FROM [PizzaRunner].[Pizza_Toppings] WHERE ToppingName='Beef'),0,GETDATE()),
	   (105,(SELECT ID FROM [PizzaRunner].[PizzaNames] WHERE PizzaName='MeatLovers'),0,
	     (SELECT ToppingID FROM [PizzaRunner].[Pizza_Toppings] WHERE ToppingName='Bacon'),GETDATE()),
       (105,(SELECT ID FROM [PizzaRunner].[PizzaNames] WHERE PizzaName='MeatLovers'),
      (SELECT STRING_AGG(ToppingID,',')  FROM [PizzaRunner].[Pizza_Toppings] WHERE ToppingName IN ('Cheese','Bacon')),
  	  (SELECT STRING_AGG(ToppingID,',') FROM [PizzaRunner].[Pizza_Toppings] WHERE ToppingName IN ('Mushrooms','Peppers'))	
  	  ,GETDATE())

--5.Generate an alphabetically ordered comma separated ingredient list for each pizza order 
--from the customer_orders table and 
--add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

--Retrieve the exclusion list
WITH ExclusionLIst
AS
(
SELECT order_id,
	   customer_id,
	   pizza_id,
	   exclusions,
	   extras,
	   Toppings,
       (CASE
		WHEN exclusions='0' THEN Toppings
		ELSE (CASE 
		WHEN len(exclusions)=1 THEN REPLACE(Toppings,SUBSTRING(exclusions,1,2)+',','' )
		ELSE REPLACE(REPLACE(Toppings,SUBSTRING(exclusions,1,2),'' ),SUBSTRING('2, 6',3,4)+',','') END)
							END) AS list
from [PizzaRunner].[customer_orders] cust
INNER JOIN [PizzaRunner].[PizzaReceipes] rec ON cust.pizza_id=rec.PizzaID
),
--for each order, list of items
OrderList
AS
(
SELECT order_id, customer_id,pizza_id,
(CASE
WHEN extras!='0' THEN CONCAT(list,',',extras)
ELSE list
END) AS pizzaOrder
FROM ExclusionLIst list
),
--count the occurence of each item
ListOfItems
AS
(
SELECT order_id, o.pizza_id,ToppingName
,COUNT(#t1.ToppingName) AS list FROM OrderList o
CROSS APPLY STRING_SPLIT(pizzaOrder,',') string
INNER JOIN #t1 ON #t1.value=string.Value
GROUP BY order_id, o.pizza_id,ToppingName
),
--concat the list of items with number of occurence
concat_list
AS
(
SELECT order_id,pizza_id,
CASE 
WHEN list=1 THEN ToppingName
ELSE CONCAT(list,'x',ToppingName)
END AS concat_list,list FROM ListOfItems
),
--finally obtain the list of items for each pizza order
AddpizzaName
As
(
SELECT order_id,
	  pizza_id,
	  STRING_AGG(concat_list,',') AS Final_list
FROM concat_list c
GROUP BY order_id,
	     pizza_id
)
----Meatlovers:Bacon,BBQ Sauce,Beef,Cheese,Chicken,2xMushrooms,Pepperoni,Salami
SELECT order_id,
	   CONCAT((SELECT PizzaName FROM [PizzaRunner].[PizzaNames] WHERE ID=a.pizza_id),':',Final_list) AS pizza_oder
FROM AddpizzaName a


