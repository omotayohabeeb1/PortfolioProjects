USE NewPortfolioProject
SELECT *
FROM NewPortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM NewPortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- select data we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM NewPortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM NewPortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%Nigeria%'

-- Looking at the Total Cases vs Population

SELECT location, date,  population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM NewPortfolioProject..CovidDeaths
WHERE LOCATION LIKE '%Nigeria%'
ORDER BY 1,2

-- Countries with highest infection rate compared to population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM NewPortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%Nigeria%'
GROUP BY Location,  Population
ORDER BY PercentPopulationInfected DESC


-- Showing countries with Highest Death count per population

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM NewPortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%Nigeria%'
WHERE location is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- showing continents with the highest death count per population


SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM NewPortfolioProject..CovidDeaths
--WHERE LOCATION LIKE '%Nigeria%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS INT)) AS TotalDeaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM NewPortfolioProject..CovidDeaths
-- WHERE LOCATION LIKE '%Nigeria%'
WHERE continent is not null
ORDER BY 1, 2


-- Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT (INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM NewPortfolioProject..CovidDeaths dea
JOIN NewPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3


-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT (INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM NewPortfolioProject..CovidDeaths dea
JOIN NewPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVacinated
CREATE TABLE #PercentPopulationVacinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_Vaccinations Numeric,
RollingPeopleVaccinated Numeric
)

INSERT INTO #PercentPopulationVacinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT (INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM NewPortfolioProject..CovidDeaths dea
JOIN NewPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVacinated


-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVacinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT (INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM NewPortfolioProject..CovidDeaths dea
JOIN NewPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3



SELECT *
FROM PercentPopulationVacinated