SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--UPDATE PortfolioProject.dbo.CovidDeaths
--SET continent = NULLIF(continent, '')
--WHERE continent = '';


--SELECT * 
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3, 4

--Data being used below

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE location IN ('United States')
ORDER BY 1,2 desc

--Viewing Total Cases vs Total Deaths
--Shows liklihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, ROUND((total_deaths/NULLIF(total_cases,0)),4)*100 AS deaths_per_100
FROM PortfolioProject.dbo.CovidDeaths
WHERE location IN ('United States')
ORDER BY 1, 2 DESC

--Viewing Total Cases vs Population
--Shows what percentage of population got Covid over time

SELECT Location, date, total_cases, population, ROUND((total_cases/population),4)*100 AS current_pop_who_had_c19
FROM PortfolioProject.dbo.CovidDeaths
WHERE location IN ('United States')
ORDER BY 1, 2 

--Viewing Countries with Highest Infection Rate relative to Population

SELECT location, population, MAX((total_cases)/population)*100 AS Population_Percent_Infected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY 3 desc 

--Showing Countries with the Highest Number of Mortalities

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 desc

--Showing continents with the highest death count

SELECT continent, MAX(cast(total_deaths AS int)) AS continent_deaths
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC

--Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, ROUND((SUM(new_deaths) / NULLIF(SUM(new_cases), 0)),4)*100  AS death_per_case
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Viewing Total Population vs Vaccinations

--Use CTE

WITH cte (continent, location, date, population, new_vaccinations, shots_per_pop) 
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition by d.location
ORDER BY d.location, d.date) AS shots_per_pop
FROM PortfolioProject.dbo.CovidDeaths d
JOIN PortfolioProject.dbo.CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
)

SELECT *,(shots_per_pop/population)*100
FROM cte


-- Temp Table

DROP TABLE IF exists #PercentPopulationToShotsRatio
CREATE TABLE #PercentPopulationToShotsRatio
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
shots_per_pop numeric
)

INSERT INTO #PercentPopulationToShotsRatio
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition by d.location
ORDER BY d.location, d.date) AS shots_per_pop
FROM PortfolioProject.dbo.CovidDeaths d
JOIN PortfolioProject.dbo.CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
--WHERE d.continent IS NOT NULL

SELECT *,(shots_per_pop/population)*100
FROM #PercentPopulationToShotsRatio

--Creating view to store data for later visualiztions

Create View PercentPopulationToShotsRatio AS 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (Partition by d.location
ORDER BY d.location, d.date) AS shots_per_pop
FROM PortfolioProject.dbo.CovidDeaths d
JOIN PortfolioProject.dbo.CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL