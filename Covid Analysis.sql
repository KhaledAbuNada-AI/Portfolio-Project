SELECT *
FROM PortfolioProjects..CovidDeaths
WHERE
	continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProjects..CovidVaccinations

--ORDER BY 3,4

SELECT 
	location, date, total_cases, new_cases, total_deaths, population

FROM 
	PortfolioProjects..CovidDeaths
WHERE
	continent is not null
ORDER BY 1,2
 

-- Looking at Total Cases vs Total Deaths

SELECT 
	location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM
	PortfolioProjects..CovidDeaths
WHERE
	location like '%Palestine%' and continent is not null
	
ORDER BY 1,2

-- Looking at Total Cases vs Population

SELECT
	location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM
	PortfolioProjects..CovidDeaths

WHERE 
	location Like '%Palestine%' and continent is not null

ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Populatin

SELECT 
	location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM
	PortfolioProjects..CovidDeaths
WHERE
	continent is not null
GROUP BY
	location, population
ORDER BY
	PercentPopulationInfected DESC

-- Showing Countries wuth Highest Death Count per Population

SELECT
	location, MAX(CAST(total_deaths AS int)) AS HighestDeathsCount
FROM
	PortfolioProjects..CovidDeaths

WHERE
	continent is not null
GROUP BY
	location
ORDER BY
	HighestDeathsCount DESC

	-- , MAX((total_deaths/population))*100 AS PercentPopulationInfected



-- Showing continents with the highest death count population
SELECT
	continent, MAX(cast(total_deaths as int)) As TotalDeathsCount
FROM
	PortfolioProjects..CovidDeaths
WHERE
	continent is not null
GROUP BY
	continent
ORDER BY
	TotalDeathsCount DESC

-- GLOBAL NUMBERS

SELECT
	 SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM
	PortfolioProjects..CovidDeaths
WHERE
	continent is not null
--GROUP BY 
--	date
ORDER BY 
	1,2


-- Looking at Total Population vs Vaccinations

SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
	ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
	PortfolioProjects..CovidDeaths dea
	Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE
	dea.continent is not null
ORDER BY
	2,3

-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
	ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
	PortfolioProjects..CovidDeaths dea
	Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE
	dea.continent is not null
)
SELECT
	*, (RollingPeopleVaccinated/population) * 100 AS TT
FROM
	PopvsVac


-- TEMP TABLE
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date DATETIME,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
	ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
	PortfolioProjects..CovidDeaths dea
	Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE
--	dea.continent is not null

SELECT
	*, (RollingPeopleVaccinated/population) * 100 AS TT
FROM
	#PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location 
	ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
	PortfolioProjects..CovidDeaths dea
	Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE
	dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated