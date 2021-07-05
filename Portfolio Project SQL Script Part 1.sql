-- Select the Data we will be working with : 
 
 /* First Table covid_deaths ( ) */ 
select CONTINENT, LOCATION, POPULATION, DATE_SYS as Day, NEW_CASES, TOTAL_CASES, NEW_DEATHS, TOTAL_DEATHS
from covid_deaths 
order by 2,4 ;

 /* Second Table covid_vaccination ( ) */ 
select CONTINENT, LOCATION, DATE_SYS, NEW_TESTS, TOTAL_TESTS, TOTAL_VACCINATIONS, PEOPLE_FULLY_VACCINATED, NEW_VACCINATIONS
from covid_vaccination
;

--------------- Working with locations  ---------------
-- Looking at the death Percentage if someone contract the virus / day

select CONTINENT, LOCATION, DATE_SYS as DAY, TOTAL_CASES, TOTAL_DEATHS, round((TOTAL_DEATHS/ TOTAL_CASES)*100,3) as Death_Percentage
from covid_deaths
where upper(location) like '%TUNISIA%'
order by location, day ;


-- Looking at the infection Percentage 

select CONTINENT, LOCATION, DATE_SYS as DAY, TOTAL_CASES, POPULATION, round((TOTAL_CASES/ POPULATION)*100,3) as Infect_Percentage
from covid_deaths
where upper(location) like '%TUNISIA%'
order by location, day ;


-- Looking at the coutries with the highest infection Percentage 

select CONTINENT, LOCATION,   max(POPULATION) as max_population, NVL(max(round((TOTAL_CASES/ POPULATION)*100,3)),0) as max_Infect_Percentage -- replace with 0 if null
from covid_deaths
--where upper(location) like '%TUNISIA%'
where continent is not null 
group by CONTINENT, LOCATION
order by max_Infect_Percentage desc nulls last ;


--  Looking at the highest death count per country

select CONTINENT, LOCATION, POPULATION,  max(new_deaths) as max_new_death, max(TOTAL_DEATHS) as max_total_deaths
from covid_deaths
where continent is not null
group by CONTINENT, LOCATION, POPULATION
order by max_total_deaths desc nulls last;


--------------- Working with continents  ---------------
-- Continents with the highest death count

select CONTINENT, sum(new_cases) as total_cases,  sum(new_DEATHS) as total_deaths
from covid_deaths
where continent is not null
group by CONTINENT
order by total_deaths desc ;


-- Infection Percentage per continent
-- Using an inline view inside a "with"
with pop_by_country as (select CONTINENT, sum(POPULATION)  as sum_pop_continent
                        from (select CONTINENT, LOCATION, max(POPULATION) as POPULATION from covid_deaths
                               where continent is not null 
                               group by CONTINENT, LOCATION) 
                        group by CONTINENT) -- get the maximum population by continent
                        
select pop_by_country.CONTINENT , sum(covid_deaths.new_cases) as total_cases, sum_pop_continent as population,  round(( sum(covid_deaths.new_cases) / sum_pop_continent )*100,3)  as infection_percentage
from covid_deaths, pop_by_country
where covid_deaths.CONTINENT = pop_by_country.CONTINENT -- now we dont have to sum (population)
group by pop_by_country.CONTINENT, sum_pop_continent
order by infection_percentage desc ;


-- Death Percentage per continent
select CONTINENT ,sum(new_deaths) as total_deaths,  round(( sum(new_deaths) / sum(new_cases) )*100,3)  as death_percentage
from covid_deaths
where continent is not null
group by CONTINENT
order by death_percentage desc ;


--------------- World  ---------------
-- Total cases / deaths / deaths % per day in the world
select date_sys, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, round(( sum(new_deaths) / sum(new_cases) )*100,3) as death_percentage
from covid_deaths
where continent is not null
group by date_sys
order by 1 asc nulls last;

-- total_cases & total_deaths in the world
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, round(( sum(new_deaths) / sum(new_cases) )*100,3) as death_percentage
from covid_deaths
where continent is not null;


------------ Join with the vaccination table ------------
-- coutries with the sum of new_vaccinations by day 
select d.continent, d.location, d.date_sys, d.population , v.new_vaccinations, sum(new_vaccinations) OVER (PARTITION BY d.location order BY d.location, d.date_sys) as sum_vacc_by_day
from covid_deaths d, covid_vaccination v
where d.ISO_CODE = v.ISO_CODE
and d.DATE_SYS = v.DATE_SYS
and d.continent is not NULL
and v.new_vaccinations is not null
order by 2, 3 
;


