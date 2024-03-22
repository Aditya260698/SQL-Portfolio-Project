SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[population]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
      ,[new_deaths_smoothed]
      ,[total_cases_per_million]
      ,[new_cases_per_million]
      ,[new_cases_smoothed_per_million]
      ,[total_deaths_per_million]
      ,[new_deaths_per_million]
      ,[new_deaths_smoothed_per_million]
      ,[reproduction_rate]
      ,[icu_patients]
      ,[icu_patients_per_million]
      ,[hosp_patients]
      ,[hosp_patients_per_million]
      ,[weekly_icu_admissions]
      ,[weekly_icu_admissions_per_million]
      ,[weekly_hosp_admissions]
      ,[weekly_hosp_admissions_per_million]
  FROM [PortfolioProject].[dbo].[CovidDeaths]



SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
order by 1,2


-- Looking at Total Cases vs Total Death

SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
order by 1,2

UPDATE PortfolioProject.dbo.CovidDeaths
SET total_deaths = NULL
WHERE total_deaths = 0;

UPDATE PortfolioProject.dbo.CovidDeaths
SET total_cases = NULL
WHERE total_cases = 0;

UPDATE PortfolioProject.dbo.CovidDeaths
SET new_cases = NULL
WHERE new_cases = 0;

UPDATE PortfolioProject.dbo.CovidVaccinations
SET new_vaccinations = NULL
WHERE new_vaccinations = 0;

UPDATE PortfolioProject.dbo.CovidDeaths
SET continent = NULL
WHERE continent = ' ';

-- Looking Total Cases vs Population
-- What % of population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at countries highest infection rates compared to population

SELECT Location, MAX(total_cases) as HignestInfected, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Group By Location, Population
order by HignestInfected DESC


-- LET'S BREAK THIS DOWN BY CONTINENT
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group By continent
order by TotalDeathCount DESC

-- Showing the countries with the highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group By Location
order by TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
(SUM(cast(new_deaths as int))/SUM(New_cases))*100 as DeathPercentage --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage

From PortfolioProject.dbo.CovidDeaths
-- Where location like '%states%'
Where continent is not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS float)) OVER (Partition by death.Location ORDER BY death.location, death.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
Order by 2,3


-- USE CTE

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS float)) OVER (Partition by death.Location ORDER BY death.location, death.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 From PopVsVac



-- Temp Table
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS float)) OVER (Partition by death.Location ORDER BY death.location, death.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS float)) OVER (Partition by death.Location ORDER BY death.location, death.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	ON death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
--Order by 2,3