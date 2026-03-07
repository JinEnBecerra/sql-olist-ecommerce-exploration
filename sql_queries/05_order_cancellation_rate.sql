/*
Question: How has the order cancellation rate changed over time?
Table: orders

Logic:
- Data cleaning
    - Remove rows where order_purchase_timestamp is NULL
    - Only keep orders with status 'delivered' or 'canceled'

- Group by order month to analyze trend over time
- Flag cancelled orders where order_status = 'canceled'
- Cancellation rate = COUNT(cancelled orders) / COUNT(total orders)
- Total orders only includes delivered + cancelled
*/

WITH clean_orders AS (
    SELECT
        *
    FROM
        orders
    WHERE
        NULLIF(order_purchase_timestamp, '') IS NOT NULL
        AND order_status IN ( 'delivered', 'canceled')
),
cancellation_metrics AS (
    SELECT
        DATE_TRUNC('month', order_purchase_timestamp::timestamp) AS order_month,
        COUNT(*) AS total_orders,
        COUNT(*) FILTER (WHERE order_status = 'canceled') AS cancelled_orders
    FROM
        clean_orders
    GROUP BY
        order_month
)

SELECT
    TO_CHAR(order_month, 'YYYY-Mon') AS order_month_formatted,
    cancelled_orders,
    total_orders,
    ROUND(cancelled_orders::NUMERIC / NULLIF(total_orders, 0) * 100, 1) AS cancellation_rate
FROM
    cancellation_metrics
ORDER BY
    order_month;
