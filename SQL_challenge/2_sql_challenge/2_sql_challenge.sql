-- https://8weeksqlchallenge.com/case-study-2/
-- Pizza Runner - Case Study 2

-- Data preparation
-- Dealing with 'null' and ''
UPDATE runner_orders SET pickup_time = NULLIF(pickup_time, 'null');

-- Change date type
ALTER TABLE runner_orders ALTER COLUMN pickup_time TYPE timestamp USING pickup_time::timestamp; 
