use sakila;
show tables;

select * from actor;
select * from address;
select * from category;
select * from city;
select * from country;
select * from customer;
select * from film;
select * from film_actor;
select * from film_category;
select * from film_text;
select * from inventory;
select * from language;
select * from payment;
select * from rental;
select * from staff;
select * from store;


-- 1. Which actors have the first name ‘Scarlett’
select * from actor where first_name ='Scarlett';

-- 2. Which actors have the last name ‘Johansson’
select * from actor where last_name ='Johansson';

-- 3. How many distinct actors last names are there?
select count(distinct(last_name)) from actor ;

-- 4. Which last names are not repeated?
select last_name , count(*) as count_lastnames from actor group by last_name having count(*)=1;

-- 5. Which last names appear more than once?
select last_name,count(*) as count_lastname from actor group by last_name having count(*)>1;

-- 6.  Which actor participated in the most films? Print their full name and in how many movies they participated.
select a.actor_id,a.first_name , a.last_name , count(f.actor_id) as film_count
from actor as a 
join film_actor as f on a.actor_id= f.actor_id
group by f.actor_id
order by count(f.actor_id) desc limit 1


-- Third most busy actor. Write a query to find the full name of the actor who has acted in the third most number of movies.
select a.actor_id,concat(a.first_name," ",a.last_name ) as full_name ,count(f.actor_id) as film_count
from actor as a 
join film_actor as f on a.actor_id= f.actor_id
group by f.actor_id
order by count(f.actor_id) desc limit 1 offset 2;


-- Highest grossing film. 


-- Customers from a particular category


-- Customers from specific countries.
select cu.customer_id, cu.first_name, cu.last_name, co.country 
from customer cu
join address a on cu.address_id = a.address_id
join city c on a.city_id =  c.city_id
join country co on c.country_id= co.country_id where co.country in ( 'India','Argentina','Vietnam' ); 

select * from city join country on city.country_id = country.country_id order by country desc

select distinct(country) from country

-- Category of films in diff cities. 

 
-- List all films of a particular category in alphabetical order.  


-- Particular thing in description.  


-- Month with most paymenst .  



-- 7. Is ‘Academy Dinosaur’ available for rent from Store 1?
select i.*
from film f 
join inventory i on f.film_id = i.film_id 
join store s on  i.store_id= s.store_id
where s.store_id=1 and f.title='academy dinosaur' #Shows all copies at store. But not if it is available to rent
and NOT EXISTS (
select 1   -- does any row exist
from rental r where r.inventory_id = i.inventory_id and r.return_date is null);
# Check if the copy is currently rented. No return date means not returned yet so NOT AVAILABLE FOR RENT now


-- 8. Insert a record to represent Mary Smith renting ‘Academy Dinosaur’ from Mike Hillyer at Store 1 today.
# Check customer_id for Mary Smith is 1 ,  staff_if of Mike Hillyer is 1 , film id fot title ‘Academy Dinosaur’ is 1.

insert into rental ( rental_date, inventory_id, customer_id, staff_id)
values   (NOW(),1,1,1);
select * from rental order by rental_id desc;

select * from customer;
select * from staff ;
select * from rental order by rental_id desc;
select * from film;
 
-- Deleting the previous row.
delete from rental where rental_id= 16050;
 
 
-- 9. When is ‘Academy Dinosaur’ due? # Due date would be the rental date + rental_duration (in days)
#Finding the film id first
select f.film_id,f.title,r.rental_id, r.rental_date, r.return_date, f.rental_duration,
       date_add(r.rental_date, interval f.rental_duration day) as due_date  # for date only add date() before date_add
from film  f  
join inventory i  on f.film_id= i.film_id
join rental r     on i.inventory_id= r.inventory_id
where title = 'Academy Dinosaur' order by r.rental_date desc limit 1; 
 

-- 10. What is the average running time of all the films in the sakila DB?
select avg(length) as avg_runtime from film;


-- 11. What is the average running time of films by category?
select avg(f.length) as avg_time, c.name 
from film f 
join film_category fc  on f.film_id=fc.film_id
join category c        on c.category_id= fc.category_id
group by c.name 
order by avg(f.length) desc;


-- 12. Why does this query return the empty set?  select * from film natural join inventory;
# A natural join combines tables based on common columns that share the same name and have compatible dtypes.

-- 13. Which actors participated in the movie ‘Academy Dinosaur’? Print their first and last names.
select a.first_name , a.last_name, a.actor_id
from film f join film_actor fa on f.film_id= fa.film_id 
join actor a on a.actor_id= fa.actor_id where f.title= "Academy Dinosaur";

