/*
Question: What is the trend of average order value (AOV) over time?
Tables used: orders, order_payments
Logic: 
- Calculate total revenue to understand overall business growth
- Calculate order volume to measure customer traffic and purchasing activity
- SUM(payment_value) / COUNT(DISTINCT order_id)to get AOV
- Only analyzing orders that are completed (order_status = 'delivered')
- Cast order_purchase_timestamp to timestamp type
- Use date_trunc to truncate to month level, then to_char to format for display
*/

WITH monthly_metrics AS (
    SELECT
        date_trunc('month', order_purchase_timestamp::timestamp) AS order_month,
        SUM(payment_value) AS monthly_revenue,
        COUNT(DISTINCT o.order_id) AS order_count,
        round(SUM(payment_value)::NUMERIC / COUNT(DISTINCT o.order_id), 2) AS aov-- cast to numeric required for ROUND, avoids double precision limitation
    FROM
        orders o
    INNER JOIN order_payments p
ON
        o.order_id = p.order_id
    WHERE
        order_status = 'delivered'
    GROUP BY
        1
)

SELECT
    to_char(order_month, 'YYYY-Mon') AS order_month_formatted,
    monthly_revenue,
    order_count,
    aov
FROM
    monthly_metrics
ORDER BY
        order_month;