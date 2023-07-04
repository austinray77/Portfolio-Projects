SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * 
--FROM CovidVaccinations
--ORDER BY 3,4

--Select Data that I will be using

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths

SELECT Location, Date, total_cases, total_deaths,(total_deaths/total_cases) * 100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE Location Like '%states%' 
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

SELECT Location, Date, Population, total_cases, (total_cases/population) * 100 AS PercentPopulation
FROM [Portfolio Project]..CovidDeaths
WHERE Location = 'United States'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--Showing the countries with the highest death count per Population

SELECT Location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT



--Showing continents with highest death counts per population

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

--Global numbers

SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))
/SUM(New_cases) * 100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
--GROUP BY Date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as bigint) as NewVaccinations
, SUM(Cast(new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.Location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM CovidDeaths Dea
Join CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

--USE CTE

WITH PopvsVac (Continent,Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as bigint) as NewVaccinations
, SUM(Cast(new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.Location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM CovidDeaths Dea
Join CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
)

Select *, (RollingPeopleVaccinated/Population) * 100
from PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
Newvaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as bigint) as NewVaccinations
, SUM(Cast(new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.Location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM CovidDeaths Dea
Join CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
--WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated

--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as bigint) as NewVaccinations
, SUM(Cast(new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.Location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
FROM CovidDeaths Dea
Join CovidVaccinations Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE dea.continent is not null

SELECT * FROM PercentPopulationVaccinated