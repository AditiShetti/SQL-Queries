                                              SQL PRACTICE QUESTIONS

# ORDER OF EXECUTION
-- from -> join -> where -> groupby -> aggregate -> having -> select -> distinct -> orderby -> limit -> offset


-- WALMART - Retrieve users' most recent transaction date,user ID & the total number of products they purchased
CREATE TABLE transactions (
    product_id INT,
    user_id INT,
    spend DECIMAL(10, 2),
    transaction_date DATETIME
);
INSERT INTO transactions (product_id, user_id, spend, transaction_date)
VALUES
(3673, 123, 68.90, '2022-07-08 10:00:00'),
(9623, 123, 274.10, '2022-07-08 10:00:00'),
(1467, 115, 19.90, '2022-07-08 10:00:00'),
(2513, 159, 25.00, '2022-07-08 10:00:00'),
(1452, 159, 74.50, '2022-07-10 10:00:00'),
(1452, 123, 74.50, '2022-07-10 10:00:00'),
(9765, 123, 100.15, '2022-07-11 10:00:00'),
(6536, 115, 57.00, '2022-07-12 10:00:00'),
(7384, 159, 15.50, '2022-07-12 10:00:00'),
(1247, 159, 23.40, '2022-07-12 10:00:00');  
select * from transactions;
-- transaction date,user id, total products
with cte as 
(select product_id,
		user_id ,
        transaction_date ,
 rank() over (partition by user_id order by transaction_date desc) as rn
from transactions)
select user_id ,
	   transaction_date,
       count(product_id) as prod_count
 from cte where rn = 1
 group by user_id , transaction_date

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- ZOMATO SQL Qn
-- Calculate the average rating for each restaurant for each month. 
CREATE TABLE reviews (
    review_id INT PRIMARY KEY,
    user_id INT,
    submit_date DATE,
    restaurant_id INT,
    rating INT
);
INSERT INTO reviews (review_id, user_id, submit_date, restaurant_id, rating) VALUES
(1001, 501, '2022-01-15', 101, 4),
(1002, 502, '2022-01-20', 101, 5),
(1003, 503, '2022-01-25', 102, 3),
(1004, 504, '2022-01-15', 102, 4),
(1005, 505, '2022-02-20', 101, 5),
(1006, 506, '2022-02-26', 101, 4),
(1007, 507, '2022-03-01', 101, 4),
(1008, 508, '2022-03-05', 102, 2);
select * from reviews

select restaurant_id, avg(rating) as avg_rating, extract(month from submit_date) as month 
from reviews 
group by restaurant_id, month

select month(submit_date) as month,
  avg(rating) as avg_rating,
  restaurant_id
from reviews
group by restaurant_id, month
having count(review_id) >= 2

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- McKinsey
-- 
CREATE TABLE npv (
    id INT,
    year INT,
    npv DECIMAL(10, 2)
);
INSERT INTO npv (id, year, npv)
VALUES 
(1, 2018, 100),
(7, 2020, 30),
(13, 2019, 40),
(1, 2019, 113),
(2, 2008, 121),
(3, 2009, 12),
(11, 2020, 99),
(7, 2019, 0); 
CREATE TABLE queries (
    id INT,
    year INT
);
INSERT INTO queries (id, year) VALUES
(1, 2019),
(2, 2008),
(3, 2009),
(7, 2018),
(7, 2019),
(7, 2020),
(13, 2019);

select q.*, round(coalesce(n.npv,0),0) as npv  # Coalesce() to map NULL walues to a value
from queries q                                # Can use IFNULL also 
left join npv n 
on n.id= q.id and n.year= q.year
order by q.id

select q.*, round(ifnull(n.npv,0),0) as npv  
from queries q
left join npv n 
on n.id= q.id and n.year= q.year
order by q.id

-- Using CASE , IF not null then npv else 0

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# FIND SELLERS WHO HAVENT MADE ANY SALE IN 2020
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    sale_date DATE,
    order_cost DECIMAL(10, 2),
    customer_id INT,
    seller_id INT
);
INSERT INTO orders (order_id, sale_date, order_cost, customer_id, seller_id) VALUES
(1, '2020-03-01', 1500.00, 101, 1),
(2, '2020-05-25', 2400.00, 102, 2),
(3, '2019-05-25', 800.00, 101, 3),
(4, '2020-09-13', 1000.00, 103, 2),
(5, '2019-02-11', 700.00, 101, 2);
select * from orders

