   # 1a. Display the first and last names of all actors from the table actor.
SELECT 
	first_name, 
    last_name
FROM sakila.actor;

-- Note there is one duplicate actor name since the count of the total table is 200 and 2 queries below returns 199. The actor_id is unique so it should be consider 200 unique actors. 
SELECT count(actor_id)
FROM sakila.actor;
 
SELECT 
	count(distinct(test.actor))
FROM 
	(
		SELECT 
			CONCAT(first_name,last_name) as actor
		FROM sakila.actor
	)test
 
#   1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT 
	UPPER(CONCAT(first_name," ",last_name)) as Actor_Name
FROM sakila.actor

#    2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT 
	actor_id, 
    first_name, 
    last_name
FROM sakila.actor
WHERE first_name = "Joe"

#2b. Find all actors whose last name contain the letters GEN:
SELECT 
	first_name, 
    last_name
FROM sakila.actor
WHERE last_name like '%gen%'

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT 
	first_name, 
    last_name
FROM sakila.actor
WHERE last_name like '%li%'
ORDER BY last_name, first_name

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT 
	country_id, 
    country
FROM sakila.country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China')

#3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE sakila.actor
ADD COLUMN middle_name VARCHAR(30) AFTER first_name;

SELECT *
FROM sakila.actor
LIMIT 1

#3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
# I am assuming this hw prompt is wrong and it means to change the middle_name column to blobs since last_name is part of a non-unique index
ALTER TABLE sakila.actor
MODIFY middle_name LONGBLOB;

DESCRIBE sakila.actor;

#3c. Now delete the middle_name column.
ALTER table sakila.actor
DROP COLUMN middle_name;

DESCRIBE sakila.actor;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT 
	DISTINCT(last_name), 
    COUNT(actor_id) as last_name_count
FROM sakila.actor
GROUP BY last_name

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT 
	DISTINCT(last_name), 
	COUNT(actor_id) as last_name_count
FROM sakila.actor
GROUP BY last_name
HAVING last_name_count >1

#4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE sakila.actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' 
	AND last_name = 'WILLIAMS';

SELECT *
FROM sakila.actor
WHERE first_name = 'GROUCHO' 
	AND last_name = 'WILLIAMS'

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE sakila.actor
    SET first_name = 
		CASE
			WHEN first_name = 'HARPO' THEN 'GROUCHO'
			ELSE 'MUCHO GROUCHO' 
		END 
WHERE actor_id = 172;

SELECT first_name, last_name
FROM sakila.actor
WHERE actor_id = 172;

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
#Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
USE sakila;
SHOW CREATE TABLE address;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT 
	staff.first_name,
    staff.last_name,
    address.address
FROM sakila.staff 
	LEFT JOIN sakila.address
		ON staff.address_id = address.address_id

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT
	staff.first_name,
    staff.last_name,
    SUM(amount) AS total_amount
FROM sakila.staff
    LEFT JOIN sakila.payment
		ON staff.staff_id = payment.staff_id
WHERE payment_date BETWEEN '2005-05-01' AND '2005-05-31'
GROUP BY 1,2


#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT 
	film.title,
    COUNT(film_actor.actor_id) AS num_of_actors
FROM
	sakila.film
    INNER JOIN sakila.film_actor
		ON film.film_id = film_actor.film_id
GROUP BY 1

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT
	title,
    COUNT(inventory_id) as copies
FROM sakila.film
	LEFT JOIN sakila.inventory
		ON film.film_id = inventory.film_id
WHERE title = "Hunchback Impossible"

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT
	last_name,
    first_name,
    SUM(amount) AS total_paid
FROM sakila.payment
	JOIN sakila.customer
		ON customer.customer_id = payment.customer_id
GROUP BY 1,2
ORDER BY last_name

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
#As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT 
	film.title
FROM sakila.film
WHERE (title like 'K%' OR title like 'Q%')
	AND  language_id = 
    (
		SELECT 
			language_id
		FROM sakila.language
        WHERE name = "English"
	)

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT 
	actor.first_name,
    actor.last_name,
    com_Film.title
FROM sakila.actor
	INNER JOIN 
		(
			SELECT 
				film.title,
                film_actor.actor_id
            FROM sakila.film
				LEFT JOIN sakila.film_actor
					ON film.film_id = film_actor.film_id
			WHERE film.title = 'Alone Trip'
		) com_Film
		ON actor.actor_id = com_film.actor_id
#Sorry, subqueries are inefficient and takes more processing power. Join is better for this questiion

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
#Use joins to retrieve this information.

SELECT 
	first_name,
    last_name,
    email
FROM sakila.customer
	LEFT JOIN sakila.address
		ON address.address_id = customer.address_id
