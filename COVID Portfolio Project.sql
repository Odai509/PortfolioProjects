SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


--Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%ye%'
AND continent IS NOT NULL
ORDER BY 1, 2


--Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%ye%'
ORDER BY 1, 2


--Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) As HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Countries with Highest Death Count compared to Population
SELECT location, MAX(CAST(total_deaths as int)) As TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Continents with Highest Death Count compared to Population
SELECT continent, MAX(CAST(total_deaths as int)) As TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL Total New Cases vs Total New Deaths By Date
SELECT date, SUM(new_cases) as Total_New_Cases, SUM(CAST(new_deaths as int)) as Total_New_Deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


--GLOBAL Total New Cases vs Total New Deaths
SELECT SUM(new_cases) as Total_New_Cases, SUM(CAST(new_deaths as int)) as Total_New_Deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2
----------------------------------------------------------------------------------------

--Total Population Vs Vaccinations

-- USING  CTE 
WITH PopvsVac (continent, location, date, population, new_vaccinations, CumulativePeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition By dea.location Order By  dea.location, dea.date ROWS UNBOUNDED PRECEDING) as CumulativePeopleVaccinated

FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (CumulativePeopleVaccinated/population)*100 As CumulativePrecentPopulationVaccinated
FROM PopvsVac

--------------------------------------------

--USING TEMP Table
DROP Table if exists #PrecentPopulationVaccinated
CREATE Table #PrecentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CumulativePeopleVaccinated numeric
)

INSERT INTO #PrecentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition By dea.location Order By  dea.location, dea.date ROWS UNBOUNDED PRECEDING) as CumulativePeopleVaccinated

FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (CumulativePeopleVaccinated/population)*100 AS CumulativePrecentPopulationVaccinated
FROM #PrecentPopulationVaccinated																				

--------------------------------------------

--Creating View
CREATE View PrecentPopulationVaccinated	AS
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition By dea.location Order By  dea.location, dea.date ROWS UNBOUNDED PRECEDING) as CumulativePeopleVaccinated

FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (CumulativePeopleVaccinated/population)*100 AS CumulativePrecentPopulationVaccinated
FROM PrecentPopulationVaccinated	