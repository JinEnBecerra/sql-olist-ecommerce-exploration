/*
This query combines several revenue driver analyses into a single dataset
for the "Revenue Drivers" Tableau dashboard.

The underlying analyses operate at different levels of granularity:
- revenue by state
- revenue by product category
- revenue by seller
- high-sales but low-rated product categories

Because these dimensions do not share the same grain, joining them together
would create duplicated records and distort the metrics.

Instead, the results are stacked using UNION ALL and organized with a
"dimension_type" field. This keeps each metric at its correct level while
allowing Tableau to filter and visualize different revenue drivers from
one unified dataset.

Each row represents a single dimension member (state, category, seller, etc.)
with the relevant metrics populated and the unrelated metrics left as NULL.
*/

WITH order_revenue AS (
    SELECT
        order_id,
        SUM(payment_value) AS revenue
    FROM order_payments
    GROUP BY order_id
),

state_revenue AS (
    SELECT
        'state' AS dimension_type,
        c.customer_state AS dimension,
        SUM(r.revenue) AS revenue,
        NULL::NUMERIC AS sales_volume,
        NULL::NUMERIC AS avg_rating
    FROM orders o
    INNER JOIN order_revenue r
        ON o.order_id = r.order_id
    INNER JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
),

category_revenue AS (
    SELECT
        'category' AS dimension_type,
        p.product_category_name AS dimension,
        SUM(oi.price + oi.freight_value) AS revenue,
        NULL::NUMERIC AS sales_volume,
        NULL::NUMERIC AS avg_rating
    FROM order_items oi
    INNER JOIN products p
        ON oi.product_id = p.product_id
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    WHERE
        o.order_status = 'delivered'
        AND NULLIF(p.product_category_name, '') IS NOT NULL
    GROUP BY p.product_category_name
),

seller_revenue AS (
    SELECT
        'seller' AS dimension_type,
        seller_id AS dimension,
        SUM(price + freight_value) AS revenue,
        NULL::NUMERIC AS sales_volume,
        NULL::NUMERIC AS avg_rating
    FROM order_items oi
    INNER JOIN orders o
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY seller_id
),

deduped_reviews AS (
    SELECT
        order_id,
        AVG(review_score) AS review_score
    FROM order_reviews
    GROUP BY order_id
),

low_rating_categories AS (
    SELECT
        'low_rating_category' AS dimension_type,
        p.product_category_name AS dimension,
        NULL::NUMERIC AS revenue,
        COUNT(DISTINCT o.order_id) AS sales_volume,
        ROUND(AVG(r.review_score)::NUMERIC, 2) AS avg_rating
    FROM order_items oi
    INNER JOIN orders o
        ON oi.order_id = o.order_id
    INNER JOIN products p
        ON p.product_id = oi.product_id
    INNER JOIN deduped_reviews r
        ON r.order_id = o.order_id
    WHERE
        o.order_status = 'delivered'
        AND NULLIF(p.product_category_name, '') IS NOT NULL
    GROUP BY p.product_category_name
    HAVING AVG(r.review_score) < 3.5
)

SELECT * FROM state_revenue
UNION ALL
SELECT * FROM category_revenue
UNION ALL
SELECT * FROM seller_revenue
UNION ALL
SELECT * FROM low_rating_categories;