CREATE TABLE sellers (
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(100)
);
INSERT INTO sellers (seller_id, seller_name) VALUES
(1, 'Daniel'),
(2, 'Ben'),
(3, 'Frank');
select * from sellers

-- 1.LEFT JOIN WITH TABLE HAVING YEAR 2020  
select *
from sellers s 
left join(
          select distinct seller_id
          from orders 
          where year(sale_date) = 2020) o  
          on s.seller_id = o.seller_id
          where o.seller_id IS NULL

2. SUBQUERY
select seller_name, seller_id
from sellers
where seller_id not in 
                      (select seller_id
                       from orders
                       where year(sale_date) = 2020)
                       
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#SUM OF REPEAT CUSTOMERS AND NEW ONES
CREATE TABLE customer_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_amount INT
);
select * from customer_orders;
INSERT INTO customer_orders (order_id, customer_id, order_date, order_amount) VALUES
(1, 100, '2022-01-01', 2000),
(2, 200, '2022-01-01', 2500),
(3, 300, '2022-01-01', 2100),
(4, 100, '2022-01-02', 2000),
(5, 400, '2022-01-02', 2200),
(6, 500, '2022-01-02', 2700),
(7, 100, '2022-01-03', 3000),
(8, 400, '2022-01-03', 1000),
(9, 600, '2022-01-03', 3000);

-- using cte WRONG output
 with cust as
(
select count(*) as all_cust, customer_id
from customer_orders
group by customer_id 
),
final_cust as 
(
select customer_id, 
case when all_cust = 1 then 'new' else 'repeat cust' end as cust_type,
case when all_cust = 1 then 1 else 0 end as new_cust,
case when  all_cust != 1 then 1 else 0 end as repeat_cust
from cust
)
select  sum(new_cust), sum(repeat_cust)
from final_cust

-- diff answers as approach differs     
with cte1 as(
select customer_id, min(order_date) as first_visited 
from customer_orders
group by customer_id
),
cte2 as
(select co.*, cte1.first_visited,
 case when order_date = first_visited then 1 else 0 end as first_visit_flag,
 case when order_date != first_visited then 1 else 0 end as repeat_visit_flag
from customer_orders co
 join cte1 on co.customer_id= cte1.customer_id
 )
select order_date, sum(first_visit_flag) as new_cust, sum(repeat_visit_flag) as repeat_cust
from cte2 group by order_date


-- using window function
select * from customer_orders

with window_cust as
(select customer_id, order_date,
   row_number() over(partition by customer_id order by order_date) as rn
from customer_orders)
select sum(case when rn=1 then 1 else 0 end) as new_cust, 
       sum(case when rn>1 then 1 else 0 end) as repeat_cust
from window_cust 

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# UBER 
--  find a user's third transaction using SQL window functions.
CREATE TABLE transactions_1 (
  user_id INT,
  spend DECIMAL(10,2),
  transaction_date DATETIME
);
INSERT INTO transactions_1 (user_id, spend, transaction_date)
VALUES
  (111, 100.50, '2022-01-08 12:00:00'),
  (111, 55, '2022-01-10 12:00:00'),
  (121, 36, '2022-01-18 12:00:00'),
  (145, 24.99, '2022-01-26 12:00:00'),
  (111, 89.60, '2022-02-05 12:00:00'); 
  select * from transactions_1
  with cte1 as (
  select user_id, spend, transaction_date ,
   dense_rank() over(partition by user_id order by transaction_date) as dense_rn
  from transactions_1 )
  select user_id, spend, transaction_date
  from cte1 where dense_rn = 3

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#AMAZON
-- find the top two highest-selling products within each category based on total spending
CREATE TABLE ProductSpend (
    category VARCHAR(50),
    product VARCHAR(100),
    user_id INT,
    spend DECIMAL(10, 2)
);
INSERT INTO ProductSpend (category, product, user_id, spend) VALUES
('appliance', 'refrigerator', 165, 26.00),
('appliance', 'refrigerator', 123, 3.00),
('appliance', 'washing machine', 123, 19.80),
('electronics', 'vacuum', 178, 5.00),
('electronics', 'wireless headset', 156, 7.00),
('electronics', 'vacuum', 145, 15.00),
('electronics', 'laptop', 114, 999.99),
('fashion', 'dress', 117, 49.99),
('groceries', 'milk', 243, 2.99),
('groceries', 'bread', 645, 1.99),
('home', 'furniture', 276, 599.99),
('home', 'decor', 456, 29.99);
select * from ProductSpend




