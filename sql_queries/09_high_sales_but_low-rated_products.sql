/*
Question: Which product categories have high sales volume but consistently low review scores?
Tables: order_items, order_reviews, products, orders

Logic:
- Filter orders where order_status = 'delivered'
- Deduplicate order_reviews by averaging review_score per order_id
  to avoid skewed ratings from duplicate review entries
- Join order_items to order_reviews on order_id
- Join products to get product_category_name
- Remove null or empty product categories
- Sales volume = COUNT(DISTINCT order_id)
- Average rating = AVG(review_score)
- Filter categories with average rating < 3.5
- ORDER BY sales volume DESC

In this analysis, "high sales volume" is interpreted relatively.
Categories are first filtered for low ratings (avg rating < 3.5),
and then ranked by sales volume to identify the most impactful categories.
*/

WITH deduped_reviews AS (
    SELECT
        order_id,
        AVG(review_score) AS review_score
    FROM order_reviews
    GROUP BY order_id
),

clean_data AS (
    SELECT
        o.order_id,
        p.product_category_name AS product_category,
        orv.review_score
    FROM order_items oi
    INNER JOIN orders o
        ON o.order_id = oi.order_id
    INNER JOIN deduped_reviews orv
        ON orv.order_id = oi.order_id
    INNER JOIN products p
        ON p.product_id = oi.product_id
    WHERE
        o.order_status = 'delivered'
        AND NULLIF(p.product_category_name, '') IS NOT NULL
),

product_metrics AS (
    SELECT
        product_category,
        COUNT(DISTINCT order_id) AS sales_volume,
        ROUND(AVG(review_score)::NUMERIC, 2) AS avg_rating
    FROM clean_data
    GROUP BY product_category
    HAVING AVG(review_score) < 3.5
)

SELECT
    product_category,
    sales_volume,
    avg_rating
FROM product_metrics
ORDER BY sales_volume DESC;