WHERE city_id IN 
	(
		SELECT 
			city_id
		FROM sakila.city
			LEFT JOIN sakila.country
				ON country.country_id = city.country_id
		WHERE country.country = 'Canada'
	)

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
SELECT 
	film.title,
    cat.name as category_name
FROM sakila.film
	INNER JOIN 
		(
			SELECT film_category.category_id, film_category.film_id, category.name
            FROM sakila.film_category
				LEFT JOIN sakila.category
					ON category.category_id = film_category.category_id
			WHERE name = 'Family'
		) cat
        ON cat.film_id = film.film_id

#7e. Display the most frequently rented movies in descending order.
SELECT
	film.title,
    count(rent.rental_id) as num_rentals
FROM sakila.film
	LEFT JOIN
		(
			SELECT 
				film_id,
                rental.inventory_id,
                rental_id
			FROM sakila.rental
				LEFT JOIN sakila.inventory
					ON inventory.inventory_id = rental.inventory_id
		) rent
        ON rent.film_id = film.film_id
GROUP BY title
ORDER BY num_rentals DESC

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT
	store.store_id,
    sum(amount) AS revenue
FROM sakila.store
	LEFT JOIN
		(
			SELECT
                staff.store_id,
                staff.staff_id,
                rental_id,
                amount
            FROM sakila.staff
				LEFT JOIN 
					(
						SELECT
							rental.staff_id,
                            rental.rental_id,
                            amount
                        FROM sakila.rental
							LEFT JOIN sakila.payment
								ON payment.rental_id = rental.rental_id
					)rent
						ON staff.staff_id = rent.staff_id
		) sta
        ON store.store_id = sta.store_id

/*    
According to the query here, only staff_id 1 made made rentals

SELECT *
FROM sakila.staff
	LEFT JOIN sakila.rental
    ON staff.staff_id = rental.staff_id
*/

#7g. Write a query to display for each store its store ID, city, and country.
SELECT 
	store_id,
    add_city.city_name,
    add_city.country_name
FROM sakila.store
	LEFT JOIN
    (
		SELECT 
			address_id, 
			city_country.city_name,
            city_country.country_name
        FROM sakila.address
			LEFT JOIN 
				(
					SELECT 
						city_id,
                        city as city_name,
                        country.country as country_name
					FROM sakila.city
						LEFT JOIN sakila.country
							ON country.country_id = city.country_id
				)city_country
                ON city_country.city_id = address.city_id
	) add_city
    ON add_city.address_id = store.address_id


#7h. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT
	category.name as genres,
    film_cat_pay.revenue as gross_revenue
FROM sakila.category
	LEFT JOIN 
		(
			SELECT
				film_category.category_id,
                SUM(invent_pay.revenue) as revenue
			FROM sakila.film_category
				LEFT JOIN 
					(
						SELECT
							inventory.film_id,
                            SUM(rent_pay.revenue) as revenue
						FROM sakila.inventory
							LEFT JOIN 
								(
									SELECT
										rental.inventory_id,
                                        SUM(payment.amount) as revenue
									FROM sakila.payment
										LEFT JOIN sakila.rental
											ON rental.rental_id = payment.rental_id
									GROUP BY rental.inventory_id
								) rent_pay
								ON rent_pay.inventory_id = inventory.inventory_id
						GROUP BY inventory.film_id
					) invent_pay
                    ON film_category.film_id = invent_pay.film_id
            GROUP BY film_category.category_id
        ) film_cat_pay
        ON film_cat_pay.category_id = category.category_id
GROUP BY category.name
ORDER BY film_cat_pay.revenue DESC
LIMIT 5

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
USE sakila;
CREATE VIEW `top_5_genres_by_rev` AS
SELECT
	category.name as genres,
    film_cat_pay.revenue as gross_revenue
FROM sakila.category
	LEFT JOIN 
		(
			SELECT
				film_category.category_id,
                SUM(invent_pay.revenue) as revenue
			FROM sakila.film_category
				LEFT JOIN 
					(
						SELECT
							inventory.film_id,
                            SUM(rent_pay.revenue) as revenue
						FROM sakila.inventory
							LEFT JOIN 
								(
									SELECT
										rental.inventory_id,
                                        SUM(payment.amount) as revenue
									FROM sakila.payment
										LEFT JOIN sakila.rental
											ON rental.rental_id = payment.rental_id
									GROUP BY rental.inventory_id
								) rent_pay
								ON rent_pay.inventory_id = inventory.inventory_id
						GROUP BY inventory.film_id
					) invent_pay
                    ON film_category.film_id = invent_pay.film_id
            GROUP BY film_category.category_id
        ) film_cat_pay
        ON film_cat_pay.category_id = category.category_id
GROUP BY category.name
ORDER BY film_cat_pay.revenue DESC
LIMIT 5;


#8b. How would you display the view that you created in 8a?
SELECT *
FROM `top_5_genres_by_rev`

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW `top_5_genres_by_rev`;

