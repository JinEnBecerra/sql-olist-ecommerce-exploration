/*
Question: What percentage of orders were delivered later than the estimated delivery date?

Table: orders

Logic:
- Data cleaning
- Keep only delivered orders
- Remove null delivery timestamps
- Exclude negative delivery times
- Filter out unusually long delivery durations (> 60 days) to avoid operational anomalies

- Define late delivery
- Flag orders where order_delivered_customer_date > order_estimated_delivery_date

- Calculate late delivery rate
- Late delivery rate = COUNT(late orders) / COUNT(total delivered orders)

- Add monthly segmentation
- Group by order month to analyze trend over time
*/
-- order_purchase_timestamp
-- order_delivered_customer_date
-- order_estimated_delivery_date
WITH
  clean_orders AS (
    SELECT
        *
    FROM
        orders
    WHERE
        order_status = 'delivered'
        AND NULLIF(order_purchase_timestamp, '')::timestamp IS NOT NULL
        AND NULLIF(order_delivered_customer_date, '')::timestamp IS NOT NULL
        AND NULLIF(order_estimated_delivery_date, '')::timestamp IS NOT NULL
        AND order_delivered_customer_date >= order_purchase_timestamp
        AND order_delivered_customer_date::timestamp - order_purchase_timestamp::timestamp <= INTERVAL '60 days'
),
  late_delivery_metrics AS (
    SELECT
        date_trunc('month', order_purchase_timestamp::timestamp) AS purchase_month,
        order_delivered_customer_date > order_estimated_delivery_date AS is_late
    FROM
        clean_orders
)
SELECT
    to_char(purchase_month, 'YYYY-Mon') AS purchase_month_formatted,
    count(*) FILTER (
    WHERE
        is_late = TRUE
    ) AS late_orders,
    count(*) AS total_orders,
    round(
    count(*) FILTER (
      WHERE
        is_late = TRUE
    )::NUMERIC / NULLIF(count(*), 0) * 100,
    1
  ) AS late_delivery_rate
FROM
    late_delivery_metrics
GROUP BY
    purchase_month
ORDER BY
    purchase_month