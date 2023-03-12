SELECT * FROM members
SELECT * FROM sales
SELECT * FROM menu
--1. What is the total amount each customer spent at the restaurant?
--customers in the sales table, they may have loyalty card or may not.
--So did the right join from the members with sales, no customers are missed out
--cust A and B made same sale(222) and cust c made 111

SELECT s.customer_id ,
		SUM(p.price)
FROM members AS m
RIGHT OUTER JOIN sales AS s ON m.customer_id=s.customer_id
INNER JOIN menu AS p ON s.product_id=s.product_id
GROUP BY s.customer_id

--2.How many days has each customer visited the restaurant?
--cust A 6 days, cust B 6 days, cust c 3 days

SELECT s.customer_id,
	   COUNT(s.order_date)  "number of days visits"
FROM members  m
Right outer JOIN sales  s ON m.customer_id=s.customer_id
GROUP BY s.customer_id

-- 3. What was the first item from the menu purchased by each customer?
--customer A ordered two items sushi and curry
--customer B ordered one dish--curry
--customer c ordered two dishes ---ramen
SELECT s.customer_id,
	s.order_date,
	p.product_name 
FROM sales AS s
INNER JOIN menu AS p ON s.product_id=p.product_id
WHERE order_date=(SELECT MIN(order_date) FROM sales)
ORDER BY s.customer_id,
	s.order_date

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- ramen is most selling item and purchased 8 times

SELECT TOP 1 menu.product_name,
			COUNT(sales.product_id) 
FROM sales
INNER JOIN menu ON menu.product_id=sales.product_id
GROUP BY menu.product_name
ORDER BY COUNT(sales.product_id) DESC

--5.Which item was the most popular for each customer?

WITH NumberOfItemsPurchased
--retrieve how many times an item was purchased by each cusomer
AS
(
SELECT      sales.customer_id
			,menu.product_name
			,COUNT(sales.product_id) 'NumberOfPurchasesPerproduct'
FROM sales
INNER JOIN menu on menu.product_id=sales.product_id
GROUP BY sales.customer_id,menu.product_name
),
Ranking
--ranking the number of times purchasing an particular item
AS
(
SELECT customer_id,
	   product_name,
	   NumberOfPurchasesPerproduct,
	   RANK() OVER( PARTITION BY customer_id ORDER BY NumberOfPurchasesPerproduct DESC )  ranking
FROM NumberOfItemsPurchased 
)
--finally get the ranked 1 item from the list, to get the most popular item per customer
SELECT customer_id
	  ,product_name
	  ,NumberOfPurchasesPerproduct 
FROM Ranking
WHERE ranking=1


--6. Which item was purchased first by the customer after they became a member?

--first retrieve the data from the date of loyalty cards had started

WITH Afterloyalty
AS
(
SELECT m.customer_id
	  ,m.join_date
	  ,s.order_date
	  ,p.product_name 
FROM members m
INNER JOIN sales s ON m.customer_id=s.customer_id AND s.order_date>=(SELECT MIN(join_date) FROM members)
INNER JOIN menu p ON p.product_id=s.product_id
),
RankThePurchase
AS
(
SELECT customer_id
       ,order_date
	   ,product_name
	   ,rank() over(partition by customer_id order by order_date)  ranking
FROM Afterloyalty
)
--first items purchases after the loyatly card
SELECT customer_id,order_date,product_name 
FROM RankThePurchase
WHERE ranking=1

--7. Which item was purchased just before the customer became a member?

--Retrieve the sales data before the loyalty card

WITH Beforeloyalty
AS
(
SELECT m.customer_id
       ,datediff(d,s.order_date,join_date)  NumOfdays
	   ,s.order_date,join_date,p.product_name 
FROM members m
INNER JOIN sales s ON m.customer_id=s.customer_id AND s.order_date<(SELECT MIN(join_date) FROM members)
INNER JOIN menu p ON p.product_id=s.product_id
),
DaysFromLoyalty
AS
(
SELECT customer_id
	   ,join_date
	   ,order_date
	   ,product_name
	   ,NumOfdays,
       RANK()OVER(PARTITION BY customer_id ORDER BY NumOfdays) ranking 
FROM Beforeloyalty
)
--items purchased and number of days just before the loyalty
SELECT customer_id
       ,product_name
	   ,NumOfdays 
