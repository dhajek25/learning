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

