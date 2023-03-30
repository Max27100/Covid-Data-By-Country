Select *
From Portfolio..CovidDeaths$
--Where continent is not NULL
order by 3,4

--Select *
--From Portfolio..CovidVaccinations$
--order by 3,4

--minimizing
Select Location, date, total_cases,new_cases, total_deaths, population
From Portfolio..CovidDeaths$
order by 1,2

--total deaths vs total cases
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage
From Portfolio..CovidDeaths$
order by 1,2

--total cases vs pop
Select Location, date, total_cases, population,(total_cases/population)* 100 as PercentageInfected
From Portfolio..CovidDeaths$
Where location like '%states%'
order by 1,2

--infection rates
Select continent, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)* 100) as PercentageInfected
From Portfolio..CovidDeaths$
group by continent, population
order by PercentageInfected desc

--Death by country
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths$
Where continent is not NULL
group by continent
order by TotalDeathCount desc


--continent with highest death count per population
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths$
Where continent is not NULL
group by continent
order by TotalDeathCount desc

--global #s
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths$
Where continent is not NULL
group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths$
Where continent is not NULL
order by 1,2

--total pop vs vac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinated
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
order by 2,3

--CTE

With PopvsVac (continent, Location, Date, Population, new_vaccinations, RollingVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinated
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL)
Select *, (RollingVaccinated/Population)*100
From PopvsVac

--Temp Table

DROP Table if exists #PercentPopVaccinated
Create Table #PercentPopVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric)


INSERT into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingVaccinated
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not NULL

Select *, (RollingVaccinated/Population)*100
From #PercentPopVaccinated

--Creating View
CREATE View PercentPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingVaccinated
From Portfolio..CovidDeaths$ dea
Join Portfolio..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL

Select *
From PercentPopVaccinated

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths$
Where continent is NULL and location not in('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc

Select location, population, MAX(total_cases) as HighestInfectCount, MAX((total_cases/population))*100 as PercentPopInfected
From Portfolio..CovidDeaths$
group by location, population
order by PercentPopInfected desc

Select location, population, date, MAX(total_cases) as HighestInfectCount, MAX((total_cases/population))*100 as PercentPopInfected
From Portfolio..CovidDeaths$
group by location, population, date
order by PercentPopInfected desc