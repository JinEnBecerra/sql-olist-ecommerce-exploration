/*
This query combines the results of:

01_monthly_revenue_trend.sql
02_average_order_value.sql
05_order_cancellation_rate.sql

It creates a unified dataset for Tableau so these metrics can be
visualized together in the "Business Performance Dashboard".
*/

WITH revenue_metrics AS (
    SELECT 
        DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS order_month,
        TO_CHAR(
            DATE_TRUNC('month', o.order_purchase_timestamp::timestamp),
            'Mon YYYY'
        ) AS order_month_formatted,
        SUM(p.payment_value) AS monthly_revenue
    FROM orders o
    INNER JOIN order_payments p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
),

aov_metrics AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS order_month,
        COUNT(DISTINCT o.order_id) AS order_count,
        ROUND(
            SUM(p.payment_value)::NUMERIC
            / COUNT(DISTINCT o.order_id),
            2
        ) AS aov
    FROM orders o
    INNER JOIN order_payments p
        ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
),

cancellation_metrics AS (
    SELECT
        DATE_TRUNC('month', order_purchase_timestamp::timestamp) AS order_month,
        COUNT(*) AS total_orders,
        COUNT(*) FILTER (
            WHERE order_status = 'canceled'
        ) AS cancelled_orders
    FROM orders
    WHERE
        order_purchase_timestamp IS NOT NULL
        AND order_status IN ('delivered', 'canceled')
    GROUP BY order_month
)

SELECT
    r.order_month,
    r.order_month_formatted,
    r.monthly_revenue,
    a.order_count,
    a.aov,
    c.cancelled_orders,
    c.total_orders,
    ROUND(
        c.cancelled_orders::NUMERIC
        / NULLIF(c.total_orders, 0) * 100,
        1
    ) AS cancellation_rate
FROM revenue_metrics r
LEFT JOIN aov_metrics a
    ON r.order_month = a.order_month
LEFT JOIN cancellation_metrics c
    ON r.order_month = c.order_month
ORDER BY r.order_month;