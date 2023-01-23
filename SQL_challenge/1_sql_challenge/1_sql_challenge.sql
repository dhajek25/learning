-- https://8weeksqlchallenge.com/case-study-1/
/* 
 * Danny's Diner
 * Case Study #1 Questions
 *  
*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, SUM(m.price) AS total_price
FROM sales s
INNER JOIN menu m
USING (product_id)
GROUP BY s.customer_id
ORDER BY s.customer_id;

"A"	76
"B"	74
"C"	36

-- 2. How many days has each customer visited the restaurant?

SELECT s.customer_id, COUNT(DISTINCT s.order_date) AS num_days_visits
FROM sales s
INNER JOIN menu m
USING (product_id)
GROUP BY s.customer_id
ORDER BY s.customer_id;

"A"	4
"B"	6
"C"	2

-- 3. What was the first item from the menu purchased by each customer?

WITH CTE_FIRST_MEAL AS(
	SELECT s.customer_id, s.order_date, m.product_name AS first_meal,
	ROW_NUMBER() OVER (PARTITION BY s.customer_id) AS RN
	FROM sales s
	INNER JOIN menu m
	USING (product_id)
	WHERE order_date IN 
		(SELECT min(s.order_date) as min_date
		FROM sales s 
		GROUP BY s.customer_id))
SELECT customer_id, order_date, first_meal
FROM CTE_FIRST_MEAL
WHERE RN =1;

"customer_id"	"order_date"	"first_meal"
"A"	          "2021-01-01"	  "sushi"
"B"	          "2021-01-01"	  "curry"
"C"	          "2021-01-01"	  "ramen"

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name, COUNT(s.product_id) AS count_product
FROM sales s
INNER JOIN menu m
USING(product_id)
GROUP BY m.product_name
ORDER BY count_product DESC
LIMIT 1;

"product_name"	"count_product"
"ramen"		8

-- 5. Which item was the most popular for each customer?

WITH TOP_PRODUCT_BY_CUSTOMER AS (
	SELECT s.customer_id, m.product_name, COUNT(m.product_name),
	RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(m.product_name) DESC) AS RO
	FROM sales s
	INNER JOIN menu m
	USING (product_id)
	GROUP BY s.customer_id, m.product_name)
SELECT * 
FROM TOP_PRODUCT_BY_CUSTOMER
WHERE RO = 1;
