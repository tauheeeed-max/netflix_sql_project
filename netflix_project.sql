drop table if exists netflix
create table netflix(
	show_id varchar(6),
	type varchar(10),
	title varchar(150),
	director varchar(210),
	casts varchar(1000),
	country varchar(150),
	date_added date,
	release_year int,
	rating varchar(10),
	duration varchar(15),
	listed_in varchar(150),
	description varchar(250)

);

-- 1 Count the number of Movies vs TV Shows

select type, count(*)
from netflix
group by type ;

-- 2 Find the most coomn rating for movies and TV shows

select type,rating,mst_rating
from (
	select type,rating,count(*) mst_rating,
	rank() over (partition by type order by count(*) desc) as rn
	from netflix
	group by 1 ,2
)
where rn=1 ;

-- 3 List all movies released in as specific year 2020

select type,title,release_year 
from netflix
where
	type  = 'Movie'
	and
	release_year=2020 ;


-- 4 Find the top 5 countries with the most content on netflix

select unnest(string_to_array(country,',')) as new_country,
count(*) as content_count
from netflix
group by 1
order by 2 desc ;

-- 5 Identify the longest movie

select *
from netflix
where type='Movie'
		and
	  duration=(select max(duration) from netflix)
order by 2 ;

-- 6 Find content added in the last five years

select *
from netflix
where date_added >= current_date-interval ' 5years' ;

-- 7 Find all the Movies / TV Shows by director 'Rajiv Chilaka'

select *
from netflix
where director ilike '%Rajiv Chilaka%' ;

-- 8 List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE 
	type ='TV Show'
	AND
	SPLIT_PART(duration,' ',1)::numeric >  5 ;


-- 9 Count the number of content items in each genre

SELECT 
	   UNNEST(STRING_TO_ARRAY(listed_in,',')),
	   COUNT(show_id) as total_content
FROM netflix
GROUP BY 1 ;

/* 10 Find each year and the average nubers of content release in India on Netflix,
return top 5 year with highest average content release */

SELECT 
	EXTRACT(YEAR FROM date_added) as date,
	COUNT(*) as yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT (*) FROM netflix WHERE country ='India')::numeric * 100 
	, 2)as avg_content_per_year
FROM netflix
WHERE country='India'
GROUP BY 1 ;

-- 11 List all movies that are documentaries

SELECT *
FROM netflix
WHERE 
	listed_in ILIKE '%Documentaries%' ;


-- 12 Find all content without director

SELECT *
FROM netflix
WHERE 
	director IS NULL ;


-- 13 Find how may movies actor 'Salman Khan' appeared in last 10 years

SELECT *
FROM netflix
WHERE 
	casts ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) -10 ;

-- 14 Find the top 10 actors who have appeared in the highest number of movies produced in India

SELECT
UNNEST(STRING_TO_ARRAY(casts,',')) as actors,
COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10 ;

/* 15 Categorize the content based on the presence of the keywords 'kill' and 'violence' in
the description field . Label content containing these keywords as 'Bad' and all other
content as 'Good'. Count how many items fall into each category. */

with new_cte 
as(
SELECT
*,
	CASE
	WHEN description ILIKE '%kill%' OR
		 description ILIKE '%violence%' THEN 'Bad_Content'
		 ELSE 'Good_Content'
	END category
FROM netflix
)
SELECT
	category,
	COUNT(*) as total_content
FROM new_cte
GROUP BY 1 ;
















