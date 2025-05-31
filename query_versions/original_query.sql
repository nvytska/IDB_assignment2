
SELECT 
    pct.product_category_name_english AS category,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    COUNT(DISTINCT s.seller_id) AS unique_sellers,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_approved_at)), 2) AS avg_delivery_days,
    ROUND(AVG(r.review_score), 2) AS avg_review_score

FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
JOIN product_category_name_translation pct ON p.product_category_name = pct.product_category_name
JOIN olist_orders_dataset o ON oi.order_id = o.order_id
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
JOIN olist_sellers_dataset s ON oi.seller_id = s.seller_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_approved_at IS NOT NULL
  AND p.product_category_name IN (
      SELECT product_category_name
      FROM (
          SELECT p.product_category_name, COUNT(*) AS total_orders
          FROM olist_order_items_dataset oi
          JOIN olist_products_dataset p ON oi.product_id = p.product_id
          JOIN olist_orders_dataset o ON oi.order_id = o.order_id
          WHERE o.order_status = 'delivered'
          GROUP BY p.product_category_name
          HAVING COUNT(*) > 1000
      ) AS filtered_categories
  )

GROUP BY pct.product_category_name_english

ORDER BY total_revenue DESC
LIMIT 10;