-- 14. How many copies of the film ‘Hunchback Impossible’ exist in the inventory system? 
select count(*) from film f join inventory i on f.film_id = i.film_id where f.title= 'Hunchback Impossible';

-- 15. What is the total amount paid by each customer for all their rentals? For each customer print their name and the total amount paid.
select concat(c.first_name," ",c.last_name) as customer_name, sum(p.amount) as Amount
from customer c 
join payment p on c.customer_id= p.customer_id group by c.first_name, c.last_name
order by amount desc;

-- 16. How many films from each category each store has? 
--     Print the store id, category name and number of films. Order the results by store id and category name.
select s.store_id, c.name , count() 
from category c
join film_category fc on c.category_id = fc.category_id
join film          f on fc.film_id = f.film_id
join inventory     i on f.film_id = i.film_id 
join store         s on i.store_id = s.store_id;


-- 17. Calculate the total revenue of each store.
select s.store_id,sum(p.amount) as revenue
from payment p join staff st on p.staff_id= st.staff_id 
     join store s on st.store_id= s.store_id
group by s.store_id   
 
 
-- 18. Find pairs of actors that participated together in the same movie and print their full names. Each such pair should appear only once in the result. (You should have 10,385 rows in the result)
select fa1.actor_id as actor_id1,
	concat(a1.first_name," ",a1.last_name) as actor1_name,
       fa2.actor_id as actor_id2 , 
	concat(a2.first_name," ",a2.last_name) as actor2_name,
       fa1.film_id , f.title as movie_title
from film_actor fa1  
join film_actor fa2 on fa1.film_id = fa2.film_id and fa1.actor_id< fa2.actor_id
join actor a1 on fa1.actor_id = a1.actor_id
join actor a2 on fa2.actor_id = a2.actor_id
join film f on f.film_id = fa1.film_id;

-- 19. Display the top five most popular films, i.e, films that were rented the highest number of times. For each film print its title and the number of times it was rented.
select i.film_id, f.title, count(*) as rental_count 
from rental r 
join inventory i on r.inventory_id= i.inventory_id 
join film f on f.film_id = i.film_id 
group by i.film_id, f.title order by rental_count desc limit 5;

-- 20. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select Upper(concat(first_name ," ", last_name)) as Actor_Name from actor 

-- 21a. Find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
select actor_id,first_name, last_name  from actor where first_name='Joe';

-- 21b. Find all actors whose last name contain the letters GEN.
select actor_id,first_name, last_name  from actor where last_name like '%GEN%';

-- 21c. Find all actors whose last names contain the letters LI. Order the rows by last name and first name.
select actor_id,first_name, last_name from actor where last_name like '%LI%' order by last_name , first_name;

-- 21d. Display the country_id and country of Afghanistan, Bangladesh, and China using IN.
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');


#22.
-- 22a. Add a column in the table actor named description with data type BLOB.
alter table actor add column description blob;

select * from actor ;
-- 22b. Delete the description column from the actor table.
alter table actor drop column description;

#23.
-- 23a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) as count_lastname 
from actor group by last_name order by count_lastname desc; 
-- 23b. List last names of actors and the number of actors who have that last name, but only for names shared by at least two actors.
select last_name, count(last_name) as count_lastname from actor
 group by last_name having  count(last_name)>=2 order by count_lastname desc; 
-- 23c. Update actor HARPO WILLIAMS who was mistakenly entered as GROUCHO WILLIAMS.
Update actor set first_name = 'HARPO' where first_name = 'GROUCHO' and last_name = 'WILLIAMS'; #If last_nam condition is not written it will update all 'HARPO'
-- 23d. Revert the name from HARPO back to GROUCHO if the actor is currently listed as HARPO.
update actor set first_name ='GROUCHO' where first_name= 'HARPO' and last_name = 'WILLIAMS';  


-- 24. Find the schema (CREATE statement) of the address table.
describe address;
show create table address;


#25.
-- 25a. Use JOIN to display the first and last names, as well as the address, of each staff member.
select s.first_name,s.last_name,a.* 
from staff s 
join address a on a.address_id= s.address_id;

-- 25b. Use JOIN to display the total amount rung up by each staff member in August of 2005.
select s.staff_id, sum(p.amount) as total_amount
from staff s
join payment p on s.staff_id= p.staff_id 
where year(p.payment_date)= 2005 and month(p.payment_date)=8
group by s.staff_id ; 

select * from payment;
-- 25c. List each film and the number of actors who are listed for that film.
select f.title, count(fa.actor_id) as actor_count from film f 
join film_actor fa on f.film_id= fa.film_id group by f.film_id,f.title;

-- 25d. How many copies of the film *Hunchback Impossible* exist in the inventory system?
select count(*)
from film f 
join inventory i on f.film_id= i.film_id 
where f.title='Hunchback Impossible';

