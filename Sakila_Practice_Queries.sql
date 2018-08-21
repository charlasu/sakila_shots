/* Clarify the database to use */
USE sakila;


/*1a: Display the first & last names of thespians from Actor table*/
SELECT first_name, last_name
FROM actor;


/*1b: Create a new column that joins the 2 name columns into a single column*/
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS `actor_name`
FROM actor;




/*2a Find actors with the first name of Mary */
SELECT * FROM actor
WHERE first_name = 'Mary';


/*2b Find all actors whose last name contain the letters "gen" */
SELECT last_name
FROM actor
WHERE last_name LIKE '%gen%' OR 'Gen%';


/*2c Find actors whose last name contains "li" and order rows by last name and first name (in that order) */
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE '%li%'
ORDER BY last_name;


/*2d Display Afghanistan, Bangladesh, and China */
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');




/*3a Add a Description column to the actor table and code it as a BLOB ... of course, this makes little sense to code an entire text description as BLOB instead of TEXT b/c of course you would want to query it */
ALTER TABLE actor
ADD COLUMN description BLOB AFTER actor_name;


/*3b Delete the Description column ... too much hassle to write descriptions! ;-p */
ALTER TABLE actor
DROP COLUMN description;




/*4a List the last names of actors + do a count on actors names*/
SELECT last_name, (SELECT COUNT(last_name)) AS 'Number of Actors w/Same Name'
FROM actor 
GROUP BY last_name;


/*4b Take 4a and show only those actors with shared last names */
SELECT last_name, (SELECT COUNT(last_name)) AS 'Number of Actors w/Same Name'
FROM actor 
GROUP BY last_name
HAVING last_name > 2;


/*4c Revise first name of actor */
UPDATE actor
SET first_name = 'Harpo' WHERE last_name = 'Williams' AND first_name = 'Groucho';


/*4d Reverse course on the previous query */
UPDATE actor
SET first_name = 'Groucho' WHERE last_name = 'Williams' AND first_name = 'Harpo';



/*5a Recreate the schema of the address table */
DESCRIBE sakila.address;




/*6a Join the staff & address tables to display first/last names and addresses*/
SELECT address.address_id, staff.first_name, staff.last_name, address.address, address.address2, address.postal_code
FROM staff
INNER JOIN address ON
staff.address_id=address.address_id;
 

/*6b Use aggregates to detmerine SUM of sales per staff member in August 2005 */
SELECT staff.staff_id, staff.first_name, staff.last_name, SUM(payment.amount)
FROM staff
JOIN payment ON staff.staff_id=payment.staff_id
WHERE payment_date LIKE '%2005-08%'
GROUP BY staff_id;


/*6c List of films and the number of actors per movie */
SELECT film.title, COUNT(film_actor.actor_id) AS 'Number of Actors'
FROM film_actor 
JOIN film ON film_actor.film_id=film.film_id
GROUP BY title; 


/*6d Count of Hunchback Impossible */
SELECT title, (SELECT COUNT(*) FROM inventory WHERE film.film_id = inventory.film_id ) AS 'Number of Copies'
FROM film WHERE title = 'Hunchback Impossible';


/*6e Total paid per customer (list alphabetically)*/
SELECT customer.customer_id., customer.first_name, customer.last_name, payment.customer_id, SUM(payment.amount) AS 'Total Amt. Paid' 
FROM payment
JOIN customer ON payment.customer_id=customer.customer_id
GROUP BY customer.last_name;



/*7a Show movie titles that begin with either a K- or Q- and are in English ... */
SELECT title
FROM film
WHERE title LIKE 'K%' or title LIKE 'Q%'
AND language_id IN
(
  SELECT language_id
  FROM language
  WHERE name = 'English'
);


/*7b Display all actors from the movie Alone Trip */
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
	SELECT actor_id
    FROM film_actor
    WHERE film_id IN
    (
		SELECT film_id
		FROM film
		WHERE title = 'Alone Trip'
    )
);
	

/*7c Find the names and emails for all Canadian customers */
SELECT customer.first_name, customer.last_name, customer.email, country.country
FROM customer 
JOIN address ON customer.address_id = address.address_id
JOIN city ON city.city_id = address.city_id
JOIN country ON country.country_id = city.country_id
WHERE country.country = 'Canada';


/*7d identify all movies categorized as family films */
SELECT title
FROM film
WHERE film_id IN
(
	SELECT film_id
    FROM film_category
    WHERE category_id IN
    (
		SELECT category_id
		FROM category
		WHERE name = 'Family'
    )
);


/*7e Most frequently rented movies (descending) */
SELECT film.title, COUNT(rental_id) AS '# of Rentals'
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
GROUP BY title
ORDER BY `# of Rentals` DESC;


/*7f Show the amount ($) of business per store */
SELECT store.store_id, SUM(payment.amount) AS 'Total Sales'
FROM store
JOIN inventory ON store.store_id = inventory.store_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON rental.rental_id=payment.rental_id
GROUP BY store_id;


/*7g Show each store ID along with it's city & country */
SELECT store.store_id, address.address_id, city.city, country.country 
FROM store 
JOIN address ON store.address_id = address.address_id
JOIN city ON city.city_id = address.city_id
JOIN country ON country.country_id = city.country_id;


/*7h Top 5 genres for gross revenue */
SELECT category.name AS 'Genre', SUM(payment.amount) AS 'Gross Revenue'
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN inventory ON film_category.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category.name 
ORDER BY `Gross Revenue` DESC
LIMIT 5;




/*8a Create a View of 7h */
CREATE VIEW top_5_genres AS 

SELECT category.name AS 'Genre', SUM(payment.amount) AS 'Gross Revenue'
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN inventory ON film_category.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category.name 
ORDER BY `Gross Revenue` DESC
LIMIT 5;


/*8b Display View from 8a */
SELECT * FROM top_5_genres;

/*8c Write query that deletes the 8a View */
DROP VIEW top_5_genres;










