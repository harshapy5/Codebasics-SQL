-- SQL Joins (INNER, LEFT, RIGHT, FULL)

-- Print all movies along with their title, budget, revenue, currency and unit. [INNER JOIN]
SELECT m.movie_id, title, budget, revenue, currency, unit 
FROM movies m
INNER JOIN financials f
ON m.movie_id=f.movie_id;

-- Perform LEFT JOIN on above discussed scenario
SELECT m.movie_id, title, budget, revenue, currency, unit 
FROM movies m
LEFT JOIN financials f
ON m.movie_id=f.movie_id;

-- Perform RIGHT JOIN on above discussed scenario
SELECT 
m.movie_id, title, budget, revenue, currency, unit 
FROM movies m
RIGHT JOIN financials f
ON m.movie_id=f.movie_id;

-- Perform FULL JOIN using 'Union' on above two tables [movies, financials]
SELECT 
m.movie_id, title, budget, revenue, currency, unit 
FROM movies m
LEFT JOIN financials f
ON m.movie_id=f.movie_id

UNION

SELECT m.movie_id, title, budget, revenue, currency, unit 
FROM movies m
RIGHT JOIN financials f
ON m.movie_id=f.movie_id;

-- Interchanging the position of Left and Right Tables
Select m.movie_id, title, revenue 
from movies m 
left join financials f
on m.movie_id = f.movie_id;

Select m.movie_id, title, revenue 
from financials f 
left join movies m
on m.movie_id = f.movie_id;

-- Replacing 'ON' with 'USING' while joining conditions
Select m.movie_id, title, revenue 
from movies m 
left join financials f
USING (movie_id);

SELECT * FROM languages;
SELECT * FROM movies;
-- Show all the movies with their language names
SELECT m.movie_id,m.title,l.name 
FROM movies m JOIN languages l
USING (language_id);

-- Show all Telugu movie names (assuming you don't know the language id for Telugu)
SELECT title FROM movies m
JOIN languages l USING (language_id) WHERE l.name = 'Telugu';

-- Show the language and number of movies released in that language
SELECT l.name, COUNT(m.movie_id) AS cnt_movies
FROM languages l LEFT JOIN movies m 
ON l.language_id = m.language_id
GROUP BY l.language_id
ORDER BY cnt_movies DESC;

### Module: Cross Join

-- Print a list of final menu items along with their price for a restaurant.
SELECT *, CONCAT(name, " - ", variant_name) as full_name,(price+variant_price) as full_price
FROM food_db.items
CROSS JOIN food_db.variants;

-- Module: Analytics on Tables

-- Find profit for all movies 
SELECT m.movie_id, title, budget, revenue, currency, unit, (revenue-budget) as profit 
FROM movies m
JOIN financials f
ON m.movie_id=f.movie_id;

-- Find profit for all movies in bollywood
SELECT m.movie_id, title, budget, revenue, currency, unit, (revenue-budget) as profit 
FROM movies m
JOIN financials f
ON m.movie_id=f.movie_id
WHERE m.industry="Bollywood";

-- Find profit of all bollywood movies and sort them by profit amount (Make sure the profit be in millions for better comparisons)
SELECT m.movie_id, title revenue, currency, unit, 
CASE 
	WHEN unit="Thousands" THEN ROUND((revenue-budget)/100,2)
	WHEN unit="Billions" THEN ROUND((revenue-budget)*100,2)
ELSE revenue-budget
END as profit_mln
FROM movies m
JOIN financials f 
ON m.movie_id=f.movie_id
WHERE m.industry="Bollywood"
ORDER BY profit_mln DESC;

-- Module: Join More Than Two Tables

-- Show comma separated actor names for each movie
SELECT m.title, group_concat(name separator " | ") as actors
FROM movies m
JOIN movie_actor ma ON m.movie_id=ma.movie_id
JOIN actors a ON a.actor_id=ma.actor_id
GROUP BY m.movie_id;

-- Print actor name and all the movies they are part of
SELECT a.name, GROUP_CONCAT(m.title SEPARATOR ' | ') as movies
FROM actors a
JOIN movie_actor ma ON a.actor_id=ma.actor_id
JOIN movies m ON ma.movie_id=m.movie_id
GROUP BY a.actor_id;

-- Print actor name and how many movies they acted in
SELECT a.name, GROUP_CONCAT(m.title SEPARATOR ' | ') as movies,COUNT(m.title) as num_movies
FROM actors a
JOIN movie_actor ma ON a.actor_id=ma.actor_id
JOIN movies m ON ma.movie_id=m.movie_id
GROUP BY a.actor_id
ORDER BY num_movies DESC;

-- Generate a report of all Hindi movies sorted by their revenue amount in millions.
-- Print movie name, revenue, currency, and unit
SELECT title, revenue, currency, unit,
CASE	
	WHEN unit = 'Thousands' THEN ROUND(revenue/1000,2)
    WHEN unit = 'Billions' THEN ROUND(revenue*1000,2)
ELSE revenue
END AS revenue_mln
FROM movies m
JOIN financials f USING (movie_id)
JOIN languages l USING (language_id)
WHERE l.name= 'Hindi'
ORDER BY revenue_mln DESC;