-- https://8weeksqlchallenge.com/case-study-2/
-- Pizza Runner - Case Study 2

-- Data preparation
-- Dealing with 'null' and ''
UPDATE runner_orders SET pickup_time = NULLIF(pickup_time, 'null');

-- Change date type
ALTER TABLE runner_orders ALTER COLUMN pickup_time TYPE timestamp USING pickup_time::timestamp;

-- Remove any character exept 0-9 and dot from distance/duration column
UPDATE runner_orders SET distance = regexp_replace(distance, '[^0-9.]', '', 'g');
UPDATE runner_orders SET duration = regexp_replace(duration, '[^0-9.]', '', 'g');

-- 1. How many pizzas were ordered?

SELECT COUNT(*) as num_pizzas FROM customer_orders;

"num_pizzas"
14

-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) as unique_order FROM customer_orders;

"unique_order"
10

-- 3. How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(order_id) AS num_orders
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id
ORDER BY runner_id;

"runner_id"	"num_orders"
  1	          4
  2	          3
  3	          1
  
-- 4. How many of each type of pizza was delivered?

SELECT pn.pizza_name, COUNT(pn.pizza_name) AS num_orders
FROM customer_orders c
INNER JOIN runner_orders ro
USING (order_id)
INNER JOIN pizza_names pn
USING (pizza_id)
WHERE ro.cancellation IS NULL
GROUP BY pn.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT c.customer_id, pn.pizza_name, COUNT(pn.pizza_name) AS num_orders
FROM customer_orders c
INNER JOIN runner_orders ro
USING (order_id)
INNER JOIN pizza_names pn
USING (pizza_id)
WHERE ro.cancellation IS NULL
GROUP BY c.customer_id, pn.pizza_name
ORDER BY c.customer_id;

"customer_id"	"pizza_name"	"num_orders"
101	    "Meatlovers"	        2
102	    "Meatlovers"	        2
102	    "Vegetarian"	        1
103	    "Meatlovers"	        2
103	    "Vegetarian"	        1
104	    "Meatlovers"	        3
105 	  "Vegetarian"	        1

-- 6. What was the maximum number of pizzas delivered in a single order?

WITH CTE_MAX_PIZZAS AS(
SELECT order_id, sum(pizza_id) as MOST_PIZZAS
FROM customer_orders
GROUP BY order_id)
SELECT MAX(MOST_PIZZAS) AS HIGHEST_PIZZAS_ORDER
FROM CTE_MAX_PIZZAS;

"highest_pizzas_order"
4

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT c.customer_id,
	SUM(CASE
		WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1
		ELSE 0
	END) AS has_changes,
	SUM(CASE
		WHEN exclusions IS NULL AND extras IS NULL THEN 1
		ELSE 0
	END) AS no_changes
FROM customer_orders c
INNER JOIN runner_orders ro
USING (order_id)
WHERE ro.cancellation IS NULL
GROUP BY c.customer_id;

"customer_id"	"has_changes"	"no_changes"
101	            0	          2
102	            0	          3
103	            3	          0
104	            2	          1
105	            1	          0

-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT COUNT(c.order_id) AS SPECIFIC_PIZZA
FROM customer_orders c 
INNER JOIN runner_orders ro
USING (order_id)
WHERE c.exclusions IS NOT NULL AND c.extras IS NOT NULL AND ro.cancellation IS NULL;

"specific_pizza"
1
