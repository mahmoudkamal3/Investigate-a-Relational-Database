/* -------Question 1--------
We want to understand more about the movies that families are watching.
The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.

Create a query that lists each movie,
the film category it is classified in,
and the number of times it has been rented out.*/



WITH T1
AS (SELECT
  F.title AS Film_Title,
  C.name AS Category_Name
FROM Category C
JOIN Film_Category FC
  ON C.Category_id = FC.Category_id
JOIN Inventory I
  ON FC.Film_id = I.Film_id
JOIN Rental R
  ON I.Inventory_id = R.Inventory_id
JOIN Film F
  ON I.Film_id = F.Film_id
WHERE C.name = 'Animation'
OR C.name = 'Children'
OR C.name = 'Classics'
OR C.name = 'Comedy'
OR C.name = 'Family'
OR C.name = 'Music')

SELECT
  Film_Title,
  Category_Name,
  COUNT(*) AS Rental_Count
FROM T1
GROUP BY 1,
         2
ORDER BY 2,
         1;



/* -------Question 2--------
Now we need to know how the length of rental duration of these family-friendly movies
compares to the duration that all movies are rented for.

Can you provide a table with the movie titles and divide them into 4 levels
(first_quarter, second_quarter, third_quarter, and final_quarter)
based on the quartiles (25%, 50%, 75%) of the rental duration for movies across all categories?
Make sure to also indicate the category that these family-friendly movies fall into.*/

SELECT F.title,
       C.name,
       F.rental_duration,
       Ntile(4)
         OVER (
           partition BY F.rental_duration ) AS standard_quartile
FROM   category C
       JOIN film_category FC
         ON C.category_id = FC.category_id
       JOIN film F
         ON FC.film_id = F.film_id
WHERE  C.name = 'Animation'
        OR C.name = 'Children'
        OR C.name = 'Classics'
        OR C.name = 'Comedy'
        OR C.name = 'Family'
        OR C.name = 'Music';


/* --------Question 3---------
provide a table with the family-friendly film category,
each of the quartiles,
and the corresponding count of movies within each combination of film category for each corresponding rental duration category.
 */

WITH T1
AS (SELECT
  C.name AS Category,
  F.rental_duration,
  NTILE(4) OVER (ORDER BY F.rental_duration) AS standard_quartile

FROM Category C
JOIN Film_Category FC
  ON C.category_id = FC.category_id
JOIN Film F
  ON FC.film_id = F.film_id
WHERE C.name = 'Animation'
OR C.name = 'Children'
OR C.name = 'Classics'
OR C.name = 'Comedy'
OR C.name = 'Family'
OR C.name = 'Music')

SELECT
  Category,
  standard_quartile,
  COUNT(*)
FROM t1
GROUP BY 1,
         2
ORDER BY 1, 2;

/* -------Question 1--------
We want to find out how the two stores compare in their count of rental orders during every month for all the years we have data for.
Write a query that returns the store ID for the store,
the year and month and the number of rental orders each store has fulfilled for that month.
*/

SELECT
  DATE_part('month', r.rental_date) AS Rental_month,
  DATE_part('year', r.rental_date) AS Rental_year,
  s.store_id,
  COUNT(*) AS Count_Rental

FROM rental r
JOIN staff sf
  ON r.staff_id = sf.staff_id
JOIN store s
  ON sf.store_id = s.store_id
GROUP BY 1,
         2,
         3
ORDER BY 4 DESC;

/* -------Question 2--------
We would like to know who were our top 10 paying customers, how many payments they made on a monthly basis during 2007, and what was the amount of the monthly payments. Can you write a query to capture the customer name, month and year of payment, and total payment amount for each month by these top 10 paying customers? */


SELECT DATE_TRUNC('month', P.payment_date) pay_month,
 C.first_name || ' ' || C.last_name AS fullname, 
 COUNT(P.amount) AS pay_countpermon, 
 SUM(P.amount) AS pay_amount
FROM customer C
JOIN payment P
ON P.customer_id = C.customer_id
WHERE C.first_name || ' ' || C.last_name IN
(SELECT T1.fullname
FROM
(SELECT C.first_name || ' ' || c.last_name AS fullname, 
  SUM(p.amount) as pay_amount
FROM customer C
JOIN payment P
ON p.customer_id = C.customer_id
GROUP BY 1	
ORDER BY 2 DESC
LIMIT 10) T1) AND (p.payment_date BETWEEN '2007-01-01' AND '2007-12-31')
GROUP BY 2, 1
ORDER BY 2, 1, 3;
