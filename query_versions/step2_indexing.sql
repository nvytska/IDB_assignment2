create index product_id_idx on olist_order_items_dataset(product_id);
create index order_id_idx on olist_order_items_dataset(order_id);
create index seller_id_idx on olist_order_items_dataset(seller_id);
create index category_name_idx on olist_products_dataset(product_category_name);
create index dates_idx on olist_orders_dataset(order_delivered_customer_date, order_approved_at);
create index category_name_trans_idx on product_category_name_translation(product_category_name);
create index product_id_idx_pr on olist_products_dataset(product_id);

with filtered_categories as (
select p.product_category_name, count(*) as total_orders
from olist_order_items_dataset oi force index (product_id_idx)
join olist_products_dataset p force index (product_id_idx_pr) on oi.product_id = p.product_id 
join olist_orders_dataset o on oi.order_id = o.order_id
where o.order_status = 'delivered'
group by p.product_category_name
having count(*) > 1000),

joined_data as (
select straight_join
p.product_category_name,
pct.product_category_name_english,
oi.price,
oi.freight_value,
oi.seller_id,
o.order_status,
o.order_delivered_customer_date,
o.order_approved_at,
r.review_score
from olist_order_items_dataset oi force index (product_id_idx, order_id_idx, seller_id_idx)
join olist_products_dataset p force index (category_name_idx, product_id_idx_pr) on oi.product_id = p.product_id
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
