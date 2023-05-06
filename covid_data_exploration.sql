select @@global.sql_mode;
set @@global.sql_mode := replace(@@global.sql_mode, 'ONLY_FULL_GROUP_BY', '');
SELECT 
    *
FROM
    covid_deaths;
SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    covid_deaths;

-- looking at Total Cases vz Total Deaths

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 as death_precent
    from
    covid_deaths
        where location like '%states%';


-- looking at Total Cases vz Population
SELECT 
    location,
    date,
	population,
    total_cases,
    (total_cases/population)*100 as cases_precent_of_pop
    from
    covid_deaths
    where location = 'Egypt';
    
    -- looking at Countries that Has Highest Infection Rate
SELECT 
    location,
    population,
    MAX(total_cases) AS highest_infiction_count,
    MAX((total_cases / population)) * 100 AS cases_precent_of_population
FROM
    covid_deaths
WHERE
continent != '0'
GROUP BY location , population
ORDER BY cases_precent_of_population DESC;


-- Showing Countries with Highest Deaths Count per Population

SELECT 
    location,
    population,
    MAX(total_deaths) AS highest_deaths_count,
    MAX((total_deaths / population)) * 100 AS deaths_precent_of_population
FROM
    covid_deaths
where continent != '0'
GROUP BY location , population
ORDER BY highest_deaths_count DESC;

-- showing the continents highest death count
SELECT 
    continent,
    population,
    MAX(total_deaths) AS highest_deaths_count,
    MAX((total_deaths / population)) * 100 AS deaths_precent_of_population
FROM
    covid_deaths
where continent != '0'
GROUP BY continent ;

-- Global Numbers 

SELECT 
    date, SUM(new_cases)as new_cases_sum,sum(new_deaths) as new_deaths_sum, SUM(new_deaths)/SUM(new_cases) as death_percentage
FROM
    covid_deaths
where continent != '0'
GROUP BY date
ORDER BY date,new_cases_sum;

-- joining the two tables together
SELECT 
    *
FROM
    covid_deaths cd
        JOIN
    covid_vaccinations cv ON cd.date = cv.date
        AND cd.location = cv.location ;

-- looking at total population vz total vaccination with CTE
with population_vz_vaccination (continent,location,date,population,new_vaccinations,total_vaccinated_per_day) 
as
(
SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    sum(cv.new_vaccinations) over (partition by cd.location order by cd.date, cd.location) 
    as total_vaccinated_per_day
    -- (total_vaccinated_per_day / cd.population) *100
FROM
    covid_deaths cd
        JOIN
    covid_vaccinations cv ON cd.date = cv.date
        AND cd.location = cv.location
        where cd.continent != '0'
        order by cd.location, cd.date
)
select * ,(total_vaccinated_per_day/population)*100 as pop_vz_vacc
from population_vz_vaccination ;



-- looking at total population vz total vaccination with TEMP TABLE
DROP TEMPORARY TABLE IF EXISTS population_vaccinated_percentag;
CREATE TEMPORARY  TABLE population_vaccinated_percentag
(
continent nvarchar(250),
location nvarchar(250),
date date,
population int,
new_vaccinations int ,
total_vaccinated_per_day int 
);
insert into population_vaccinated_percentag 
SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    sum(cv.new_vaccinations) over (partition by cd.location order by cd.date, cd.location) 
    as total_vaccinated_per_day
    -- (total_vaccinated_per_day / cd.population) *100
FROM
    covid_deaths cd
        JOIN
    covid_vaccinations cv ON cd.date = cv.date
        AND cd.location = cv.location
        where cd.continent != '0'
        order by cd.location, cd.date;
        
select * ,(total_vaccinated_per_day/population)*100 as pop_vz_vacc
from population_vaccinated_percentag  ;

-- Create a View for total population vaccinated
create view total_people_vaccinated as
SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    sum(cv.new_vaccinations) over (partition by cd.location order by cd.date, cd.location) 
    as total_vaccinated_per_day
    -- (total_vaccinated_per_day / cd.population) *100
FROM
    covid_deaths cd
        JOIN
    covid_vaccinations cv ON cd.date = cv.date
        AND cd.location = cv.location
        where cd.continent != '0'
        order by cd.location, cd.date;
	
    
    -- Queries used for Tableau Project
-- 1. 

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage
From covid_deaths
-- Where location like '%states%'
where continent != '0'  
-- Group By date
order by 1,2;

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


-- Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
-- From PortfolioProject..CovidDeaths
-- Where location like '%states%'
-- where location = 'World'
-- Group By date
-- order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select continent, SUM(new_deaths) as total_death_count
From covid_deaths
-- Where location like '%states%'
Where continent != '0' 
and location not in ('World', 'European Union', 'International')
Group by continent
order by total_death_count desc;


-- 3.

Select location, population, MAX(total_cases) as highest_infection_count,
  Max((total_cases/population))*100 as percent_population_infected
From covid_deaths
-- Where location like '%states%'
Group by location, population
order by percent_population_infected desc;


-- 4.


Select location, population,date, MAX(total_cases) as highest_infection_count,
  Max((total_cases/population))*100 as percent_population_infected
From covid_deaths
-- Where location like '%states%'
Group by location, population, date
order by percent_population_infected desc;




