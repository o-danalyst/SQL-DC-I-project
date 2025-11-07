create database global_job_layoffs;
use global_job_layoffs;
-- duplicate table
CREATE TABLE `layoffs1` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs1
select *
from layoffs;

-- confirm that the duplicate table is populated
select *
from layoffs
where company = 'ola';

-- start data cleaning
-- 1st step remove duplicates
-- identify duplicates
select *, row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as detector
from layoffs1;
-- remove duplicates
CREATE TABLE `layoffs2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  detector int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs2
select *, row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,'date',stage,country,funds_raised_millions) as detector
from layoffs1;

select *
from layoffs2
where detector >= 2;

delete 
from layoffs2
where detector >= 2;

-- drop detector column
alter table layoffs2
drop column detector;

-- trim spaces
select *
from layoffs2;

select trim(company) as company
from layoffs2;

update  layoffs2
set funds_raised_millions = trim(funds_raised_millions);

-- set everything null/blank to be null
update layoffs2
set industry = null
where industry = '';

select *
from layoffs2
where country = '';

-- check for wrong spellings and correct
select distinct(industry)
from layoffs2;

update layoffs2
set industry = 'crypto'
where industry like 'crypto%';

update layoffs2
set country = trim(trailing '.' from country)
;

select *
from layoffs2;

-- inspect individual columns and standerdize the data type
select date, str_to_date(date, '%m/%d/%Y') as date
from layoffs2;

update layoffs2
set date = str_to_date(date, '%m/%d/%Y');

select * from layoffs2;

alter table layoffs2
modify column date date;

-- fill the blanks where possible
select industry
from layoffs2
where industry is null;

select *
from layoffs2
where total_laid_off is null;
select *
from layoffs2
where company like '%juul%';
update layoffs2
set industry = 'consumer'
where industry is null and company = "juul";

select *
from layoffs2 as t1
join layoffs2 as t2
 on t1.location = t2.location
 where (t1.total_laid_off is null and t2.total_laid_off is not null) and (t1.company = t2.company);
 
 update layoffs2  as t1
 join layoffs2 as t2
  on t1.location = t2.location
  set t1.total_laid_off = t2.total_laid_off
 where (t1.total_laid_off is null and t2.total_laid_off is not null) and (t1.company = t2.company);
 
 select *
 from layoffs2 as t1
 join layoffs2 as t2
 on t1.location = t2.location
 where(t1.percentage_laid_off is null and t2.percentage_laid_off is not null) and (t1.company = t2.company);
 
  update layoffs2  as t1
 join layoffs2 as t2
  on t1.location = t2.location
  set t1.percentage_laid_off = t2.percentage_laid_off
 where (t1.percentage_laid_off is null and t2.percentage_laid_off is not null) and (t1.company = t2.company);
 
 select *
 from layoffs2
 where total_laid_off is null or percentage_laid_off is null;
 
 update layoffs2
 set total_laid_off = 0
 where total_laid_off is null;
 
 update layoffs2
 set percentage_laid_off = 0
 where percentage_laid_off is null;
 
 
 select *
 from layoffs2
 where company like '2u';
 
-- delete useless rows in the dataset
select *
from layoffs2
where total_laid_off is null and percentage_laid_off is null;

delete
from layoffs2
where total_laid_off is null and percentage_laid_off is null;

-- Part 2
-- driving insights
select * from layoffs2;

-- find the total laid off
select sum(total_laid_off)
from layoffs2;

-- find total funds raised from tha table
select sum(funds_raised_millions)
from layoffs2;

-- find the distinct industries
select distinct(industry)
from layoffs2;

-- find total funds raised per industry
select industry, sum(funds_raised_millions) as indfund
from layoffs2
group by industry
order by indfund desc;

-- find the company that raised the highest amount of money
select company, sum(funds_raised_millions) as funds
from layoffs2
group by company
order by funds desc
limit 1;

-- find the highest company per industry in funds raised
select company,industry, sum(funds_raised_millions) as funds
from layoffs2
group by company,industry
order by funds desc
limit 1;

-- find the country where companies raise the highest amount of money
select country, sum(funds_raised_millions) as funds
from layoffs2
group by country
order by funds desc
limit 1;

-- find the preffered location of most companies
select location,count(location) preffered
from layoffs2
group by location
order by preffered desc
limit 1;

-- total laid off by industry
select industry,sum(total_laid_off) as laidoff
from layoffs2
group by industry
order by laidoff desc;

-- company that laid off the most workers
select company, sum(total_laid_off) laidoff
from layoffs2
group by company
order by laidoff desc
limit 1;

-- which year did the companies raised the most money
select company,date, max(funds_raised_millions) raised
from layoffs2
group by company,date
order by raised desc
limit 1;

-- list of companies that laid off staff in 2022
select company,date,total_laid_off
from layoffs2
where total_laid_off > 0 and date like "2022%";

-- the countries where healthcare and crypto industries exist
select distinct(country),industry
from layoffs2
where industry like 'health%' or industry like 'crypto'
;

-- 






 
 
 






















 






 
 




