select *
from PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihod of dying if you caontract covid in your country

select location, date, total_cases, total_deaths,  (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentag of population got Covid

select location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

select location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%Thailand%'
Group by location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%Thailand%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Contintents with the highest death count per population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%Thailand%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
--where location like '%states%'
Where continent is not null
--Group by date
order by 1,2

Total Population vs Vaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea. Location order by dea.location,dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date 
Where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (Continenet, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea. Location order by dea.location,dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date 
Where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea. Location order by dea.location,dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date 
--Where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea. Location order by dea.location,dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date 
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated