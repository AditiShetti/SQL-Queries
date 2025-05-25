Analyst Builder questions (FREE ones)
Alex the Analyst

-- Easy level
1. Determine which Tesla Model has made the most profit.

tesla_model	 car_price	 cars_sold 	production_cost
Model 3     	 46990	        156357	  	  	21000
Model S	       104990        	23464	  	    	43000
Model X	       120990	  	19542	  	    	48000...


tesla_model	 car_price	 cars_sold 	production_cost
Model 3     	46990	      156357	  	  	21000      
Model S	       104990       	23464	  	       	43000      
Model X	       120990	  	19542	  	    	48000...  
SELECT *, (car_price-production_cost)*cars_sold as profit
FROM tesla_models
order by profit desc limit 1;

2.If a patient is over the age of 50, cholesterol level of 240 or over, and weight 200 or greater,
  then they are at high risk of having a heart attack.  Order by Cholesterol high to low.
 
 patient_id	  age	  cholesterol 	weight
1001	        52       	373        	267
1002	        93    	   235	        164
1003	        77	    324	        211...

SELECT *
FROM patients
where age>50 and cholesterol>= 240 and weight>=200
order by cholesterol desc;


3.A Computer store is offering a 25% discount for all new customers over the age of 65 or customers
 that spend more than $200 on their first purchase. The owner want the no. of people.
 
customer_id	 age	  total_purchase
1001	        72	    1053
1002	        86	    826
1003	        37	    713...
SELECT COUNT(*)
FROM customers
where age>65 or total_purchase>200;

4.Write a query that returns all of the stores whose average yearly revenue is greater than one million dollars.
Output the store ID and average revenue. Round the average to 2 decimal places. Order by store ID.
store_id	year	  revenue
1	        2020	  1000000
2	        2020	  1500000
3	        2020	  800000

SELECT store_id, round(avg(revenue),2)
FROM stores
group by store_id having avg(revenue)>1000000;

5.Popularity is defined by number of actions (likes, comments, shares, etc.) divided by the number impressions the post received * 100.
If the post receives a score higher than 1 it was very popular.
Return all the post IDs and their popularity where the score is 1 or greater.
Order popularity from highest to lowest.

post_id	  impressions	  actions
18492	      49582	        3891
18493    	308331	      133
18494	      99497        	4216
SELECT post_id, (actions/impressions)*100 as r
FROM linkedin_posts
  where (actions/impressions)*100  >1 
  ORder by (actions/impressions)*100  desc;

6.Give each Employee who is a level 1 a 10% increase, level 2 a 15% increase, and level 3 a 200% increase."new-salary"
employee_id	pay_level	  salary
1001        	1        	75000
1002	        1	        85000
1003	        1	        60000

SELECT *,
  case when pay_level=1 then salary* 1.10 
     when pay_level=2 then salary* 1.15 
     when pay_level=3 then salary* 3
  else salary
  end as new_salary
FROM employees;

7.Write a Query to return bakery items that contain the word "Chocolate".
SELECT *
FROM bakery_items
where product_name like '%Chocolate%';

8. Extract oldest 3 employees
SELECT employee_id
FROM employees
order by birth_date asc limit 3;

9.Output every possible combination of bread and meats . CROSS JOIN
SELECT bread_name, meat_name
FROM bread_table as b cross join meat_table as m
ORDER by bread_name, meat_name ;

10.f a car has any critical issues it will fail inspection or if it has more than 3 minor issues it will also fail.
SELECT owner_name ,vehicle
FROM inspections
  where critical_issues=0 and minor_issues<=3
ORDER by owner_name asc;

11.which region spends the most money on fast food?
state      	region	fast_food_millions
Alabama	    South        	83
Alaska	    West        	80
Arizona    	West        	81

SELECT region
FROM food_regions
  group by region
ORDER by sum(fast_food_millions) desc limit 1 ;


12.Return all IDs that have problem solving skills, SQL experience, knows Python or R, and has domain knowledge.
candidate_id	sql_experience	excel	 python 	r_prog	problem_solving	 3_yoe 7_yoe	domain_knowledge
1001	        X            	X      	X	        NULL    	 X	            X	            X	        X
1002	        X            	X     	NULL	    X	       X	            NULL        	NULL	    NULL
1003	        X            	X	    X        NULL	     X	            NULL         	NULL	    X

