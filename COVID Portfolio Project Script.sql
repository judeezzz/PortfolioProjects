--The main two tables-----------------------------------

SELECT * 
FROM PortfolioProject..CovidDeaths

SELECT * 
FROM PortfolioProject..CovidVaccinations

--------------------------------------------------------

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths-------------------------------------------
-- Shows likelyhood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population --------------------------------------------
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as ContractionsPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at countries with highest infection rates compared to population --------
SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Showing countries with highest death count per population ------------------------
SELECT location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--AND location like '%states%'
GROUP BY location, population
ORDER BY TotalDeathCount desc


-- BY CONTINENT ----------------------------------------------------------------------
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--AND location like '%states%'
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Showing the continet with the highest death count per population -------------------
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--AND location like '%states%'
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers ---------------------------------------------------------------------
SELECT sum(new_cases), sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
-- AND location like '%states%'
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccination --------------------------------------------
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location	
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE-----------------------------------------------------------------------------------
WITH PopsvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location	
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
FROM PopsvsVac


--TEMP TABLE------------------------------------------------------------------------------
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations bigint,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as bigint) AS new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization --------------------------------
CREATE VIEW PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as bigint) AS new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

SELECT * FROM PercentagePopulationVaccinated