select rpad(product, 15, '*') from ProductSpend; 



 select instr(category,'ics') from ProductSpend
 
 
with cte as(
select category,product,sum(spend) as total_spend,
  rank() over(partition by category order by sum(spend) desc) as rn
from ProductSpend
group by category,product)
select category,product, total_spend
from cte
where rank<=2
order by category,rank
 
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CHECK THIS 
#SWIGGY
-- find out the count of delayed orders for each delivery partner
CREATE TABLE order_details (
    orderid INT PRIMARY KEY,
    custid INT,
    city VARCHAR(50),
    order_date DATE,
    del_partner VARCHAR(50),
    order_time TIME,
    deliver_time TIME,
    predicted_time INT,
    aov DECIMAL(10, 2)
);
INSERT INTO order_details (orderid, custid, city, order_date, del_partner, order_time, deliver_time, predicted_time, aov) 
VALUES
(1, 101, 'Bangalore', '2024-01-01', 'PartnerA', '10:00:00', '11:30:00', 60, 100.00),
(2, 102, 'Chennai', '2024-01-02', 'PartnerB', '12:00:00', '13:15:00', 45, 200.00),
(3, 103, 'Bangalore', '2024-01-03', 'PartnerA', '14:00:00', '15:45:00', 60, 300.00),
(4, 104, 'Chennai', '2024-01-04', 'PartnerB', '16:00:00', '17:30:00', 90, 400.00);
select * from order_details

select del_partner, count(*) as delayed_del
from order_details where timestampdiff(minute,order_time,deliver_time )> predicted_time
group by del_partner

select  del_partner,
count( case when predicted_time < timestampdiff(minute, deliver_time,order_time) then 1 else null end) as order_count
from order_details
group by del_partner

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#Sel highest and lowest salary in each department
create table employee (
emp_name varchar(10),
dep_id int,
salary int
);
insert into employee values 
('Siva',1,30000),('Ravi',2,40000),('Prasad',1,50000),('Sai',2,20000)

select * from employee

with cte as
(select *,
 row_number() over(partition by dep_id order by salary desc) as rank_desc,
 row_number() over(partition by dep_id order by salary asc) as rank_asc
from employee)
select dep_id, salary,
 max(case when rank_desc=1 then emp_name end ) as high_rank,
 max(case when rank_asc=1 then emp_name end ) as low_rank
from cte group by dep_id,salary

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CHECK THIS
#Count words which are repeating
create table namaste_python (
file_name varchar(25),
content varchar(200)
);
insert into namaste_python values ('python bootcamp1.txt','python for data analytics 0 to hero bootcamp starting on Jan 6th')
,('python bootcamp2.txt','classes will be held on weekends from 11am to 1 pm for 5-6 weeks')
,('python bootcamp3.txt','use code NY2024 to get 33 percent off. You can register from namaste sql website. Link in pinned comment')

select * 
from namaste_python
cross apply string_split('content', '') 

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Find busiest route with highest ticket_count.
-- Round trip BOM --> DEL and DEL -->BOM is diff .
CREATE TABLE tickets (
    airline_number VARCHAR(10),
    origin VARCHAR(3),
    destination VARCHAR(3),
    oneway_round CHAR(1),
    ticket_count INT
);
INSERT INTO tickets (airline_number, origin, destination, oneway_round, ticket_count)
VALUES
    ('DEF456', 'BOM', 'DEL', 'O', 150),
    ('GHI789', 'DEL', 'BOM', 'R', 50),
    ('JKL012', 'BOM', 'DEL', 'R', 75),
    ('MNO345', 'DEL', 'NYC', 'O', 200),
    ('PQR678', 'NYC', 'DEL', 'O', 180),
    ('STU901', 'NYC', 'DEL', 'R', 60),
    ('ABC123', 'DEL', 'BOM', 'O', 100),
    ('VWX234', 'DEL', 'NYC', 'R', 90);

