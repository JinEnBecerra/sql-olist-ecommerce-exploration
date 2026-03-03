/*
Question: How has average delivery time changed over time?
Table: orders

Logic:
- Data cleaning 
- Filter orders where order_status = 'delivered'
- Calculate delivery time = order_delivered_customer_date - order_purchase_timestamp
- Group by month
- AVG(delivery time) to get monthly average
- Filter out null/empty order_delivered_customer_date to avoid timestamp errors
- Filter out unusually long delivery times (> 60 days) as they likely represent operational exceptions
*/

WITH clean_orders AS (
    SELECT
        *
    FROM
        orders
    WHERE
        order_status = 'delivered'
        AND nullif(order_delivered_customer_date, '') IS NOT NULL
        AND nullif(order_purchase_timestamp, '') IS NOT NULL
        AND order_delivered_customer_date::timestamp >= order_purchase_timestamp::timestamp
        AND order_delivered_customer_date::timestamp - order_purchase_timestamp::timestamp <= INTERVAL '60 days'
),
delivery_metrics AS (
    SELECT
        date_trunc('month', order_purchase_timestamp::timestamp ) AS purchase_month,
        round(avg(date_part('day', order_delivered_customer_date::timestamp - order_purchase_timestamp::timestamp)::NUMERIC), 1) AS average_delivery_days
    FROM
        clean_orders
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
