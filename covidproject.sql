use CovidProject;

select * from CovidDeaths 
WHERE CONTINENT is null
order by 3,4;

select * from CovidVaccinations order by 3,4;

select location , date , total_cases , new_cases , total_deaths , population
from CovidDeaths order by 1,2;

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from CovidDeaths where location like ('%India%') 
order by 1,2;



select location,avg(population) as population,max(total_cases) as total_cases,max((total_cases/population))*100 as percentage_infected,
max(cast(total_deaths as int) ) as highest_death_count
from CovidDeaths group by location
order by 4 desc;

select location,population,max(total_cases) as highest_infection_count , max((total_cases/population))*100 as max_percentage_infected
from CovidDeaths
--WHERE POPULATION >10000000
group by location,population 
order by 4 DESC;

--Highest Death count per country
select location,population,max(cast(total_deaths as int) ) as highest_death_count , max((total_deaths/population))*100 as max_percentage_death
from CovidDeaths
where continent is not null
group by location,population 
order by 3 DESC;

--Hisghest Death Count per continent
select location,population,max(cast(total_deaths as int) ) as highest_death_count , max((total_deaths/population))*100 as max_percentage_death
from CovidDeaths
where continent is null
group by location,population 
order by 2 DESC;

--Global Numbers evereday from March-2020
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from CovidDeaths where continent is not null
group by date
order by 1;

--Global number till 31-August-2021
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from CovidDeaths where continent is not null
--group by date
order by 1;


select * from CovidVaccinations
where continent is not null and location like '%India%';

--Vaccinations per day and total vaccination per country till now

select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations))  over (partition by cd.location
order by cd.location,cd.date) as rolling_vaccinations
from CovidDeaths cd
join CovidVaccinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null and cd.location like '%India%'
order by 2,3;

 --Using CTE to find percentage of total population vaccinated

 with PopvsVac(continent,location,date,population,new_vaccinations,rolling_vaccinations)
 as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations))  over (partition by cd.location
order by cd.location,cd.date) as rolling_vaccinations
from CovidDeaths cd
join CovidVaccinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null --and cd.location like '%India%'
--order by 1,2
)select location, population ,max(rolling_vaccinations) as maximum_vaccination,max((rolling_vaccinations/population))*100 as percentage_vaccinated 
from PopvsVac
--where location like '%India%'
group by location,population
order by 4 desc;


--Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations varchar(255),
rolling_vaccinations numeric)

insert into #PercentPopulationVaccinated
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations))  over (partition by cd.location
order by cd.location,cd.date) as rolling_vaccinations
from CovidDeaths cd
join CovidVaccinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null --and cd.location like '%India%'
--order by 1,2

select * ,(rolling_vaccinations/population)*100 as vactinations_per_population
from #percentPopulationVaccinated;

--Creating views(For Tableau)

Create View Vacc_per_Population as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations))  over (partition by cd.location
order by cd.location,cd.date) as rolling_vaccinations
from CovidDeaths cd
join CovidVaccinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null --and cd.location like '%India%'
--order by 1,2

create View Death_percentage as
select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from CovidDeaths where continent is not null
--group by date
select * from Death_percentage;

create view death_percentage_everyday as 
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from CovidDeaths where continent is not null
group by date

create view death_count_per_contry as
select location,population,max(cast(total_deaths as int) ) as highest_death_count , max((total_deaths/population))*100 as max_percentage_death
from CovidDeaths
where continent is not null
group by location,population 

create view death_count_per_continent as
select location,population,max(cast(total_deaths as int) ) as highest_death_count , max((total_deaths/population))*100 as max_percentage_death
from CovidDeaths
where continent is null
group by location,population 
