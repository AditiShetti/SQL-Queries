use sakila;
show tables;

select * from actor;
select * from address;
select * from category;
select * from city;
select * from country;
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
select last_name from actor group by last_name having count(*)=1;

-- 5. Which last names appear more than once?
select last_name from actor group by last_name having count(*)>1;

-- 6.  Which actor participated in the most films? Print their full name and in how many movies they participated.
select a.actor_id,a.first_name , a.last_name , count(f.actor_id) as film_count
from actor as a join film_actor as f on a.actor_id= f.actor_id
group by f.actor_id
order by count(f.actor_id) desc limit 1

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

-- 9. When is ‘Academy Dinosaur’ due?

-- 10. What is the average running time of all the films in the sakila DB?
select avg(rental_duration) from film;

-- 11. What is the average running time of films by category?
select avg(f.length) as avg_time, c.name 
from film f join film_category fc on f.film_id=fc.film_id
join category c on c.category_id= fc.category_id
group by c.name order by avg(f.length) desc;

-- 12. Why does this query return the empty set? select * from film natural join inventory;
-- 13. Which actors participated in the movie ‘Academy Dinosaur’? Print their first and last names.
select a.first_name , a.last_name
from film f join film_actor fa on f.film_id= fa.film_id 
join actor a on a.actor_id= fa.actor_id where f.title= "Academy Dinosaur";

-- 14. How many copies of the film ‘Hunchback Impossible’ exist in the inventory system? 
-- 15. What is the total amount paid by each customer for all their rentals? For each customer print their name and the total amount paid.
-- 16. How many films from each category each store has? 
--     Print the store id, category name and number of films. Order the results by store id and category name.



-- 17. Calculate the total revenue of each store.
select s.store_id,sum(p.amount)
from payment p join staff st on p.staff_id= st.staff_id 
     join store s on st.store_id= s.store_id
group by s.store_id   
  
-- 20. Find pairs of actors that participated together in the same movie and print their full names. Each such pair should appear only once in the result. (You should have 10,385 rows in the result)
-- 21. Display the top five most popular films, i.e., films that were rented the highest number of times. For each film print its title and the number of times it was rented.


-- 22. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select Upper(concat(first_name ," ", last_name)) as Actor_Name from actor 

-- 23a. Find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
select actor_id,first_name, last_name  from actor where first_name='Joe';

-- 23b. Find all actors whose last name contain the letters GEN.
select actor_id,first_name, last_name  from actor where last_name like '%GEN%';

-- 23c. Find all actors whose last names contain the letters LI. Order the rows by last name and first name.
select actor_id,first_name, last_name  from actor where last_name like '%LI%' order by last_name , first_name;

-- 23d. Display the country_id and country of Afghanistan, Bangladesh, and China using IN.
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

-- 24a. Add a column in the table actor named description with data type BLOB.
alter table actor add column description blob;

select * from actor;
-- 24b. Delete the description column from the actor table.


-- 25a. List the last names of actors, as well as how many actors have that last name.
-- 25b. List last names of actors and the number of actors who have that last name, but only for names shared by at least two actors.
-- 25c. Update actor HARPO WILLIAMS who was mistakenly entered as GROUCHO WILLIAMS.
Update actor set first_name = 'HARPO' where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- 25d. Revert the name from HARPO back to GROUCHO if the actor is currently listed as HARPO.

-- 26a. Find the schema (CREATE statement) of the address table.

-- 27a. Use JOIN to display the first and last names, as well as the address, of each staff member.
select from st

-- 27b. Use JOIN to display the total amount rung up by each staff member in August of 2005.
-- 27c. List each film and the number of actors who are listed for that film.
-- 27d. How many copies of the film *Hunchback Impossible* exist in the inventory system?
-- 27e. List the total paid by each customer, ordered by last name.

-- 28a. Display titles of movies starting with the letters K and Q whose language is English using subqueries.

-- 28b. Display all actors who appear in the film *Alone Trip* using subqueries.
select first_name, last_name, actor_id from actor  in (select title from film where title='Alone Trip';)

-- 28c. Retrieve the names and email addresses of all Canadian customers for a marketing campaign.
-- 28d. Identify all movies categorized as Family films.
-- 28e. Display the most frequently rented movies in descending order.
-- 28f. Display how much business, in dollars, each store brought in.
-- 28g. Display for each store: its store ID, city, and country.
-- 28h. List the top five genres in gross revenue in descending order.

-- 29a. Create a view to show the top five genres by gross revenue.
-- 29b. Display the view created in 29a.
-- 29c. Drop the view created in 29a if no longer needed.
