/*
Question: How has average delivery time changed over time?
Table: orders

Logic:
- Filter orders where order_status = 'delivered'
- Calculate delivery time = order_delivered_customer_date - order_purchase_timestamp
- Group by month
- AVG(delivery time) to get monthly average
- Filter out null/empty order_delivered_customer_date to avoid timestamp errors
*/

WITH delivery_metrics AS (
    SELECT
        date_trunc('month', order_purchase_timestamp::timestamp ) AS purchase_month,
        round(avg(date_part('day', order_delivered_customer_date::timestamp - order_purchase_timestamp::timestamp)::NUMERIC), 1) AS average_delivery_days
    FROM
        orders
    WHERE
        order_status = 'delivered'
        AND order_delivered_customer_date != ''
    GROUP BY
        1
)
    
    SELECT
    to_char(purchase_month, 'YYYY-Mon') AS purchase_month_formatted,
    average_delivery_days
FROM
    delivery_metrics
ORDER BY
    purchase_month;
