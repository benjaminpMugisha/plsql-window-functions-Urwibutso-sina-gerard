-- 1. Top Products per Province
SELECT province, product_name, total_revenue,    
       RANK() OVER (PARTITION BY province ORDER BY total_revenue DESC) as rank_pos
FROM (
    SELECT c.province, p.product_name, SUM(s.amount_rwf) as total_revenue
    FROM sales s
    JOIN customers c ON s.customer_id = c.customer_id
    JOIN products p ON s.product_id = p.product_id
    GROUP BY c.province, p.product_name
) sales_summary
ORDER BY province, rank_pos;
