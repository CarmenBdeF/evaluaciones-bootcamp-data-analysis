-- Evaluación Final Módulo 2: SQL

USE sakila;

-- 1. Selecciona todos los nombres de las películas sin que aparezcan duplicados.

SELECT DISTINCT title
FROM film;

-- 2. Muestra los nombres de todas las películas que tengan una clasificación de "PG-13".

SELECT title, rating
FROM film
WHERE rating = 'PG-13';

/*-- 3. Encuentra el título y la descripción de todas las películas que contengan la palabra
 "amazing" en su descripción.*/
 
SELECT title, description
FROM film
WHERE description LIKE '%amazing%';

 
-- 4. Encuentra el título de todas las películas que tengan una duración mayor a 120 minutos.

SELECT title, length
FROM film
WHERE length > 120;

-- 5. Recupera los nombres de todos los actores.

SELECT CONCAT(first_name, ' ', last_name) AS full_name 
FROM actor;

-- 6. Encuentra el nombre y apellido de los actores que tengan "Gibson" en su apellido.

SELECT first_name, last_name, actor_id
FROM actor
WHERE last_name = 'Gibson';

-- 7. Encuentra los nombres de los actores que tengan un actor_id entre 10 y 20.

SELECT first_name, last_name, actor_id
FROM actor
WHERE actor_id BETWEEN 10 AND 20;

/*-- 8. Encuentra el título de las películas en la tabla film que no sean ni "R" ni
"PG-13" en cuanto a su clasificación.*/

SELECT title, rating
FROM film
WHERE rating NOT IN ('R', 'PG-13');


/*-- 9. Encuentra la cantidad total de películas en cada clasificación de la tabla film y 
muestra la clasificación junto con el recuento.*/

SELECT rating, COUNT(*) AS cantidad
FROM film
GROUP BY rating;

/*-- 10. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID 
del cliente, su nombre y apellido junto con la cantidad de películas alquiladas.*/

SELECT customer_id, first_name, last_name,  COUNT(c.customer_id) AS 'rented_movies'
FROM customer AS c
INNER JOIN rental
USING (customer_id)
INNER JOIN inventory
USING (inventory_id)
INNER JOIN film
USING (film_id)
GROUP BY customer_id;

/*-- 11. Encuentra la cantidad total de películas alquiladas por categoría y muestra el 
nombre de la categoría junto con el recuento de alquileres.*/

SELECT c.name AS 'category_name', COUNT(r.rental_id) AS total_rentals
	FROM rental r
INNER JOIN inventory AS i 
	ON r.inventory_id = i.inventory_id
INNER JOIN film AS f 
	ON i.film_id = f.film_id
INNER JOIN film_category AS f_cat 
	ON f.film_id = f_cat.film_id
INNER JOIN category AS c 
	ON f_cat.category_id = c.category_id
GROUP BY c.name
	ORDER BY category_name ASC;


/*-- 12. Encuentra el promedio de duración de las películas para cada clasificación de la 
tabla film y muestra la clasificación junto con el promedio de duración.*/

SELECT rating, AVG(length)
FROM film
GROUP BY rating;

/*-- 13. Encuentra el nombre y apellido de los actores que aparecen en la película con
title "Indian Love".*/

SELECT a.first_name, a.last_name, f.title AS film_name
FROM actor AS a 
INNER JOIN film_actor
	USING (actor_id)
INNER JOIN film AS f
	USING (film_id)
WHERE f.title = 'Indian Love'; -- he añadido WHERE para asegurarme

/*-- 14. Muestra el título de todas las películas que contengan la palabra "dog" o "cat"
en su descripción.*/

SELECT title, description
FROM film_text
WHERE description LIKE '%dog%'

UNION -- para quitar duplicados

SELECT title, description
FROM film_text
WHERE description LIKE '%cat%'
ORDER BY title ASC; -- creo que puede causar problemas porque podría coger palabras que contengan esas letras.

-- 15. Hay algún actor o actriz que no aparezca en ninguna película en la tabla film_actor.

SELECT a.actor_id, a.first_name, a.last_name
FROM actor AS a
LEFT JOIN film_actor AS f_act 
	ON a.actor_id = f_act.actor_id
WHERE f_act.actor_id IS NULL; -- no hay ningún actor/ actriz que no aparezca en ninguna película en la tabla film_actor.

-- Alternativa con subconsulta:
SELECT a.first_name, a.last_name
FROM actor AS a
WHERE actor_id NOT IN (SELECT actor_id FROM film_actor);


-- 16. Encuentra el título de todas las películas que fueron lanzadas entre el año 2005 y 2010.

SELECT title, release_year
FROM film
WHERE release_year BETWEEN 2005 AND 2010;

-- O:
SELECT title, release_year
FROM film
WHERE release_year >= 2005 AND release_year <= 2010;


-- 17. Encuentra el título de todas las películas que son de la misma categoría que "Family".

SELECT f.title AS film_name, c.name AS category_name
FROM film AS f
INNER JOIN film_category AS f_cat
	USING (film_id)
INNER JOIN category AS c
	USING (category_id)
