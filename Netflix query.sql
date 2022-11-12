Use Netflix_titles;

-- top 10 countries with most releases
Select country, count(release_year)
FROM netflix
Where country <> '' AND release_year <> '' 
Group By country
Order BY count(release_year) DESC
Limit 10;


-- individual years and how many titles were added to netflix that year
SELECT YEAR(date_added) AS 'date added', COUNT(Distinct(title)) AS 'number of titles'
from netflix 
GROUP BY YEAR(date_added)
ORDER BY YEAR(date_added) DESC ;




-- this shows which months are most popular for netflix additions
-- if you wanted your movie or tv show to stand out pick maybe feb or may date addition to netflix
Select  month(date_added) AS 'month added', count(title) as 'total added'
from netflix
GROUP BY month(date_added)
HAVING count(title)>0
ORDER BY count(title) DESC;

-- NUmber of movies vs tv shows
SELECT type, count(title) AS 'number of titles'
from netflix
GROUP by type;



-- most common ratings listed
SELECT rating, count(title)
from netflix
GROUP by rating
HAVING count(title) > 1 AND rating <> ''
ORDER BY count(title) DESC;

-- most prevalent directors (top 10)
SELECT director, count(title)
from netflix
GROUP by director
HAVING director <> ''
ORDER BY count(title) DESC
LIMIT 10;


-- date added vs release year 
SELECT 'date added' AS category, YEAR(date_added) AS 'year' ,  count(title)
from netflix
GROUP BY YEAR(date_added) 

UNION 

SELECT 'release year' AS category, release_year, count(title)
from netflix
GROUP BY release_year;



-- TV shows released b/w 1940 and 1970 
SELECT title, type, country, YEAR(date_added), release_year
from netflix
Where country <> '' AND type <> 'movie'
Having release_year BETWEEN '1940' AND '1970'
ORDER BY country;


-- movies released b/w 1940 and 1970 excluding any from the United States

SELECT title, type, country, YEAR(date_added), release_year
from netflix
Where country <> '' AND country NOT LIKE '%United States%' AND type = 'movie'
Having release_year BETWEEN '1940' AND '1970'
ORDER BY country;

-- drama movies with a rating of R or PG-13 since 2000
SELECT title, duration, rating, release_year
from netflix
where listed_in LIKE 'dramas' AND type = 'movie' AND rating = 'R' OR rating = 'PG-13'
HAVING release_year > 2000;

-- arbitrary viewership table with numbers to compare for joins
create database netflix_viewership;
USE netflix_viewership;
Create table views (id int, 
type text, 
views int, 
title text);

SELECT * FROM views;
INSERT INTO views VALUES (1,	'Movie',	3000000,	'Dick Johnson Is Dead'),
(2,	'TV Show',	9120888,	'Blood & Water'),
(3,	'TV Show',	10755000,	'Ganglands'),
(4,	'TV Show',	52985007,	'Jailbirds New Orleans');

ALTER TABLE 'netflix_viewership', 'netflix views' 
RENAME TO  'netflix_viewership', 'views' ;


-- views for shows first 100 shows in table

SELECT nv.title, country, views 
from netflix_viewership.views nv
JOIN Netflix_titles.netflix n
ON nv.id = n.id
WHERE country <> ''
ORDER BY views DESC;
