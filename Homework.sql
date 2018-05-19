use sakila;

-- 1a. Display the first and last names of all actors from the table actor. 
select 
first_name, last_name
from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. 
select
CONCAT(first_name, " " ,last_name) AS Actor_Name
from actor;
select Actor_name, upper(Actor_Name);

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name
from actor
where first_name like 'Joe%';

-- 2b. Find all actors whose last name contain the letters GEN:
select actor_id, first_name, last_name
from actor
where last_name like '%gen%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select actor_id, first_name, last_name
from actor
where last_name like '%li%'
order by last_name asc, first_name asc;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country in('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
alter table actor
add column middle_name varchar(20)
AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
alter table actor modify middle_name blob;

-- 3c. Now delete the middle_name column.
alter table actor
drop column middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select 
last_name, count(*) as number_of_actors
from actor
group by (last_name);

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select 
last_name, count(*) as number_of_actors
from actor
group by (last_name) having count(*) >= 2;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second 
-- cousin's husband's yoga teacher. Write a query to fix the record.

set sql_safe_updates = 0;
UPDATE actor
SET first_name = replace(first_name, 'GROUCHO', 'HARPO');

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single 
-- query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, 
-- as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO 
-- GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)

select actor_id, last_name, first_name
from actor
where first_name = 'HARPO'; 

select actor_id, last_name, first_name
from actor
where first_name = 'GROUCHO';  

update actor
set first_name='GROUCHO' 
where actor_id = 172;

update actor
set first_name='MUCHO GROUCHO' 
where actor_id = 78 and 106;
set sql_safe_updates = 1;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select
first_name, last_name, address from staff
inner join address on staff.address_id = address.address_id;


-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. 
select
s.staff_id, first_name, last_name, sum(amount) as 'Total' from staff s
inner join payment p on s.staff_id = p.staff_id
group by staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title, count(actor_id) as 'Number of Actors'
from film f
inner join film_actor fa on f.film_id = fa.film_id
group by f.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select f.title, count(i.film_id) as 'Number of copies'
from inventory i
inner join film f on f.film_id = i.film_id
where f.title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select c.customer_id, c.first_name, c.Last_name, sum(p.amount) as 'Total Amount'
from payment p
inner join customer c on p.customer_id = c.customer_id
group by p.customer_id
order by c.last_name asc; 

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting 
-- with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the 
-- letters K and Q whose language is English. 
select title 
from film 
where language_id IN
	(select language_id from language where name = "English") 
    and (title like 'K%') or (title like 'Q%');
    

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name from actor
where actor_id in
	(select actor_id from film_actor
	where film_id in
		(select film_id from film
		where title = "Alone Trip"));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all 
-- Canadian customers. Use joins to retrieve this information.
select c.first_name, c.last_name, c.email, co.country FROM customer c
left join address a
on c.address_id = a.address_id
left join city ci
on ci.city_id = a.city_id
left join country co
on co.country_id = ci.country_id
where country = "Canada";



-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.
select * from film
where film_id IN
	(select film_id from film_category
	where category_id in
		(SELECT category_id from category
		WHERE name = "Family"));

-- 7e. Display the most frequently rented movies in descending order.
select f.title, COUNT(r.rental_id) AS 'Times Rented' FROM film f
right join inventory i
on f.film_id = i.film_id
join rental r 
on r.inventory_id = i.inventory_id
group by f.title
order by COUNT(r.rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select s.store_id, sum(amount) as 'Total Revenue' FROM store s
right join staff st
on s.store_id = st.store_id
left join payment p
on st.staff_id = p.staff_id
group by s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, ci.city, co.country from store s
join address a
on s.address_id = a.address_id
join city ci
on a.city_id = ci.city_id
join country co
on ci.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the 
-- following tables: category, film_category, inventory, payment, and rental.)
select c.name, sum(p.amount) as 'Revenue per Genre' from category c
join film_category f
on c.category_id = f.category_id
join inventory i
on f.film_id = i.film_id
join rental r
on r.inventory_id = i.inventory_id
join payment p
on p.rental_id = r.rental_id
group by name;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
create view Top_5 as
select c.name, sum(p.amount) as 'Revenue per Genre' FROM category c
join film_category f
on c.category_id = f.category_id
join inventory i
on f.film_id = i.film_id
join rental r
on r.inventory_id = i.inventory_id
join payment p
on p.rental_id = r.rental_id
group by name
order by SUM(p.amount) DESC
limit 5;


-- 8b. How would you display the view that you created in 8a?
SELECT * FROM Top_5;


-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top_5_;