select * from tickets

select origin,destination,sum(ticket_count) as tc 
from 
(select origin,destination, oneway_round,ticket_count from tickets
union all
select origin,destination, oneway_round,ticket_count from tickets
where oneway_round = 'R') a
group by origin,destination order by tc desc

with cte as
(select origin,destination, oneway_round,ticket_count from tickets
union all
select origin,destination, oneway_round,ticket_count from tickets
where oneway_round = 'R') 
select origin, destination, sum(ticket_count) as ticket_count from cte
group by origin, destination order by ticket_count desc

with cte as 
(select origin,destination,
  sum(case when oneway_round='O' then ticket_count else ticket_count*2 end) as tickets_sold
  from tickets group by origin,destination)
select origin,destination,tickets_sold 
from cte order by tickets_sold desc

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#AMAZON - find number of employees inside the hospital
create table hospital (emp_id int
, action varchar(10)
, time datetime);

insert into hospital values ('1', 'in', '2019-12-22 09:00:00');
insert into hospital values ('1', 'out', '2019-12-22 09:15:00');
insert into hospital values ('2', 'in', '2019-12-22 09:00:00');
insert into hospital values ('2', 'out', '2019-12-22 09:15:00');
insert into hospital values ('2', 'in', '2019-12-22 09:30:00');
insert into hospital values ('3', 'out', '2019-12-22 09:00:00');
insert into hospital values ('3', 'in', '2019-12-22 09:15:00');
insert into hospital values ('3', 'out', '2019-12-22 09:30:00');
insert into hospital values ('3', 'in', '2019-12-22 09:45:00');
insert into hospital values ('4', 'in', '2019-12-22 09:45:00');
insert into hospital values ('5', 'out', '2019-12-22 09:40:00');

select * from hospital

with cte as 
(select *,
 dense_rank() over(partition by emp_id order by time desc) as dr
from hospital
where action='in')
select * from cte where dr =1
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CHECK THIS
#AMERICAN EXPRESS -- avg transaction amount per year for each client for the years 2018 to 2022.
CREATE TABLE transactions_2 (
    transaction_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_amount DECIMAL(10, 2) NOT NULL);
INSERT INTO transactions_2 (transaction_id, user_id, transaction_date, transaction_amount)
VALUES
    (1, 269, '2018-08-15', 500),
    (2, 478, '2018-11-25', 400),
    (3, 269, '2019-01-05', 1000),
    (4, 123, '2020-10-20', 600),
    (5, 478, '2021-07-05', 700),
    (6, 123, '2022-03-05', 900);

select user_id,
    year(transaction_date) as transaction_year,
    avg(transaction_amount) as avg_transaction_amount
from transactions_2
group by transaction_year,user_id;

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#Find change in employees leaving firm in each year (Churn) increase/decrease/no change
create table emp_churn ( empId int primary key,
start_date date not null,
end_date date not null,
salary int not null)
insert into emp_churn( empId, start_date, end_date, salary)
values
(1, '2019-05-02', '2021-01-01', 103000),
(2, '2019-06-02', '2019-09-02', 107000),
(3, '2019-06-02', '2020-09-02', 108800),
(4, '2019-03-02', '2022-09-02', 103800),
(5, '2019-06-02', '2019-10-01', 103500),
(6, '2019-06-02', '2020-09-02', 103300);
select * from emp_churn

with cte as(
select year(end_date) as year_driver_churned , 
 count(empId) as n_churned
 from emp_churn
 group by year(end_date)
)
select year_driver_churned,n_churned,
 lag(n_churned,1,0) over(order by year_driver_churned ) as n_churned_prev, #1,0 - 1 no. of prev rows to check. 0 default if no value
 case when n_churned> lag(n_churned,1,0) over(order by year_driver_churned ) then 'increase'
     when n_churned< lag(n_churned,1,0) over(order by year_driver_churned ) then 'decrease'
     else 'no change' 
 end as 'change'
from cte

