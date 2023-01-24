-- https://8weeksqlchallenge.com/case-study-1/
-- Danny's Diner - Case Study 1


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

"customer_id"	"product_name"	"count"	"ro"
"A"		"ramen"		3	1
"B"		"sushi"		2	1
"B"		"curry"		2	1
"B"		"ramen"		2	1
"C"		"ramen"		3	1

-- 6. Which item was purchased first by the customer after they became a member?

WITH FIRST_PRODUCT AS(
	SELECT s.customer_id, me.product_name, s.order_date,
	ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS RN
	FROM sales s
	INNER JOIN members m
	USING (customer_id)
	INNER JOIN menu me
	USING (product_id)
	WHERE s.order_date >= m.join_date)
SELECT customer_id, product_name, order_date 
FROM FIRST_PRODUCT
WHERE RN = 1;

"customer_id"	"product_name"	"order_date"
"A"		"curry"		"2021-01-07"
"B"		"sushi"		"2021-01-11"

-- 7. Which item was purchased just before the customer became a member?

WITH BEFORE_MEMBER_PRODUCT AS(
	SELECT s.customer_id, me.product_name, s.order_date,
	ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS RN
	FROM sales s
	INNER JOIN members m
	USING (customer_id)
	INNER JOIN menu me
	USING (product_id)
	WHERE s.order_date < m.join_date)
SELECT customer_id, product_name, order_date 
FROM BEFORE_MEMBER_PRODUCT
WHERE RN = 1;

"customer_id"	"product_name"	"order_date"
"A"		"sushi"		"2021-01-01"
"B"		"sushi"		"2021-01-04"

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, count(me.product_id), sum(me.price)
FROM sales s
INNER JOIN menu me
USING (product_id)
LEFT JOIN members m 
ON s.customer_id = m.customer_id WHERE s.order_date < m.join_date
GROUP BY s.customer_id

UNION

SELECT s.customer_id, count(s.product_id), sum(me.price)
FROM sales s
INNER JOIN menu me
USING (product_id)
WHERE s.customer_id NOT IN ('A', 'B')
GROUP BY s.customer_id;

"customer_id"	"count"	"sum"
"B"		3	40
"C"		3	36
"A"		2	25

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id,
	SUM(
		CASE 
			WHEN me.product_name ILIKE ('sushi') THEN (price * 20)
			WHEN me.product_name NOT ILIKE ('sushi') THEN (price * 10)
		END
	)AS total_points
FROM sales s
INNER JOIN menu me
USING (product_id)
GROUP BY s.customer_id;

"customer_id"	"total_points"
"B"		940
"C"		360
"A"		860

-- 1O. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT s.customer_id,
	SUM(
		CASE
			WHEN s.order_date < m.join_date THEN
				CASE 
					WHEN me.product_name ILIKE ('sushi') THEN (price * 20)
					WHEN me.product_name NOT ILIKE ('sushi') THEN (price * 10)
				END
			WHEN s.order_date > (m.join_date + 6) THEN
				CASE
					WHEN me.product_name ILIKE ('sushi') THEN (price * 20)
					WHEN me.product_name NOT ILIKE ('sushi') THEN (price * 20)
				END
			ELSE price * 20
		END
	)AS total_points
FROM sales s
INNER JOIN menu me
USING (product_id)
INNER JOIN members m
USING (customer_id)
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id;


"customer_id"	"total_points"
"A"		1370
"B"		940


