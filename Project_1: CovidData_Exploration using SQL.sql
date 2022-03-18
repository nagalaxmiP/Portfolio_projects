select *
from portfolio_project..CovidDeaths
order by 3,4

--data we are going to be using
select location,date,total_cases,new_cases,total_deaths,population
from portfolio_project..CovidDeaths
order by 1,2


--total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from portfolio_project..CovidDeaths
order by 1,2


--United Sates total cases vs total deaths
--likelihood of dying if you contracted covid 19 in the United States
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from portfolio_project..CovidDeaths
--where location like '%States%'
where location='United States'
order by 1,2


--India total cases vs total deaths
--likelihood of dying if you contracted covid 19 in India
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from portfolio_project..CovidDeaths
where location='India'
order by 1,2


--total cases vs population
--shows what percentage of people got covid 19 in United States
select location,date,total_cases,population,(total_cases/population)*100 as cases_percentage
from portfolio_project..CovidDeaths
where location like '%States%'
order by 1,2


--shows what percentage of people got covid 19 in india
select location,date,total_cases,population,(total_cases/population)*100 as cases_percentage
from portfolio_project..CovidDeaths
where location like '%india%'
order by 1,2


--what country has highest infection rate compared to population
select location,population,max(total_cases) as highestInfectionCount ,max((total_cases/population))*100 as cases_percentage
from portfolio_project..CovidDeaths
where continent is not null
group by location,population
order by 4 desc


--countries with highest death count per population
select location,population,max(cast(total_deaths as int)) as DeathCount ,max((total_deaths/population))*100 as death_percentage
from portfolio_project..CovidDeaths
where continent is not null
group by location,population
order by DeathCount desc


--continents with highest death count
select continent,max(cast(total_deaths as int)) as TotalDeathCount 
from portfolio_project..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--global numbers(total cases ,total deaths, death percentage) per single day
select date,sum(new_cases) as TotalCases,sum(cast(new_deaths as int))  as TotalDeaths,(sum(cast(new_deaths as int))/sum(new_cases)) * 100 as death_percentage
from portfolio_project..CovidDeaths
where continent is not null and new_cases is not null and  new_deaths is not null
group by date
order by 1


--global numbers(total cases ,total deaths, death percentage)
select sum(new_cases) as TotalCases,sum(cast(new_deaths as int))  as TotalDeaths,(sum(cast(new_deaths as int))/sum(new_cases)) * 100 as death_percentage
from portfolio_project..CovidDeaths
where continent is not null 
--group by date
order by 1

--total population vs vaccinations
--checking if the tables joined correctly
select *
from portfolio_project..CovidDeaths as dea
join portfolio_project..CovidVaccinations as vac
     on dea.location=vac.location and
        dea.date=vac.date

--selecting required data from the joined table
select dea.continent,dea.location,dea.date,dea.population,vac.total_vaccinations
from portfolio_project..CovidDeaths as dea
join portfolio_project..CovidVaccinations as vac
     on dea.location=vac.location and
        dea.date=vac.date
where dea.continent is not null and dea.location='united states'
order by 2,3


-----------------------------------------------------------------------------------------------------------------------
--new vaccinations rolling count 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))over(partition by dea.location order by dea.location,dea.date) as TotalPeopleVaccinatedRollingCount
from portfolio_project..CovidDeaths as dea
join portfolio_project..CovidVaccinations as vac
     on dea.location=vac.location and
        dea.date=vac.date
where dea.continent is not null
order by 2,3


---------------------------------------------------------------------------------------------------------------------
--total population vs vaccinations(new-vaccinations rolling count)
--using CTE
with PopvsVac(continent,location,date,population,new_vaccinations,TotalPeopleVaccinatedRollingCount)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as TotalPeopleVaccinatedRollingCount
--,(TotalPeopleVaccinatedRollingCount/dea.population)*100 as vaccinatedPercentage
from portfolio_project..CovidDeaths as dea
join portfolio_project..CovidVaccinations as vac
     on dea.location=vac.location and
        dea.date=vac.date
where dea.continent is not null
--order by 2
)
select *
from PopvsVac
---------------------------------------------------------------------------------------------------------------------
--using CTE
with PopvsVac (continent,location,date,population,new_vaccinations,TotalPeopleVaccinatedRollingCount)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as TotalPeopleVaccinatedRollingCount
--,(PeopleVaccinatedCount/dea.population)*100 as vaccinatedPercentage
from portfolio_project..CovidDeaths as dea
join portfolio_project..CovidVaccinations as vac
     on dea.location=vac.location and
        dea.date=vac.date
where dea.continent is not null
--order by 2
)
select *,
(TotalPeopleVaccinatedRollingCount/population)*100 as vaccinatedPercentage
from PopvsVac


--------------------------------------------------------------------------------------------------------------------------
--country with highest percentage of people fully vaccinated
select dea.location,dea.population,max(vac.people_fully_vaccinated) as PeopleFullyVaccinated,
max((vac.people_fully_vaccinated/dea.population)*100) as PeopleFullyVaccinatedPercentage
from portfolio_project..CovidDeaths as dea
join portfolio_project..CovidVaccinations as vac
     on dea.location=vac.location and
        dea.date=vac.date
where dea.continent is not null 
group by dea.location,dea.population
order by PeopleFullyVaccinatedPercentage desc


 --------------------------------------------------------------------------------------------------------------------
 --TEMP TABLE
 drop table if exists #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 TotalPeopleVaccinatedRollingCount numeric
 )

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as TotalPeopleVaccinatedRollingCount
--,(PeopleVaccinatedCount/dea.population)*100 as vaccinatedPercentage
from portfolio_project..CovidDeaths as dea
join portfolio_project..CovidVaccinations as vac
     on dea.location=vac.location and
        dea.date=vac.date
where dea.continent is not null
--order by 2
select *,
(TotalPeopleVaccinatedRollingCount/population)*100 as vaccinatedPercentage
from #PercentPopulationVaccinated
order by 2,3


--------------------------------------------------------------------------------------------------------------------
--creating view for later visualizations
--drop view if exists PercentPopulationVaccinated
create view PercentagePopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as TotalPeopleVaccinatedRollingCount
--,(PeopleVaccinatedCount/dea.population)*100 as vaccinatedPercentage
from portfolio_project..CovidDeaths as dea
join portfolio_project..CovidVaccinations as vac
     on dea.location=vac.location and
        dea.date=vac.date
where dea.continent is not null
--quering the view

select *
from PercentagePopulationVaccinated
