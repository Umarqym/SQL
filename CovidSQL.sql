-- The data used in this project is from Covid-19 global data derived 
-- from ‘Our World in Data’ website (https://ourworldindata.org/covid-deaths).
-- The data was first imported into MySQL and then analysed. The following queries
-- give a general overview about the current and overall state of the Covid-19 virus 
-- in the UK and Globally. The aim of this project is to give an overview of my abilities in SQL.


-- General overview of Covid statistics.
select location, date, total_cases, total_deaths, population from coviddeaths;

-- Overview of total cases vs total deaths, and death percentage for each location.
select location, sum(new_cases), sum(new_deaths), (sum(new_deaths)/sum(new_cases))*100 as death_likelihood, population from coviddeaths
group by location;

-- Overview of total cases vs total deaths, and death percentage for UK.
select location, sum(new_cases), sum(new_deaths), (sum(new_deaths)/sum(new_cases))*100 as death_likelihood, population FROM coviddeaths
where location like '%United Kingdom%'
group by location;

-- Timeline of covid total cases, total death and death ratio for the UK
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage from coviddeaths
where location like '%United Kingdom%';

-- Timeline of covid infection rate in the UK
select location, date, total_cases, population, (total_cases/population) * 100 as infection_percentage from coviddeaths
where location like '%United Kingdom%';

-- Timeline of death rate in the UK
select location, date, total_deaths, population, (total_deaths/population) * 100 as death_to_population_percentage from coviddeaths
where location like '%United Kingdom%';

-- Top 10 locations with the highest infection rate recorded.
select location, max((total_cases/population)) * 100 as infection_percentage from coviddeaths
group by location
order by infection_percentage desc
limit 10;

-- Top 10 locations with the highest death rate recorded.
select location, max((total_deaths/population)) * 100 as death_percentage from coviddeaths
group by location
order by death_percentage desc
limit 10;

-- Top 10 locations with the highest number of deaths.
select location, max(total_deaths) as deaths from coviddeaths
where continent is not null and location not in 
('europe', 'world','Upper middle income','High income','North America','Asia','Lower middle income','European Union','South America')
group by location
order by  max(total_deaths) desc
limit 10;

-- Continents with the highest number of deaths.
select continent, max(total_deaths) as deaths from coviddeaths
where continent is not null and continent <> ''
group by continent
order by  max(total_deaths) desc;

-- Global timeline of infections and deaths.
select date, sum(new_cases) as Global_Infections,sum(new_deaths) as Global_Deaths, (sum(new_deaths)/sum(new_cases)) as Death_Ratio from coviddeaths
group by date
order by 1,2;

-- New vaccinations/ total vaccination timeline for all locations.
select d.continent, d.location,d.date, d.population, v.new_vaccinations, sum(new_vaccinations) over (partition by d.location order by d.date) as total_vaccinated, (sum(new_vaccinations) over (partition by d.location order by d.date)/d.population) as '% of population vaccinated'  from coviddeaths d
join covidvac v
on d.location = v.location
and d.date = v.date
where d.continent is not null and d.location not in 
('europe', 'world','Upper middle income','High income','North America','Asia','Lower middle income','European Union','South America');

-- Current total vaccinations per location.
select d.location, d.population, max(people_fully_vaccinated) as fully_Vaccinated, ( max(people_fully_vaccinated)/population)*100 as '% of population' from coviddeaths d
join covidvac v
on d.location = v.location
and d.date = v.date
where d.location not in 
('europe', 'world','Upper middle income','High income','North America', 'oceania','low income', 'africa','Asia','Lower middle income','European Union','South America')
group by location;