-- 25e. List the total paid by each customer, ordered by last name.
select c.first_name, c.last_name, sum(p.amount) as amount
from customer c 
join payment p on c.customer_id= p.customer_id group by c.first_name, c.last_name 
order by c.last_name desc;

-- 26a. Display titles of movies starting with the letters K and Q whose language is English using subqueries.
select title 
from film 
where (title like 'K%' or title like 'Q%' )
and language_id in 
          (select language_id from language where name='English')

-- 26b. Display all actors who appear in the film *Alone Trip* using subqueries.
select fa.actor_id, a.first_name, a.last_name
from film_actor fa 
join actor a on a.actor_id= fa.actor_id
where fa.film_id in 
(select film_id from film where title ='Alone Trip')

-- 26c. Retrieve the names and email addresses of all Canadian customers for a marketing campaign.
select cu.first_name, cu.last_name, cu.email
from customer cu  
join address a     on cu.address_id= a.address_id
join city c        on a.city_id= c.city_id
join country co    on c.country_id= co.country_id 
where co.country='Canada';

-- 26d. Identify all movies categorized as Family films.
select f.film_id , f.title
from film f 
join film_category fc on f.film_id = fc.film_id
join category c on fc.category_id = c.category_id where c.name='Family'


-- 26e. Display how much business, in dollars, each store brought in.
 select s.store_id, sum(p.amount) as revenue
 from store s 
  join staff st on s.store_id =st.store_id
  join payment p on  st.staff_id=p.staff_id
  group by  s.store_id
  
  -- 26f. Display for each store: its store ID, city, and country.
 select s.store_id, c.city,co.country 
 from store s 
  join address a on s.address_id = a.address_id
  join city c on a.city_id= c.city_id
  join country co on c.country_id = co.country_id;
  
-- 26g. List the top five genres in gross revenue in descending order.
select c.name, sum(p.amount) as revenue
from category c
join film_category fc on c.category_id= fc.category_id
join film f           on fc.film_id= f.film_id
join inventory i      on f.film_id= i.film_id
join rental r         on i.inventory_id= r.inventory_id
join payment p        on r.rental_id= p.rental_id
group by c.name,c.category_id order by sum(p.amount) desc limit 5;


# VIEWS
SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';

select * from actor_info;
select * from customer_list;
select * from film_list;
select * from nicer_but_slower_film_list;
select * from sales_by_film_category;
select * from sales_by_store;
select * from staff_list;


describe actor_info

-- Create all the above view again acc to understanding.

-- 27a. Create a view to show the top five genres by gross revenue.
create or replace view top_5_genres_revenue as
(select c.name, sum(p.amount) as revenue
from category c
join film_category fc on c.category_id= fc.category_id
join film f           on fc.film_id= f.film_id
join inventory i      on f.film_id= i.film_id
join rental r         on i.inventory_id= r.inventory_id
join payment p        on r.rental_id= p.rental_id
group by c.name,c.category_id order by sum(p.amount) desc limit 5)

select * from top_5_genres_revenue
show full tables where table_type= 'VIEW';

-- 27b. Display the view created in 29a.
select * from top_5_genres_revenue

-- 27c. Drop the view created in 29a if no longer needed.
drop view top_5_genres_revenue;

-- 28. Create a view showing each film’s rental count
create or replace view film_rental as 
(select f.film_id, f.title , count(r.rental_id) as rented_count
from film f 
left join inventory i on f.film_id= i.film_id
left join rental r on  i.inventory_id= r.inventory_id
group by f.film_id, f.title
order by count(r.rental_id) desc) 

select * from film_rental where rented_count>30;

# Self join qns
-- 29.Write a query to find pairs of actors (actor_id1, actor_id2) who have the same last name but different actor_ids.
select a1.first_name,a1.actor_id, a1.last_name, a2.first_name,a2.actor_id 
from actor a1
join actor a2
on a1.last_name = a2.last_name
and a1.actor_id > a2.actor_id 


-- 30. List all customers who have never rented a movie. 
select customer_id
from customer where customer_id not in (select customer_id from rental)

select * from customer c left join rental r on c.customer_id= r.customer_id where r.customer_id is null ; 


-- 31. For each city, show the total number of customers living there. Sort the result by the number of customers, highest first.
select count(*), c.city
from customer cu
join address a on cu.address_id = a.address_id
join city c on   a.city_id = c.city_id group by c.city order by count(*) desc;

-- 32. Count of Language 
select l.name , count(f.film_id)
from language l join film f on l.language_id = f.language_id
group by l.name ;
select * from language
select distinct(language_id) from film

# timestamp funcs
# label address as store / staff add.

