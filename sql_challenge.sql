-- https://8weeksqlchallenge.com/case-study-1/
/* 
 * Danny's Diner
 * Case Study #1 Questions
 *  
*/

-- 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, sum(m.price) AS total_price
FROM sales s
INNER JOIN menu m
USING (product_id)
GROUP BY s.customer_id
ORDER BY s.customer_id;