SELECT candidate_id
FROM candidates
where problem_solving ='X' and sql_experience ='X' and (python='X' or r_programming ='X') and 
  domain_knowledge='X';

13. calculate how much money they have lost on their rotisserie chickens this year. Round to the nearest whole number.
month	    lost_revenue_millions
January	          2.5
February         	3.75
March	            4.21
  
SELECT
  round(SUM( lost_revenue_millions),0) as loss
FROM sales;

14.Write a query to determine the percentage of employees that were laid off from each company.round to 2 decimal places
company	 company_size	  employees_fired
Apple	         147000	        0
Microsoft	     181000	        6000
Google	       139500	        15000
SELECT company, round((employees_fired/company_size)*100,2) as laid_off
FROM tech_layoffs
order by company asc;

15.Separate id and name into diff columns. the id is 5 digits.
id
12345Johnny
93829Sally
20391Larry
SELECT left(id,5) as ID, substring(id,6) as NAME
FROM bad_data;

-- Hard level
16..Every 3rd transaction must be given a 33% discount.Output the customer id, transaction id, amount,
 and the amount after the discount as "discounted_amount".
 customer_id	transaction_id	amount
1001	          339473	        89  
1002	          359433        	5  
1003	          43176	          52  
with cte AS
  (SELECT customer_id,
  transaction_id,
  amount,
  dense_rank() over(partition by customer_id order by transaction_id asc)as d
FROM purchases)
SELECT customer_id,transaction_id,amount, amount*0.67 as discounted_amount
FROM cte where d=3;

17.Write a query to find the people who spent a higher than average amount of time on social media.
users_time                                              users
user_id  media_time_minutes                       user_id      first_name
1              0                                     1           John
2              200                                   2           Janice

SELECT first_name
FROM user_time as t join users as u on t.user_id=u.user_id
  where media_time_minutes>(SELECT avg(media_time_minutes) from user_time)
 order by first_name ASC;


18.If a customer is 55 or above they qualify for the senior citizen discount. Check which customers qualify.
Assume the current date 1/1/2023.

customer_id  	birth_date
YVD4753692	  1989-03-25
XBJ9334631	  1964-06-12
SELECT customer_id
FROM customers
WHERE TIMESTAMPDIFF(YEAR ,birth_date,'2023-01-01')>=55 
 ORDER BY  customer_id ;


19.Write a query to identify products that have undergone shrink-flation over the last year. Shrink-flation is defined as a reduction in product size while maintaining or increasing the price.
Include a flag for Shrinkflation. This should be a boolean value (True or False) indicating whether the product has undergone shrink-flation
The output should have the columns Product_Name, Size_Change_Percentage, Price_Change_Percentage, and Shrinkflation_Flag.
Round percentages to the nearest whole number and order the output on the product names alphabetically.


product_id	product_name	    category	 original_size   	new_size	            original_price	new_price            	date_changed
1	          Cheerioes	     Cereals	   349.73	    321.75160000000005	    5.17	        5.2217	            2023-01-08
2          	Mountain Dew	    Beverages	  103.17	      99.0432                  	5.48	        5.863600000000001	    2022-12-09


  
SELECT product_name,
  round(((new_size-original_size)/original_size)*100,0) as Size_Change_Percentage,
  round(((new_price-original_price)/original_price)*100,0) as Price_Change_Percentage,
  case
      when original_size>new_size and original_price<=new_price then 'True'
  else 'False' end as Shrinkflation
FROM products
  ORDER by product_name;


20.Write a query to determine how many direct reports each Manager has.
Note: Managers will have "Manager" in their title.
Report the Manager ID, Manager Title, and the number of direct reports in your output.

employee_id	    position	          managers_id
1001	        Analytics Manager	    1013
1002         	Data Engineer	          1007

SELECT a.employee_id as manager_id, a.position as manager_position,
     count(*) as direct_reports
FROM direct_reports as a
join direct_reports as b on a.employee_id=b.managers_id
  WHERE a.position like '%Manager%'
  GROUP by a.employee_id,a.position;

21.