#Lead and lag are not supported in my version USE SELF JOIN

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
GEEKSFORGEEKS 19 TOP INTERVIEW QNS
 
 CREATE TABLE emp (
    Id integer NOT NULL,
    Group_Id integer NOT NULL,
    Salary integer NOT NULL,
    Name character varying NOT NULL,
    CONSTRAINT Test_pkey PRIMARY KEY (Id)
)
 
 CREATE TABLE emp_sal (
    name VARCHAR(255) NOT NULL,
    salary INT NOT NULL)
    
INSERT INTO emp_sal (Name, Salary)
VALUES 
('Aman', 100000),
('Shubham', 1000000),
('Naveen', 40000),
('Nishant', 500000)
 
 -- Find 2nd highest salary
select * from emp_sal order by salary desc limit 1 offset 1 # using offset
 
select max(salary) from emp_sal where salary not in
  (select max(salary) from emp_sal)
 
 # 3rd highest sal
 select max(salary) from emp_sal 
 where salary < (select max(salary) from emp_sal 
              where salary < (select max(salary) from emp_sal))
 
 # FIND nth salary
  select * from emp_sal order by salary desc limit 1 offset 2 # using offset

# use row_number or dense_rank
 select  salary 
 from (select  salary, 
  row_number() over( order by salary) as rn
  from emp_sal) as Rankedsalaries
  where rn = 2

 CREATE TABLE department(
    id int,
    salary int,
    name Varchar(20),
    dept_id Varchar(255))

INSERT INTO department VALUES (1, 34000, 'ANURAG', 'UI DEVELOPERS');
INSERT INTO department VALUES (2, 33000, 'harsh', 'BACKEND DEVELOPERS');
INSERT INTO department VALUES (3, 36000, 'SUMIT', 'BACKEND DEVELOPERS');
INSERT INTO department VALUES (4, 36000, 'RUHI', 'UI DEVELOPERS');
INSERT INTO department VALUES (5, 37000, 'KAE', 'UI DEVELOPERS')
INSERT INTO department VALUES (5, 37000, 'KAE', 'UI DEVELOPERS') #
INSERT INTO department VALUES (3, 36000, 'SUMIT', 'BACKEND DEVELOPERS'); #

 -- increase all salaries by 5%
 select id, salary, salary* 1.05 as inc_salary from department
 
 -- highest sal acc dept
 select dept_id, max(salary) from department group by dept_id order by salary 
 
 -- count of emp in each dept
select dept_id, count(*) from department group by dept_id

-- avg of any col
select avg(salary) from department

-- sel alternate records
select  * from department where mod(id,2) != 0 # = even rows != odd
select  * from department where mod(id,2) = 1 # odd rows

select  * from(select id,salary,name,     # using row no.
  row_number() over (order by id) as rn 
  from department ) as x
  where mod(id,2) = 0
  
-- duplicates
select name, count(*) #for displaying dupl
from department
group by name 
having count(*)>1

# for removing dupl row_number
with cte as (
select *,
   row_number() over (partition by id order by id ) as rn
from department)
select * from cte where rn>1

-- pattern matching
select * from department where name like 'h%'

select * from department where salary like '37%'

select * from department where name like '%u%'

select * from department where dept_id not like 'UI%'

select * from department where dept_id like '%developers'

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Extract name from email id
create table user(
user_id int primary key auto_increment ,
user_name varchar(255) not null,
phone_no varchar(15) unique not null,
email varchar(255) unique not null
)
insert into user(user_id,user_name, phone_no, email)
values
(3001,'Aditi Shetti', '9876543210', 'aditi.shetti@example.com'),
(3002,'Priya Patel', '9123456789', 'priya.patel@example.com'),
(3003,'Ravi Kumar', '9988776655', 'ravi.kumar@example.com'),
(3004,'Sneha Gupta', '9898989898', 'sneha.gupta@example.com'),
(3005,'Rahul Mehta', '9765432109', 'rahul.mehta@example.com'),
(3006,'Aarti Shetti', '9654321098', 'aarti.shetti@example.com'),
(3007,'Vikram Singh', '9556677889', 'vikram.singh@example.com'),
(3008,'Neha Reddy', '9445566778', 'neha.reddy@example.com'),
(3009,'Diya Kasbekar', '9222333444', 'diya.kasbekar@example.com'),
(3010,'Rohan Joshi', '9333221111', 'rohan.joshi@example.com')
select * from user
select user_id,user_name, substring(email,1,locate('@',email)-1) as name from user # start at positn 1 and before @
select user_id,user_name, substring(email,locate('@',email)+1) as domain from user # start at positn @ till the end

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- sql statement to show second most recent balance for each account 
create table account_bal (
    acct_I INT NOT NULL,
    date_I DATE NOT NULL,
    balance_amt INT);
