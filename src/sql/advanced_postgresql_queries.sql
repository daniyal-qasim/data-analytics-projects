-- Advanced CTE with Window Functions & Conditional Aggregation
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        region,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(order_amount) AS total_sales,
        AVG(order_amount) AS avg_order_value
    FROM orders
    GROUP BY 1, 2
),
ranked_regions AS (
    SELECT 
        month,
        region,
        total_orders,
        total_sales,
        avg_order_value,
        RANK() OVER (PARTITION BY month ORDER BY total_sales DESC) AS region_rank
    FROM monthly_sales
)
SELECT 
    month,
    region,
    total_orders,
    total_sales,
    avg_order_value,
    CASE 
        WHEN region_rank = 1 THEN 'Top Performer'
        WHEN region_rank <= 3 THEN 'High Performer'
        ELSE 'Needs Improvement'
    END AS performance_category
FROM ranked_regions
ORDER BY month DESC, region_rank;
