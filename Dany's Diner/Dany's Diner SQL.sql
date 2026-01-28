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
  
-- members table 
create table members(
customer_id varchar (1),
join_date date)
INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
select * from sales;
select * from members;
select * from menu;
 
 
-- 1. What is the total amount each customer spent at the restaurant?
select  s.customer_id, 
		sum(m.price) as total_amount
from menu as m join sales as s 
on m.product_id= s.product_id
group by s.customer_id;


-- 2. How many days has each customer visited the restaurant?
select sales.customer_id, 
count(distinct(order_date)) as visit_count
from sales left join members on sales.customer_id= members.customer_id
group by sales.customer_id;


-- 3. What was the first item from the menu purchased by each customer?  
-- dense rank because multiple items were ordered on the same day. We dont have time given to rank one above the other
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
order by highest_count desc
limit 1;


-- 5. Which item was the most popular for each customer? max(count) aggreagate over aggregates doesnt work.
-- Dense_rank beacuse a customer can have mulyiple most ordered items.
with cte as 
(select  sales.customer_id,
		menu.product_name,
        count(sales.product_id) as product_count,
dense_rank() over(partition by customer_id order by count(sales.product_id) desc) as popular_item
from sales
join menu on sales.product_id = menu.product_id
group by sales.customer_id,menu.product_name)
select customer_id, product_name, product_count
from cte  
where popular_item= 1;


-- 6. Which item was purchased first by the customer after they became a member?
with cte as
(select me.customer_id, order_date,me.join_date,s.product_id, m.product_name,
 row_number() over(partition by me.customer_id order by s.order_date) as rankk
from sales s
join members me on s.customer_id= me.customer_id and order_date > join_date 
join menu m on m.product_id= s.product_id)
select customer_id,product_name,order_date,join_date
from cte
where rankk=1;


-- 7. Which item was purchased just before the customer became a member?
select customer_id, product_name
from
(select s.customer_id, s.order_date, me.join_date, m.product_name,
row_number() over(partition by me.customer_id order by order_date desc) as rn
from sales s
join members me on s.customer_id= me.customer_id
join menu m on s.product_id= m.product_id
where order_date< join_date) a 
where rn=1;


-- 8. What is the total items and amount spent for each member before they became a member?
select me.customer_id,
		count(s.product_id) as total_items, 
		sum(m.price) as total_price 
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


-- 10. In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi
-- how many points do customer A and B have at the end of January?  
select s.customer_id, 
		s.product_id, 
        s.order_date , 
        m.price,
    date_add(s.order_date, interval 6 day) as first_week_after_joining,
    case 
		when s.order_date between s.order_date and date_add(s.order_date, interval 7 day) then price*2 
    else price 
    end as new_sale_amt
from sales s join menu m on s.product_id= m.product_id;