INSERT INTO account_bal (acct_I, date_I, balance_amt) VALUES
(23456, '2022-12-31', 350),
(34567, '2022-12-31', 34000),
(99824, '2022-12-31', 0),
(23456, '2020-01-10', 2500),
(99824, '2020-01-11', 2500), 
(12345, '2022-12-31', 25);

with cte as(select *,
 dense_rank() over (partition by acct_I order by date_I desc) as dr
from account_bal)
select acct_I,balance_amt from cte where dr=2

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- identify product categories where the sold quantity exceeded the restocked quantity in every month of 2024.
create table inventory (product_id int,
category varchar(50),
sold_quantity int, restocked_quantity int,
transaction_date date
);
insert into inventory(product_id,category,transaction_date,sold_quantity,restocked_quantity)
values(1, 'Electronics', '2024-01-10', 100, 80),
    (2, 'Electronics', '2024-02-15', 120, 110),
    (3, 'Electronics', '2024-03-20', 90, 85),
    (4, 'Electronics', '2024-04-05', 130, 100),
    (5, 'Clothing', '2024-01-12', 200, 180),
    (6, 'Clothing', '2024-02-20', 220, 210),
    (7, 'Clothing', '2024-03-25', 180, 190),
    (8, 'Clothing', '2024-04-18', 210, 200),
    (9, 'Furniture', '2024-01-15', 150, 160),
    (10, 'Furniture', '2024-02-25', 170, 180),
    (11, 'Furniture', '2024-03-12', 160, 150),
    (12, 'Furniture', '2024-04-05', 180, 170);
select * from inventory

select date_format(transaction_date, '%Y-%m') as d
from inventory

with cte as (
select category,month(transaction_date) as month, 
  sum(sold_quantity) as total_sold, 
  sum(restocked_quantity) as total_restocked
from inventory
where year(transaction_date) = 2024
group by category, month(transaction_date)
having sum(sold_quantity) > sum(restocked_quantity))
select category from cte
group by category
having count(distinct month) = 12;

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- 20th jan 2026
-- 21st Jan

select now()
select curdate()

select transaction_date, year(transaction_date) from inventory;
select transaction_date, month(transaction_date) from inventory;
select transaction_date, monthname(transaction_date) from inventory;

SELECT
  order_date,
  YEAR(order_date)  AS yearr,
  MONTH(order_date) AS monthh,
  DAY(order_date)   AS dayy
FROM sales;

SELECT transaction_date,
  WEEK(transaction_date, 3) AS iso_week
FROM inventory;

select transaction_date, day(transaction_date) from inventory;
select transaction_date, dayname(transaction_date) from inventory;
select transaction_date, dayofmonth(transaction_date) from inventory;  # dayofmonth/week/year

select transaction_date, week(transaction_date,6) from inventory;

select transaction_date, date_add(transaction_date interval() ) from inventory;


SELECt order_date,
  DATE_ADD(order_date, INTERVAL 7 DAY)  AS plus_7_days,
  DATE_ADD(order_date, INTERVAL 6 month)  AS plus_6_m,
  DATE_SUB(order_date, INTERVAL 1 MONTH) AS minus_1_month
FROM sales;


select transaction_date, datediff('2026-01-22',transaction_date) from inventory;
select transaction_date, timestampadd( month ,'2026-01-22',transaction_date) from inventory;

SELECT DATE_FORMAT('2026-01-22', '%d-%b-%Y') AS nice;  -- 22-Jan-2026

SELECT
  '2026-01-22' AS d,
  DAYNAME('2026-01-22') AS day_name,
  WEEKDAY('2026-01-22') AS weekday_no;  -- 0=Mon ... 6=Sun

