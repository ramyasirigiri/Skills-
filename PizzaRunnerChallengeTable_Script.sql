/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [order_id]
      ,[runner_id]
      ,[pickup_time]
      ,[distance]
      ,[duration]
      ,[cancellation]
  FROM [trainingsql].[PizzaRunner].[runner_orders]

  INSERT INTO [PizzaRunner].runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, 'null', 'null', 'null', 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  (9, 2, 'null', 'null', 'null', 'Customer Cancellation'),
  (1, 1, '2020-01-11 18:50:20', '10km', '10minutes', 'null');

  DROP TABLE IF EXISTS [PizzaRunner].PizzaNames;
  CREATE TABLE [PizzaRunner].PizzaNames(
										ID INT IDENTITY(1,1),
										PizzaName VARCHAR(20)
										)
INSERT INTO [PizzaRunner].PizzaNames(PizzaName)
VALUES('Meatlovers'),
	  ('Vegetarian');
SELECT * FROM [PizzaRunner].PizzaNames

DROP TABLE IF EXISTS [PizzaRunner].PizzaReceipes;
CREATE TABLE [PizzaRunner].PizzaReceipes(
							PizzaID INT,
							Toppings TEXT)
INSERT INTO [PizzaRunner].PizzaReceipes(PizzaID,Toppings)
VALUES (1,'1, 2, 3, 4, 5, 6, 8, 10'),
       (2,'4, 6, 7, 9, 11, 12');
 SELECT * FROM [PizzaRunner].PizzaReceipes 

 DROP TABLE IF EXISTS [PizzaRunner].Pizza_Toppings;
 CREATE TABLE [PizzaRunner].Pizza_Toppings( 
							ToppingID INT,
							ToppingName TEXT)
INSERT INTO [PizzaRunner].Pizza_Toppings(ToppingID,ToppingName)
VALUES  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  SELECT * FROM [PizzaRunner].Pizza_Toppings

  --PizzaRunner
DROP TABLE IF EXISTS runner_orders;
CREATE TABLE PizzaRunner.runner_orders (
  "order_id" INT,
  "runner_id" INT,
  "pickup_time" DATETIME,
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO pizzaRunner.runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, null, null, null, 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  (9, 2, null, null, null, 'Customer Cancellation'),
  (10,1, '2020-01-11 18:50:20', '10km', '10minutes', 'null');

