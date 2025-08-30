-- 1. Count the number of Movies vs TV Shows
select 
    type,
    count(show_id) as total_content
from netflix.movies
group by 1;

-- 2. Find the most common rating for movies and TV shows
select 
    type,
    rating
from (
    select 
        type,
        rating,
        count(*) as total_content,
        rank() over (
            partition by type 
            order by count(*) desc
        ) as ranking
    from netflix.movies
    group by 1, 2
    order by 1, 3 desc
) as ct
where ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
select 
    *
from netflix.movies
where release_year = 2020
  and type = 'Movie';

-- 4. Find the top 5 countries with the most content on Netflix
select 
    unnest(string_to_array(country, ',')) as new_country,
    count(show_id) as total_content
from netflix.movies
group by 1
order by 2 desc
limit 5;

-- 5. Identify the longest movie 
select 
    *
from netflix.movies 
where duration = (
    select max(duration) 
    from netflix.movies
);

-- 6. Find content added in the last 5 years
select 
    *
from netflix.movies
where to_date(date_added, 'month dd,yyyy') > current_date - interval '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'
select 
    *
from netflix.movies
where director ilike '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
select 
    *
from netflix.movies
where type = 'TV Show'
  and split_part(duration, ' ', 1)::numeric > 5;

-- 9. Count the number of content items in each genre
select 
    unnest(string_to_array(listed_in, ',')) as genre,
    count(show_id) as total_content
from netflix.movies
group by 1
order by 2 desc;

-- 10. Find each year and the average numbers of content release in India on Netflix.
--     Return top 5 years with highest avg content release!
select 
    extract(year from to_date(date_added, 'month dd,yyyy')) as year,
    count(show_id) as total_content,
    round(
        (count(show_id)::numeric 
         / (select count(*) 
            from netflix.movies 
            where country ilike '%India%')::numeric
        ) * 100, 2
    ) as avg_content
from netflix.movies
where country ilike '%India%'
group by 1
order by 3 desc;

-- 11. List all movies that are documentaries
select 
    *
from netflix.movies
where listed_in ilike '%documentaries%';

-- 12. Find all content without a director
select 
    *
from netflix.movies
where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select 
    *
from netflix.movies
where "cast" ilike '%Salman Khan%'
  and release_year > extract(year from current_date) - 11;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India
select 
    unnest(string_to_array("cast", ',')) as actor_name,
    count(show_id) as total_content
from netflix.movies
where country = 'India'
group by 1
order by 2 desc
limit 10;

-- 15. Categorize the content based on the presence of 'kill' or 'violence' in description
--     Label as 'Bad' else 'Good', then count
select 
    category,
    count(show_id) as total_content
from (
    select 
        *,
        case
            when description ilike '%kill%' or description ilike '%violence%' 
                then 'bad_content'
            else 'good_content'
        end as category
    from netflix.movies
) as ct 
group by 1;
