/*
Question: Who are the top 10 sellers by total revenue generated?
Tables: order_items, sellers, orders

Logic:
- Only analyzing orders that are completed (order_status = 'delivered')
- Revenue per item = price + freight_value (excludes discounts/vouchers)
- Join order_items to orders to filter by order_status
- Join sellers to validate seller_id
- SUM(price + freight_value) grouped by seller_id
- Use RANK() to handle ties at position 10
*/

WITH clean_revenue AS (
    SELECT
        oi.seller_id,
        oi.price + oi.freight_value AS item_revenue
    FROM order_items oi
    INNER JOIN orders o
        ON o.order_id = oi.order_id
    INNER JOIN sellers s
        ON s.seller_id = oi.seller_id
    WHERE
        o.order_status = 'delivered'
),

seller_revenue_rank_metrics AS (
    SELECT
        seller_id AS seller,
        SUM(item_revenue) AS total_revenue,
        RANK() OVER (ORDER BY SUM(item_revenue) DESC) AS revenue_rank
    FROM clean_revenue
    GROUP BY 1
)

SELECT *
FROM seller_revenue_rank_metrics
WHERE revenue_rank <= 10
ORDER BY revenue_rank;