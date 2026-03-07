/*
Question: Which product categories generate the most revenue?
Tables: order_items, products, orders

Logic:
- Remove null product category
- Only analyzing orders that are completed (order_status = 'delivered')
- Revenue per item = price + freight_value (excludes discounts/vouchers)
- Join order_items to products to get product_category_name
- Join orders to filter by order_status
- SUM(price + freight_value) grouped by category
- ORDER BY revenue DESC LIMIT 5
*/

WITH clean_items AS (
    SELECT
        p.product_category_name AS category,
        oi.price + oi.freight_value AS item_revenue
    FROM order_items oi
    INNER JOIN products p ON oi.product_id = p.product_id
    INNER JOIN orders o ON oi.order_id = o.order_id
    WHERE
        NULLIF(p.product_category_name, '') IS NOT NULL
        AND o.order_status = 'delivered'
),

category_summary AS (
    SELECT
        category,
        SUM(item_revenue) AS total_revenue
    FROM clean_items
    GROUP BY 1
)

SELECT
    category,
    total_revenue
FROM category_summary
ORDER BY total_revenue DESC
LIMIT 5;