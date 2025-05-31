with filtered_categories as (
select p.product_category_name, count(*) as total_orders
from olist_order_items_dataset oi
join olist_products_dataset p on oi.product_id = p.product_id
join olist_orders_dataset o on oi.order_id = o.order_id
where o.order_status = 'delivered'
group by p.product_category_name
having count(*) > 1000),

joined_data as (
select 
p.product_category_name,
pct.product_category_name_english,
oi.price,
oi.freight_value,
oi.seller_id,
o.order_status,
o.order_delivered_customer_date,
o.order_approved_at,
r.review_score
from olist_order_items_dataset oi
join olist_products_dataset p on oi.product_id = p.product_id
join product_category_name_translation pct on p.product_category_name = pct.product_category_name
join olist_orders_dataset o on oi.order_id = o.order_id
left join olist_order_reviews_dataset r on o.order_id = r.order_id
where o.order_status = 'delivered'
and o.order_delivered_customer_date is not null
and o.order_approved_at is not null
)


select
jd.product_category_name_english as category,
  round(sum(jd.price + jd.freight_value), 2) as total_revenue,
  count(distinct jd.seller_id) as unique_sellers,
  round(avg(datediff(jd.order_delivered_customer_date, jd.order_approved_at)), 2) as avg_delivery_days,
  round(avg(jd.review_score), 2) as avg_review_score

from joined_data jd
join filtered_categories fc on jd.product_category_name = fc.product_category_name

group by jd.product_category_name_english
order by total_revenue desc
limit 10;
