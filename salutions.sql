--- Netflix Project

DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix
(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);

SELECT * FROM netflix;

SELECT 
     	COUNT(*) AS total_count
FROM netflix;

SELECT 
	DISTINCT(type)
FROM netflix;

---  15 Business Problems

--- 1. Count the number of Movies vs TV Shows

SELECT TYPE, COUNT(*) AS total_shows
FROM netflix
GROUP BY TYPE;

--- 2. Find the most common rating for movies and TV shows
SELECT 
	type,
	rating
FROM	
(
    SELECT 
		type, 
		rating,
		count(*),
		RANK() OVER(PARTITION BY type ORDER BY  count(*) DESC) AS ranking
	from netflix
	GROUP BY 1, 2
) as t1
WHERE 
	ranking = 1;

--- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE 
	release_year = 2020
	AND 
	type = 'Movie';

--- 4. Find the top 5 countries with the most content on netflix
SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY total_content DESC
LIMIT 5;

--- 5. Identify the longest movie?

SELECT * 
FROM netflix
WHERE 
	type = 'Movie'
	AND 
	duration = (SELECT MAX(duration) FROM netflix);

--- 6. Find content added in the last 5 years

SELECT 
	*
FROM netflix
WHERE TO_DATE(date_added,'MONTH DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

--- 7. Find all movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

--- 8. List all the TV shows with more than 5 seasins

SELECT *
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	duration > '5 Seasons';

OR

SELECT *
FROM netflix 
WHERE
	type = 'TV Show'
	AND 
	SPLIT_PART(duration, ' ', 1):: numeric > 5;

--- 9.Count the number of items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id)
FROM netflix
GROUP BY 1;

--- 10. Find each year and the average numbers of content release by India on netflix.
--- return top 5 with highest avg content release !
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
	COUNT(*) as yearly_content,
	ROUND(
	COUNT(*)::NUMERIC /(SELECT COUNT(*) FROM netflix WHERE country = 'India') ::NUMERIC * 100
 	,2) AS avg_content_per_year
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--- 11. List all movies that are documentaries

SELECT *
FROM netflix
WHERE listed_in LIKE '%Documentaries%'

--- 12. Find all content without a director

SELECT *
FROM netflix
WHERE director is null;

-- 13. Find how many movies actors 'Salman Khan' appears in last 10 years;

SELECT COUNT(*) AS total_movies
FROM netflix
WHERE 
	release_year >= EXTRACT( YEAR FROM CURRENT_DATE) - 10
	AND
	casts LIKE '%Salman Khan%';

--- 14. Find the top 10 actors who are appeared in the highest number of movies produced in india

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors,
	COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%india'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

--- 15. Categorise the content on the presece of the keywords 'kill' and 'violence' in the description fieid. 
--- lebel content containing these keywords as 'Bad' and all other content as 'Good'. 
--- Count how many items fall into each category;

WITH new_table
AS
(
SELECT 
	*,
	CASE 
	WHEN description ILIKE '%kill%' OR
	     description ILIKE '%violence%' THEN 'Bad_film'
	ELSE 'Good_film' 
	END AS category
FROM netflix
)

SELECT 
	category,
	COUNT(*) AS total
FROM new_table
GROUP BY 1;
