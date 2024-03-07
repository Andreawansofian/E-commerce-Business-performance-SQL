-- alltime favourite payment type

SELECT 
    payment_type, 
    COUNT(payment_type) AS num_used 
FROM 
    order_payment AS op 
JOIN 
    orders AS o ON o.order_id = op.order_id 
GROUP BY 
    payment_type 
ORDER BY 
    COUNT(payment_type) DESC;
	
-- Payment detail per year

WITH payment_temp_table AS (
    SELECT 
        EXTRACT(YEAR FROM order_purchase_timestamp) AS year, 
        payment_type, 
        COUNT(1) AS num_used 
    FROM 
        order_payment AS op 
    JOIN 
        orders AS o ON o.order_id = op.order_id 
    GROUP BY 
        year, 
        payment_type
) 
SELECT 
    *, 
    CASE 
        WHEN y_2017 = 0 THEN NULL
        ELSE ROUND((y_2018 - y_2017) / y_2017, 2) 
    END AS pct_change 
FROM (
    SELECT 
        payment_type, 
        SUM(CASE WHEN year = 2016 THEN num_used ELSE 0 END) AS y_2016, 
        SUM(CASE WHEN year = 2017 THEN num_used ELSE 0 END) AS y_2017, 
        SUM(CASE WHEN year = 2018 THEN num_used ELSE 0 END) AS y_2018 
    FROM 
        payment_temp_table 
    GROUP BY 
        payment_type
) AS pivot_payment;



