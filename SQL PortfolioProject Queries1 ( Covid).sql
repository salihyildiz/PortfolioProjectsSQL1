select *
From PortfolioProject..CovidDeaths$
order by 3,4

--select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2


-- Loooking at Total cases vs Total Deaths 
-- shows likelihood of if you contract covid in your country
select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%state%'
order by 1,2


-- Looking at Total cases vs Population
--Shows what percentage of population got covid

select location, date, population, total_cases,  (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%state%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--where location like '%state%'
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%state%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%state%'
where continent  is not null
Group by continent
order by TotalDeathCount desc


--Showing continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%state%'
where continent  is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select  SUM(total_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
--Group By date
order by 1,2


-- USE CTE

With PopvsVac(Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
--, (RollingPeopleVacinated/population)*100
From PortfolioProject..CovidDeaths$ dea 
Join PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/population)*100
From PopvsVac


--TEMP TABLE 

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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
--, (RollingPeopleVacinated/population)*100
From PortfolioProject..CovidDeaths$ dea 
Join PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3


Select*, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations 

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
--, (RollingPeopleVacinated/population)*100
From PortfolioProject..CovidDeaths$ dea 
Join PortfolioProject..CovidVaccinations$ vac
     On dea.location = vac.location
	 and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated



