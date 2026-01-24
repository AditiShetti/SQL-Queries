-- Sales table
create table sales(
customer_id varchar (1),
order_date date,
product_id int)

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 
-- menu table 
create table menu(
product_id int,
product_name varchar(5),
price int)
INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
-- mwmbers table 
create table members(
customer_id varchar (1),
join_date date)
INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  


-- 1. What is the total amount each customer spent at the restaurant?
select s.customer_id, sum(m.price) as total_amount
from menu as m join sales as s 
on m.product_id= s.product_id
group by s.customer_id;

-- 2. How many days has each customer visited the restaurant?
select members.customer_id, count(distinct(order_date)) as visit_count
from sales join members on sales.customer_id= members.customer_id
group by members.customer_id;

-- 3. What was the first item from the menu purchased by each customer? 
 with cte as 
(select customer_id, order_date, product_name,
 dense_rank() over (partition by customer_id ORDER BY order_date) as dense_r
from menu as m join sales as s 
on m.product_id= s.product_id
)
select customer_id, order_date,product_name
from cte where dense_r= 1
group by customer_id, order_date,product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers? 
select menu.product_name,count(sales.product_id)as highest_count
from sales
join menu on sales.product_id = menu.product_id
group by  menu.product_name
order by highest_count desc;

******
-- 5. Which item was the most popular for each customer?
select sales.customer_id,count(sales.product_id) as highest_count
from sales
join menu on sales.product_id = menu.product_id
where count(sales.product_id)= max(count(sales.product_id))
group by  sales.customer_id, menu.product_name
order by highest_count desc;

with cte as (select sales.customer_id,menu.product_name,count(sales.product_id) as highest_count
from sales
join menu on sales.product_id = menu.product_id
group by sales.customer_id,menu.product_name
order by sales.customer_id,highest_count desc)
select customer_id,product_name,highest_count
from cte
where highest_count= max(highest_count)
group by customer_id
;


select current_date()
select day

**
-- 6. Which item was purchased first by the customer after they became a member?
select me.customer_id, order_date,s.product_id, m.product_name,
 rank() over(partition by me.customer_id,s.order_date order by me.customer_id) as rankk
from sales s
join members me on s.customer_id= me.customer_id and order_date > join_date 
join menu m  on m.product_id= s.product_id

select * from sales


-- 7. Which item was purchased just before the customer became a member?


-- 8. What is the total items and amount spent for each member before they became a member?
select me.customer_id,count(s.product_id) as total_items, sum(m.price) as total_price 
from sales s
join members me
on s.customer_id= me.customer_id 
join menu m 
on m.product_id= s.product_id
where s.order_date < me.join_date
group by me.customer_id
order by me.customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte as (select s.customer_id,m.price , m.product_name,
case when product_name = 'sushi' then price*20 
     else price*10 
end as points
from menu as m join sales as s 
on m.product_id= s.product_id)
select customer_id, sum(points) as total_points
from cte
group by customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?  
