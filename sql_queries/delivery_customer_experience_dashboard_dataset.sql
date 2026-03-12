/*
This query combines the results of:

03_average_delivery_time.sql
04_late_delivery_rate.sql
10_rating_vs_delivery_time.sql

It creates a unified dataset for Tableau so delivery performance
and customer experience metrics can be visualized together in the
"Delivery and Customer Experience Dashboard".

The dashboard uses purchase_month as the mutual filter
to analyze operational performance over time.
*/

WITH delivery_metrics AS (
    SELECT
        DATE_TRUNC('month', NULLIF(order_purchase_timestamp,'')::timestamp) AS purchase_month,
        ROUND(
            AVG(
                DATE_PART(
                    'epoch',
                    NULLIF(order_delivered_customer_date,'')::timestamp
                    - NULLIF(order_purchase_timestamp,'')::timestamp
                ) / 86400
            )::NUMERIC,
            1
        ) AS avg_delivery_days
    FROM orders
    WHERE
        order_status = 'delivered'
        AND NULLIF(order_purchase_timestamp,'') IS NOT NULL
        AND NULLIF(order_delivered_customer_date,'') IS NOT NULL
        AND NULLIF(order_delivered_customer_date,'')::timestamp 
            >= NULLIF(order_purchase_timestamp,'')::timestamp
        AND NULLIF(order_delivered_customer_date,'')::timestamp
            - NULLIF(order_purchase_timestamp,'')::timestamp <= INTERVAL '60 days'
    GROUP BY purchase_month
),

late_delivery_metrics AS (
    SELECT
        DATE_TRUNC('month', NULLIF(order_purchase_timestamp,'')::timestamp) AS purchase_month,
        COUNT(*) FILTER (
            WHERE NULLIF(order_delivered_customer_date,'')::timestamp
                > NULLIF(order_estimated_delivery_date,'')::timestamp
        ) AS late_orders,
        COUNT(*) AS total_orders
    FROM orders
    WHERE
        order_status = 'delivered'
        AND NULLIF(order_purchase_timestamp,'') IS NOT NULL
        AND NULLIF(order_delivered_customer_date,'') IS NOT NULL
        AND NULLIF(order_estimated_delivery_date,'') IS NOT NULL
        AND NULLIF(order_delivered_customer_date,'')::timestamp
            >= NULLIF(order_purchase_timestamp,'')::timestamp
        AND NULLIF(order_delivered_customer_date,'')::timestamp
            - NULLIF(order_purchase_timestamp,'')::timestamp <= INTERVAL '60 days'
    GROUP BY purchase_month
),

review_metrics AS (
    SELECT
        DATE_TRUNC('month', NULLIF(o.order_purchase_timestamp,'')::timestamp) AS purchase_month,
        ROUND(AVG(r.review_score)::NUMERIC, 2) AS avg_review_score
    FROM orders o
    INNER JOIN order_reviews r
        ON o.order_id = r.order_id
    WHERE
        o.order_status = 'delivered'
        AND NULLIF(o.order_purchase_timestamp,'') IS NOT NULL
        AND r.review_score IS NOT NULL
    GROUP BY purchase_month
)

SELECT
    d.purchase_month,
    TO_CHAR(d.purchase_month, 'Mon YYYY') AS purchase_month_formatted,
    d.avg_delivery_days,
    ROUND(
        l.late_orders::NUMERIC
        / NULLIF(l.total_orders, 0) * 100,
        1
    ) AS late_delivery_rate,
    r.avg_review_score
FROM delivery_metrics d
LEFT JOIN late_delivery_metrics l
    ON d.purchase_month = l.purchase_month
LEFT JOIN review_metrics r
    ON d.purchase_month = r.purchase_month
ORDER BY d.purchase_month;