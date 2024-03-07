-- Monthly Average User	 
SELECT year, ROUND(AVG(total_customer), 2) as average_MAU
FROM (SELECT EXTRACT(MONTH FROM order_purchase_timestamp) as month,
           EXTRACT(YEAR FROM order_purchase_timestamp) as year,
           COUNT(DISTINCT c.customer_unique_id) as total_customer
    FROM orders as o
    JOIN customers as c ON o.customer_id = c.customer_id
    GROUP BY month, year
) as total_customer_temp_table
GROUP BY year
ORDER BY year;

-- new customer per year
SELECT EXTRACT(YEAR FROM firstime_buying) as year, COUNT(1) as new_customer 
FROM (
    SELECT customer_unique_id, MIN(order_purchase_timestamp) as firstime_buying 
    FROM orders as o 
    JOIN customers as c ON o.customer_id = c.customer_id 
    GROUP BY customer_unique_id
) as firstime_buying_temp_table 
GROUP BY year
ORDER BY year;

-- repeat order customer per year
SELECT year, COUNT(DISTINCT customer_unique_id) as repeat_customer 
FROM (
    SELECT EXTRACT(YEAR FROM order_purchase_timestamp) as year, 
           customer_unique_id
    FROM orders as o 
    JOIN customers as c ON o.customer_id = c.customer_id 
    GROUP BY customer_unique_id, year 
    HAVING COUNT(*) > 1
) as repeat_customer_temp 
GROUP BY year;

-- avg frecuency order per year
SELECT year, ROUND(AVG(totals_orders), 2) as total_order 
FROM (
    SELECT EXTRACT(YEAR FROM order_purchase_timestamp) as year, 
           customer_unique_id, 
           COUNT(1) as totals_orders 
    FROM orders as o 
    JOIN customers as c ON o.customer_id = c.customer_id 
    GROUP BY customer_unique_id, year
) as total_order_temp 
GROUP BY year;

-- master table
		
WITH mau_table AS (
    SELECT year, ROUND(AVG(total_customer), 2) as average_MAU
    FROM (
        SELECT EXTRACT(MONTH FROM order_purchase_timestamp) as month,
               EXTRACT(YEAR FROM order_purchase_timestamp) as year,
               COUNT(DISTINCT c.customer_unique_id) as total_customer
        FROM orders as o
        JOIN customers as c ON o.customer_id = c.customer_id
        GROUP BY month, year
    ) as total_customer_temp_table
    GROUP BY year
    ORDER BY year
), 
new_cust AS(
    SELECT EXTRACT(YEAR FROM firstime_buying) as year, COUNT(1) as new_customer 
    FROM (
        SELECT customer_unique_id, MIN(order_purchase_timestamp) as firstime_buying 
        FROM orders as o 
        JOIN customers as c ON o.customer_id = c.customer_id 
        GROUP BY customer_unique_id
    ) as firstime_buying_temp_table 
    GROUP BY year
    ORDER BY year
), 
repeat_cust AS(
    SELECT year, COUNT(DISTINCT customer_unique_id) as repeat_customer 
    FROM (
        SELECT EXTRACT(YEAR FROM order_purchase_timestamp) as year, 
               customer_unique_id
        FROM orders as o 
        JOIN customers as c ON o.customer_id = c.customer_id 
        GROUP BY customer_unique_id, year 
        HAVING COUNT(*) > 1
    ) as repeat_customer_temp 
    GROUP BY year
    ORDER BY year
), 
avg_order AS (
    SELECT year, ROUND(AVG(totals_orders), 2) as avg_order 
    FROM (
        SELECT EXTRACT(YEAR FROM order_purchase_timestamp) as year, 
               customer_unique_id, 
               COUNT(1) as totals_orders 
        FROM orders as o 
        JOIN customers as c ON o.customer_id = c.customer_id 
        GROUP BY customer_unique_id, year
    ) as total_order_temp 
    GROUP BY year
    ORDER BY year
) 
SELECT 
    MAU.year,
    MAU.average_MAU,
    NC.new_customer,
    ROC.repeat_customer,
    AFO.avg_order
FROM 
    mau_table AS MAU
JOIN 
    new_cust AS NC ON MAU.year = NC.year
JOIN 
    repeat_cust AS ROC ON MAU.year = ROC.year
JOIN 
    avg_order AS AFO ON MAU.year = AFO.year
ORDER BY MAU.year;



