-- revenue per year

CREATE TABLE IF NOT EXISTS total_revenue_per_year AS 
SELECT 
    year, 
    ROUND(SUM(revenue), 2) AS revenue 
FROM (
    SELECT 
        EXTRACT(YEAR FROM order_purchase_timestamp) AS year, 
        price + freight_value AS revenue 
    FROM 
        orders AS o 
    JOIN 
        orders_item AS i ON o.order_id = i.order_id 
    WHERE 
        order_status = 'delivered' 
    ORDER BY 
        year, 
        revenue
) AS revenue_table_temp 
GROUP BY 
    year;
	
select * from total_revenue_per_year;


-- cancel order per year 

CREATE TABLE IF NOT EXISTS total_cancel_per_year AS 
SELECT 
    EXTRACT(YEAR FROM order_purchase_timestamp) AS year, 
    COUNT(1) AS num_canceled_orders 
FROM 
    orders 
WHERE 
    order_status = 'canceled' 
GROUP BY 1 ;

select * from total_cancel_per_year;

-- high revenue product per year

CREATE TABLE IF NOT EXISTS high_revenue_product_per_year AS 
SELECT 
    year, 
    category_product_name, 
    ROUND(revenue, 2) AS revenue 
FROM (
    SELECT 
        EXTRACT(YEAR FROM order_purchase_timestamp) AS year, 
        category_product_name, 
        SUM(price + freight_value) AS revenue, 
        RANK() OVER (PARTITION BY EXTRACT(YEAR FROM order_purchase_timestamp) ORDER BY SUM(price + freight_value) DESC) AS rank 
    FROM 
        orders_item AS i 
    JOIN 
        orders AS o ON o.order_id = i.order_id 
    JOIN 
        product AS p ON p.id_product = i.product_id 
    WHERE 
        o.order_status = 'delivered' 
    GROUP BY 
        year, 
        category_product_name
) AS product_temp_table 
WHERE 
    rank = 1;

select * from high_revenue_product_per_year;

-- most canceled product per year

CREATE TABLE IF NOT EXISTS most_canceled_product_order_per_year AS 
SELECT 
    year, 
    category_product_name, 
    num_of_canceled 
FROM (
    SELECT 
        EXTRACT(YEAR FROM order_purchase_timestamp) AS year, 
        p.category_product_name, 
        COUNT(*) AS num_of_canceled, 
        RANK() OVER (PARTITION BY EXTRACT(YEAR FROM order_purchase_timestamp) ORDER BY COUNT(*) DESC) AS rank 
    FROM 
        orders AS o 
    JOIN 
        orders_item AS i ON o.order_id = i.order_id 
    JOIN 
        product AS p ON p.id_product = i.product_id 
    WHERE 
        order_status = 'canceled' 
    GROUP BY 
        year, 
        p.category_product_name
) AS cancelled_product 
WHERE 
    rank = 1;

select * from most_canceled_product_order_per_year;

-- master table 

SELECT 
    a.year, 
    a.revenue AS revenue, 
    b.category_product_name AS product_high_revenue, 
    b.revenue AS total_revenue, 
    d.num_canceled_orders AS total_cancel_per_year, 
    c.category_product_name AS most_product_canceled, 
    c.num_of_canceled AS total_cancelled_order 
FROM 
    total_revenue_per_year AS a 
JOIN 
    high_revenue_product_per_year AS b ON a.year = b.year 
JOIN 
    most_canceled_product_order_per_year AS c ON b.year = c.year 
JOIN 
    total_cancel_per_year AS d ON c.year = d.year;

