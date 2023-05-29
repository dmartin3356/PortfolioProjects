SELECT
	*
FROM
	PortfolioProject..CovidVaccinations
Order By 3,4

--SELECT
--	*
--FROM
--	PortfolioProject..CovidDeaths
--Order By 3,4

-- Select data that we are going to be using 

SELECT
	Location, date, total_cases, new_cases, total_deaths, population_density
FROM
	PortfolioProject..CovidDeaths
Order By 1,2

-- Changing data types
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases float

ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths float


-- Looking at total cases versus total deaths
-- Shows the likelyhood of dying if you contract Covid in your country
SELECT
	Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	Location like '%states%'
and continent is not null
Order By 1,2

-- Looking at the total cases versus the population
-- Shows what percentage of population got covid
SELECT
	Location, date, total_cases, population_density, (total_cases/population_density)*100 as percent_population_infected
FROM
	PortfolioProject..CovidDeaths
WHERE
	Location like '%states%'
Order By 1,2


--Looking at countries with highest infection rate compared to population_density
SELECT
	Location, population_density, MAX(total_cases) AS HighestInfectionCount, MAX((total_deaths/total_cases))*100 AS PercentPopulationInfected
FROM
	PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
Group by Location, population_density
Order By PercentPopulationInfected desc

-- Showing countries with the highest death count per population_density

SELECT
	Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM
	PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
Group by Location
Order By TotalDeathCount desc

-- Breaking things down by continent
-- Showing the continents with highest death count
SELECT
	continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM
	PortfolioProject..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
Group by continent
Order By TotalDeathCount desc


-- Global numbers
SELECT	date,
		sum(new_cases) as new_cases,
		Sum(new_deaths) as new_deaths,
		SUM(new_deaths)/sum(nullif(new_cases,0))*100 as death_percentatge
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1

-- Joining tables, total population versus vaccinations
SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date= vac.date

SELECT dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date= vac.date
WHERE dea.continent is not null
Order by 2,3

-- Use CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date= vac.date
WHERE dea.continent is not null
--Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

-- Temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date= vac.date
WHERE dea.continent is not null
--Order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date= vac.date
WHERE dea.continent is not null
--Order by 2,3

SELECT *
FROM PercentPopulationVaccinated