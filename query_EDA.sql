


-- select database

use DataAnalytics;

-- create tables 

Create Table covid_deaths (iso_code varchar(100),continent varchar(100),location varchar(100),date Date,population float,total_cases float,new_cases float,new_cases_smoothed float,total_deaths float,new_deaths float,new_deaths_smoothed float,total_cases_per_million float,new_cases_per_million float,new_cases_smoothed_per_million float,total_deaths_per_million float,new_deaths_per_million float,new_deaths_smoothed_per_million float,reproduction_rate float,icu_patients float,icu_patients_per_million float,hosp_patients float,hosp_patients_per_million float,weekly_icu_admissions float,weekly_icu_admissions_per_million float,weekly_hosp_admissions float,weekly_hosp_admissions_per_million float);

Create Table covid_vaccs (iso_code varchar(100),continent varchar(100),location varchar(100),date Date,new_tests float,total_tests float,total_tests_per_thousand float,new_tests_per_thousand float,new_tests_smoothed float,new_tests_smoothed_per_thousand float,positive_rate float,tests_per_case float,tests_units varchar(100),total_vaccinations float,people_vaccinated float,people_fully_vaccinated float,total_boosters float,new_vaccinations float,new_vaccinations_smoothed float,total_vaccinations_per_hundred float,people_vaccinated_per_hundred float,people_fully_vaccinated_per_hundred float,total_boosters_per_hundred float,new_vaccinations_smoothed_per_million float,new_people_vaccinated_smoothed float,new_people_vaccinated_smoothed_per_hundred float,stringency_index float,population float,population_density float,median_age float,aged_65_older float,aged_70_older float,gdp_per_capita float,extreme_poverty float,cardiovasc_death_rate float,diabetes_prevalence float,female_smokers float,male_smokers float,handwashing_facilities float,hospital_beds_per_thousand float,life_expectancy float,human_development_index float,excess_mortality_cumulative_absolute float,excess_mortality_cumulative float,excess_mortality float,excess_mortality_cumulative_per_million float);

-- check tables 

select count(*) from covid_deaths;
select count(*) from covid_vaccs;
select * from covid_deaths order by 3,4;

-- select data to use 
 
select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
order by 1,2;

-- total cases vs total deaths

select location,isnull(max(total_cases),0) as cases,isnull(max(total_deaths),0) as deaths from covid_deaths
group by location
order by location;

-- likelyhood of dying if you get covid positive in your country 

select location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as per from covid_deaths
where location like '%pak%'
order by location,date;

-- what percentage of total pop got covid


select location,date,population,total_cases,(total_cases/population)*100 as per from covid_deaths
--where location like '%pak%'
order by location,date;

-- find country with highest infection rate (wrt population)


select *,isnull((a.inf/a.pop)*100,0) as rate  from 
(select location,population as pop,isnull(max(total_cases),0) as inf from covid_deaths
where continent is not null
group by location,population) a 
order by rate desc;

-- find countries with highest death rate


select *,isnull((a.dead/a.pop)*100,0) as rate  from 
(select location,population as pop,isnull(max(total_deaths),0) as dead from covid_deaths
where continent is not null
group by location,population
) a 
order by rate desc;


-- breaking down by continent 


select continent, max(population) from covid_deaths
group by continent;

select continent,location,population,
case
	when continent='NULL' then location
	else continent
	end as cont 
from covid_deaths 
order by cont


-- so total deaths per continent 

select continent, max(total_deaths) as dedded from covid_deaths
where continent!='NULL'
group by continent
order by dedded desc;



-- total population vs total vaccinations 
-- cummulative sum using window function 
-- cte's

with pop_vac(continent,location,date,population,new_vacc,cum_sum_vac) as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.date) as cumm_sum_vacc
from covid_deaths as d
	join covid_vaccs as v
	on d.location=v.location and d.date=v.date
where d.continent != 'NULL')

select *,(cum_sum_vac/population)*100 as vacc_rate from pop_vac
where location like 'pakistan'
order by 2,3;

-- temp table 

drop table if exists #pop_vac2
create table #pop_vac2 (continent nvarchar(255),location nvarchar(255), date Date, population numeric, new_vacc numeric,cum_sum_vac numeric)

insert into #pop_vac2
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.date) as cumm_sum_vacc
from covid_deaths as d
	join covid_vaccs as v
	on d.location=v.location and d.date=v.date
where d.continent != 'NULL'


select *,(cum_sum_vac/population)*100 as vacc_rate from #pop_vac2
where location like 'pakistan'
order by 2,3;


-- using views to store data for later visualizations 

create view pop_vac3 as 
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(v.new_vaccinations) over(partition by d.location order by d.date) as cumm_sum_vacc
from covid_deaths as d
	join covid_vaccs as v
	on d.location=v.location and d.date=v.date
where d.continent != 'NULL'


select * from pop_vac3;