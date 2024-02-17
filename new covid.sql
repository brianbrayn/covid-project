
Select *
From newcovid..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From newcovid..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From newcovid..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From newcovid..CovidDeaths
--Where location like '%kenya%'
Where continent is not null
order by 1,2

--shows what percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From newcovid..CovidDeaths
--Where location like '%kenya%'
Where continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From newcovid..CovidDeaths
--Where location like '%kenya%'
Where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From newcovid..CovidDeaths
--Where location like '%kenya%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--BREAK DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From newcovid..CovidDeaths
--Where location like '%kenya%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From newcovid..CovidDeaths
--Where location like '%kenya%'
Where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
     SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	 --,(RollingPeopleVaccinated/Population)*100
From newcovid..CovidDeaths dea
join newcovid..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--USE CTE

With popvsvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
     SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	 --,(RollingPeopleVaccinated/Population)*100
From newcovid..CovidDeaths dea
join newcovid..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *,  (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
     SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
	 --,(RollingPeopleVaccinated/Population)*100
From newcovid..CovidDeaths dea
join newcovid..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3
Select *,  (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating View for later Visualization

 Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/Population)*100
From newcovid..CovidDeaths dea
join newcovid..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated










