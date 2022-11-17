USE covid_cases;
ALTER TABLE coviddeaths
ADD COLUMN new_date DATE;
UPDATE coviddeaths 
SET new_date = STR_TO_DATE('date', '%m/%d/%Y');

-- total cases vs deaths by continent and country code
-- also can show mortality rate of covid by country
Use covid_cases;
SELECT continent, location, sum(total_cases) AS 'total cases' , sum(total_deaths) AS 'total deaths', (total_deaths/total_cases)*100 AS 'mortality rate'
FROM coviddeaths
WHERE continent <> ''
GROUP BY 1,2, 5
Order by 1,2;

 
-- vaccination rates by population in relation to location
SELECT location, 
SUM(people_vaccinated/population)*100 AS 'population vacc rate',  
SUM(people_fully_vaccinated/population)*100 AS 'fully vaccinated rate'
FROM coviddeaths
WHERE population <> '' AND people_vaccinated <> '' AND people_fully_vaccinated <> '' 
GROUP BY 1
LIMIT 50;

-- top countries with highest death rate
SELECT location, population, 
MAX(total_deaths) AS 'total deaths', 
SUM(total_deaths/population)*100 AS 'Death Rate'
FROM coviddeaths
WHERE total_deaths <> ''
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 20;


-- countries health factors in accordance to their total deaths
SELECT cd.location, SUM(cd.total_deaths), SUM(cv.extreme_poverty), (cv.diabetes_prevalence), SUM(cv.female_smokers), SUM(cv.male_smokers),
cv.life_expectancy
FROM covid_cases.coviddeaths cd
JOIN covid_vacc.covidvaccinations cv
	ON cd.date = cv.date
    AND cd.location = cv.location
WHERE cv.life_expectancy <> ''
GROUP BY 1,4,7
ORDER BY 2 DESC
LIMIT 10;

-- Join to compare cases, deaths, tests and vaccinations
SELECT cd.continent, cd.location, cd.total_cases, cd.total_deaths, cv.total_tests, cv.total_vaccinations
FROM covid_cases.coviddeaths cd
JOIN covid_vacc.covidvaccinations cv
ON cd.total_vaccinations = cv.total_vaccinations
AND cd.location = cv.location
WHERE cd.continent <> ''
ORder BY 1,2;


-- Partition by to allow for window functions and see vaccination rate compared to sums

SELECT cd.continent, cd.location,
SUM(cd.total_cases) OVER (Partition BY cd.location ORder by cd.location) AS 'total cases',
SUM(cv.total_vaccinations) OVER (Partition BY cv.location ORder BY cv.location) AS 'total vaccinations',
(cv.total_vaccinations/cd.total_cases)*100 AS 'vacc rate'
FROM covid_cases.coviddeaths cd
JOIN covid_vacc.covidvaccinations cv
ON cd.total_vaccinations = cv.total_vaccinations
AND cd.location = cv.location
WHERE cd.continent <> ''
ORder BY 1,2
LIMIT 10;

-- subquery showing new cases and death sums in Europe
SELECT cd.location, SUM(cd.new_cases), SUM(cd.new_deaths)
FROM covid_cases.coviddeaths cd
WHERE location IN (SELECT location
					FROM covid_vacc.covidvaccinations cv
                    WHERE continent = 'Europe')
GROUP BY 1
ORDER BY 2 DESC;

-- number of smokers in countries with more thena 1000 deaths from covid
-- could allow for analysis on potential correlation
SELECT cv.location, SUM(cv.female_smokers), SUM(cv.male_smokers)
FROM covid_vacc.covidvaccinations cv
WHERE cv.population_density IN (SELECT cd.population_density
					FROM  covid_cases.coviddeaths cd
                    WHERE total_deaths > 1000
                    GROUP BY cd.location)
GROUP BY 1;

