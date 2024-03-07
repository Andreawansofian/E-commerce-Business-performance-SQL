--checking duplicate value
select * from customers;
select customer_id, customer_unique_id, customer_zip_code_prefix, count(*)
from customers
group by 1, 2, 3
having count(*) > 1;

select * from geolocation;
select geolocation_zip_code_prefix, geolocation_lat, geolocation_lng,  count(*)
from geolocation
group by 1, 2, 3
having count(*) > 1;

-- handling duplicate on geolocation
delete from geolocation
where geolocation_zip_code_prefix not in (
										 select min(geolocation_zip_code_prefix)
										 from geolocation
										 group by geolocation_zip_code_prefix
										 );


select * from order_payment;
select order_id, count(*)
from order_payment
group by 1
having count(*) > 1;

select * from order_reviews1;
select review_id, count(*)
from order_reviews1
group by 1
having count(*) > 1;

select * from orders;
select order_id, customer_id, order_purchase_timestamp, count(*)
from orders
group by 1, 2, 3
having count(*) > 1;

select * from orders_item;
select order_id, product_id, seller_id, count(*)
from orders_item
group by 1, 2, 3
having count(*) > 1;

select * from product;
select  product_id, count(*)
from orders_item
group by 1
having count(*) > 1;

-- drop index column in product table
alter table product
drop column index_num;

select * from sellers;
select  seller_id, count(*)
from sellers
group by 1
having count(*) > 1;