FROM DaysFromLoyalty 
WHERE ranking=1 

-- 8. What is the total items and amount spent for each member before they became a member?

WITH Beforeloyalty
--sales before the loyatly card
AS
(
SELECT m.customer_id
	   ,DATEDIFF(d,s.order_date,join_date)  NumOfdays
	   ,s.order_date
	   ,join_date
	   ,p.product_name
	   ,p.price 
FROM members m
INNER JOIN sales s ON m.customer_id=s.customer_id AND s.order_date<(SELECT MIN(join_date) FROM members)
INNER JOIN menu p ON p.product_id=s.product_id
)
--NumberOfItemsPurchased and amount spend
SELECT customer_id
       ,COUNT(product_name) 'NumberOfItemsPurchased'
	   ,SUM(price) 'AmountSpent' 
FROM Beforeloyalty
GROUP BY customer_id

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
--how many points would each customer have?

WITH Points
--calculate the points based on the item
AS
(
SELECT s.customer_id
       ,m.Product_name,
	   CASE
			WHEN product_name='sushi' THEN price*2*10
			ELSE price*10
	   END AS points
FROM sales s INNER JOIN menu m ON s.product_id=m.product_id
)
--sum the points for each customer
SELECT customer_id
       ,SUM(points) AS 'TotalNumPoints' 
FROM Points
GROUP BY customer_id

-- 10. In the first week after a customer joins the program (including their join date) 
--they earn 2x points on all items,
--not just sushi - how many points do customer A and B have at the end of January?

WITH BeforeLoyalty
--sales before loyatly
AS
(
SELECT m.customer_id
	  ,m.join_date
	  ,s.order_date,p.product_name,
	  CASE
		WHEN p.product_name='sushi' THEN p.price*10*2
		ELSE p.price*10
	 END AS points
FROM members m
INNER JOIN sales s ON m.customer_id=s.customer_id AND s.order_date<(SELECT MIN(join_date) FROM members)
INNER JOIN menu p ON p.product_id=s.product_id
),
FromloyaltyFirstWeek
--first week sales of loyalty, add 2 times of the points on all the item
AS
(
SELECT m.customer_id
	  ,m.join_date
	  ,s.order_date
	  ,p.product_name
	  ,(2*10*p.price) AS points
FROM members m
INNER JOIN sales s ON m.customer_id=s.customer_id AND s.order_date>=(SELECT MIN(join_date) FROM members)
INNER JOIN menu p ON p.product_id=s.product_id
WHERE s.order_date >=m.join_date AND s.order_date<=DATEADD(WEEK,1,m.join_date)
),
AfterFirstWeekLoyalty
--After first week add 2 times of 10 points for each dollar
--if cust buy sushi, else 10 points per each dollar 
AS
(
SELECT m.customer_id
	  ,m.join_date
	  ,s.order_date
	  ,p.product_name,
	  CASE
		WHEN p.product_name='sushi' THEN p.price*10*2
		ELSE p.price*10
	 END AS points
FROM members m
INNER JOIN sales s ON m.customer_id=s.customer_id AND s.order_date>=(SELECT MIN(join_date) FROM members)
INNER JOIN menu p ON p.product_id=s.product_id
WHERE s.order_date<'2021-02-01' AND NOT (s.order_date >=m.join_date AND s.order_date<=DATEADD(WEEK,1,m.join_date))
),
--combine all the info
combineALL
AS
(
SELECT customer_id,join_date,order_date,product_name,points FROM BeforeLoyalty
UNION ALL
SELECT customer_id,join_date,order_date,product_name,points FROM FromloyaltyFirstWeek
UNION ALL
SELECT customer_id,join_date,order_date,product_name,points FROM AfterFirstWeekLoyalty
)
--Finally total number of points by end of JAN
SELECT customer_id,sum(points) 'TotalPointsByEndOf_JAN' FROM combineALL
GROUP BY customer_id