-- the same as the query before but with with ( CTE : Common table Expression )
-- Determine the percent of vaccinated people
with sum_vaccs (continent, location, date_sys, population, newly_vaccinated , sum_vacc_by_day) 
as 
(select d.continent, d.location, d.date_sys, d.population , v.new_vaccinations, sum(new_vaccinations) OVER (PARTITION BY d.location order BY d.location, d.date_sys) as sum_vacc_by_day
    from covid_deaths d, covid_vaccination v
    where d.ISO_CODE = v.ISO_CODE
    and d.DATE_SYS = v.DATE_SYS
    and d.continent is not NULL
    and v.new_vaccinations is not null
)
                    
select sum_vaccs.*, round(( sum_vaccs.sum_vacc_by_day / sum_vaccs.population)*100,4) as Percent_poeple_vaccinated
from sum_vaccs;


    
---------- CREATING VIEWS based on the above queries -------

-- Creating a working views to be ued later in tableau ( visualization )
create view WV_PERCT_pple_vaccs_country AS 
with sum_vaccs as 
(select d.continent, d.location, d.date_sys, d.population , v.new_vaccinations, sum(new_vaccinations) OVER (PARTITION BY d.location order BY d.location, d.date_sys) as sum_vacc_by_day
    from covid_deaths d, covid_vaccination v
    where d.ISO_CODE = v.ISO_CODE
    and d.DATE_SYS = v.DATE_SYS
    and d.continent is not NULL
    and v.new_vaccinations is not null
)
                    
select sum_vaccs.*, round(( sum_vaccs.sum_vacc_by_day / sum_vaccs.population)*100,4) as Percent_poeple_vaccinated
from sum_vaccs ;
    

--------/////////////////////////////////////////!!!!!!!!!!!!!!!!!!

-- Creating a working views to be ued later in tableau ( visualization ) : Infection Percentage per continent
create or replace view WV_perct_infect_continent as 
with pop_by_country as (select CONTINENT, sum(POPULATION)  as sum_pop_continent
                        from (select CONTINENT, LOCATION, max(POPULATION) as POPULATION from covid_deaths
                               where continent is not null 
                               group by CONTINENT, LOCATION) 
                        group by CONTINENT) -- get the maximum population by continent
                        
select pop_by_country.CONTINENT , sum(covid_deaths.new_cases) as total_cases, sum_pop_continent as population,  round(( sum(covid_deaths.new_cases) / sum_pop_continent )*100,3)  as infection_percentage
from covid_deaths, pop_by_country
where covid_deaths.CONTINENT = pop_by_country.CONTINENT -- now we dont have to sum (population)
group by pop_by_country.CONTINENT, sum_pop_continent
order by infection_percentage desc;

--------/////////////////////////////////////////!!!!!!!!!!!!!!!!!!

-- Creating a working views to be ued later in tableau ( visualization ) : Death Percentage per continent
create or replace view WV_perct_death_continent as 
select CONTINENT ,sum(new_deaths) as total_deaths,  round(( sum(new_deaths) / sum(new_cases) )*100,3)  as death_percentage
from covid_deaths
where continent is not null
group by CONTINENT
order by death_percentage desc ;


--------/////////////////////////////////////////!!!!!!!!!!!!!!!!!!

-- Creating a working views to be ued later in tableau ( visualization ) : Dthe coutries with the highest infection Percentage 
create or replace view WV_high_perct_infect_country as 
select CONTINENT, LOCATION,   max(POPULATION) as max_population, max(round((TOTAL_CASES/ POPULATION)*100,3)) as max_Infect_Percentage
from covid_deaths
--where upper(location) like '%TUNISIA%'
where continent is not null 
group by CONTINENT, LOCATION
order by max_Infect_Percentage desc nulls last ;


--------/////////////////////////////////////////!!!!!!!!!!!!!!!!!!

-- Creating a working views to be ued later in tableau ( visualization ) : infection Percentage 
create or replace view WV_perct_infect_country as 
select CONTINENT, LOCATION, DATE_SYS as DAY, TOTAL_CASES, POPULATION, round((TOTAL_CASES/ POPULATION)*100,3) as Infect_Percentage
from covid_deaths
where CONTINENT is not null
order by location, day ;


--------/////////////////////////////////////////!!!!!!!!!!!!!!!!!!

-- Creating a working views to be ued later in tableau ( visualization ) : death Percentage  / country / day
create or replace view WV_perct_death_country as 
select CONTINENT, LOCATION, DATE_SYS as DAY, TOTAL_CASES, TOTAL_DEATHS, round((TOTAL_DEATHS/ TOTAL_CASES)*100,3) as Death_Percentage
from covid_deaths
where CONTINENT is not null
order by location, day ;