WHERE name = 'Family';

-- 18. Muestra el nombre y apellido de los actores que aparecen en más de 10 películas.
-- Con GROUP BY y HAVING:

SELECT 
    a.actor_id,
    a.first_name,
    a.last_name,
    COUNT(f_act.film_id) AS films_total
FROM actor AS a
INNER JOIN film_actor AS f_act
	ON a.actor_id = f_act.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
HAVING COUNT(f_act.film_id) > 10
ORDER BY films_total ASC;

 -- Con subconsulta:
SELECT a.first_name, a.last_name, films_total
FROM actor AS a
INNER JOIN (
    SELECT actor_id, COUNT(film_id) AS films_total
    FROM film_actor
    GROUP BY actor_id
    HAVING COUNT(film_id) > 10
) AS actores 
ON a.actor_id = actores.actor_id
ORDER BY films_total ASC;

/*-- 19. Encuentra el título de todas las películas que son "R" y tienen una duración mayor 
a 2 horas en la tabla film.*/

SELECT title, length, rating
FROM film
WHERE rating = 'R' AND length > 120
ORDER BY length ASC;

/*-- 20. Encuentra las categorías de películas que tienen un promedio de duración superior 
a 120 minutos y muestra el nombre de la categoría junto con el promedio de duración.*/

SELECT c.name AS category_name, AVG(f.length) AS avg_length
FROM category AS c
INNER JOIN film_category AS f_cat 
	ON c.category_id = f_cat.category_id
INNER JOIN film AS f 
	ON f_cat.film_id = f.film_id
GROUP BY c.name
HAVING AVG(f.length) > 120
ORDER BY avg_length ASC;


/*-- 21. Encuentra los actores que han actuado en al menos 5 películas y muestra el nombre
del actor junto con la cantidad de películas en las que han actuado.*/

SELECT 
    a.first_name, 
    a.last_name, 
    COUNT(f_act.film_id) AS total_films
FROM actor AS a
INNER JOIN film_actor AS f_act 
	ON a.actor_id = f_act.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
HAVING COUNT(f_act.film_id) >= 5 -- para filtrar solo los que han hecho al menos 5 pelis
ORDER BY total_films ASC;

/*-- 22. Encuentra el título de todas las películas que fueron alquiladas por más de 5 días. 
Utiliza una subconsulta para encontrar los rental_ids con una duración superior a 5 días y
luego selecciona las películas correspondientes.*/

SELECT f.title
FROM film AS f
WHERE film_id IN (
    SELECT DISTINCT i.film_id
    FROM inventory AS i
    INNER JOIN rental AS r
		ON i.inventory_id = r.inventory_id
    WHERE DATEDIFF(return_date, rental_date) > 5);


/*-- 23. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película
de la categoría "Horror". Utiliza una subconsulta para encontrar los actores que han actuado
 en películas de la categoría "Horror" y luego exclúyelos de la lista de actores.*/
 
SELECT a.first_name, a.last_name
FROM actor AS a
WHERE a.actor_id NOT IN (
    SELECT DISTINCT f_act.actor_id
    FROM film_actor AS f_act
    INNER JOIN film_category AS f_cat 
		ON f_act.film_id = f_cat.film_id
    INNER JOIN category AS c 
		ON f_cat.category_id = c.category_id
    WHERE c.name = 'Horror'
)
ORDER BY a.last_name, a.first_name;
 
 -- Alternativa: actores que han actuado en Horror (Incluidos)
SELECT DISTINCT a.first_name, a.last_name, 'Included' AS category
FROM actor AS a
INNER JOIN film_actor AS f_act 
	ON a.actor_id = f_act.actor_id
INNER JOIN film_category AS f_cat 
	ON f_act.film_id = f_cat.film_id
JOIN category AS c 
	ON f_cat.category_id = c.category_id
WHERE c.name = 'Horror'

UNION

-- Actores que NO han actuado en Horror (Excluidos)
SELECT a.first_name, a.last_name, 'Excluded' AS category
FROM actor AS a
WHERE a.actor_id NOT IN (
    SELECT f_act.actor_id
    FROM film_actor AS f_act
    INNER JOIN film_category AS f_cat 
		ON f_act.film_id = f_cat.film_id
    INNER JOIN category AS c 
		ON f_cat.category_id = c.category_id
    WHERE c.name = 'Horror'
)
ORDER BY category, last_name, first_name;
 
/*-- 24. Encuentra el título de las películas que son comedias y tienen una duración mayor
a 180 minutos en la tabla film.*/

SELECT f.title AS film_name, c.name AS category_name, f.length
FROM film AS f
JOIN film_category AS f_cat 
	ON f.film_id = f_cat.film_id
INNER JOIN category AS c 
	ON f_cat.category_id = c.category_id
WHERE c.name = 'Comedy' AND f.length > 180
ORDER BY f.length ASC;

-- Alternativa:
SELECT title
FROM film
WHERE length > 180 AND film_id IN (
		SELECT film_id
		FROM film_category
		WHERE category_id = (SELECT category_id FROM category WHERE name = 'Comedy'));

