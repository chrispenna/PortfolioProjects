
--Data being used below

--Total deaths accrued over time + new cases per day

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE location IN ('United States')
ORDER BY 1,2 DESC

--Total deaths accrued over time + new cases per day
-- + Covid deaths per 100 cases in specified country

SELECT location, date, total_cases, total_deaths, CONCAT(ROUND((total_deaths/NULLIF(total_cases,0)),4) * 100, '%') AS deaths_per_100
FROM PortfolioProject.dbo.CovidDeaths
WHERE location IN ('United States')
ORDER BY 1, 2 DESC

--Viewing total cases, countries population, and % of specified countries population who has had Covid 19

SELECT location, date, total_cases, population, CONCAT(ROUND((total_cases/population),4)*100, '%') AS current_pop_who_had_c19
FROM PortfolioProject.dbo.CovidDeaths
WHERE location IN ('United States')
ORDER BY 1, 2 

--All countries population % infected with Covid 19 from descending order

SELECT location, population, CONCAT(ROUND(MAX((total_cases) / population), 4) * 100, '%') AS pop_infected_with_covid
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY CAST(REPLACE(CONCAT(ROUND(MAX((total_cases) / population), 4) * 100, '%'), '%', '') AS DECIMAL) DESC;


--Countries # of mortalities from descending order

SELECT location, MAX(total_deaths) AS total_death_count
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--Continents # of mortalities from descending order

SELECT continent, MAX(total_deaths) AS continent_deaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

--Total global cases, deaths and deaths per 100 cases

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, ROUND((SUM(new_deaths) / NULLIF(SUM(new_cases), 0)),4)*100  AS death_per100_cases
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Each countries population vs # of shots % ratio using a CTE

WITH cte (continent, location, date, population, new_vaccinations, covid_shots) 
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition by d.location
ORDER BY d.location, d.date) AS covid_shots
FROM PortfolioProject.dbo.CovidDeaths d
JOIN PortfolioProject.dbo.CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
)

SELECT *, CONCAT(ROUND((covid_shots / population), 4) * 100, '%') AS shots_to_population
FROM cte
WHERE location = 'United States'


-- Temp Table

DROP TABLE IF exists #PercentPopulationToShotsRatio
CREATE TABLE #PercentPopulationToShotsRatio
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
covid_shots numeric
)

INSERT INTO #PercentPopulationToShotsRatio
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition by d.location
ORDER BY d.location, d.date) AS covid_shots
FROM PortfolioProject.dbo.CovidDeaths d
JOIN PortfolioProject.dbo.CovidVaccinations v
ON d.location = v.location
AND d.date = v.date


SELECT *,ROUND((covid_shots/population),4)*100 AS shots_to_population_ratio
FROM #PercentPopulationToShotsRatio
ORDER BY 2, 3

--Creating view to store data for later visualiztions

Create View PercentPopulationToShotsRatio AS 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition by d.location
ORDER BY d.location, d.date) AS covid_shots
FROM PortfolioProject.dbo.CovidDeaths d
JOIN PortfolioProject.dbo.CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL