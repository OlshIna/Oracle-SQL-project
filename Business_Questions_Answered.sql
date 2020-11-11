-- The First Business Question: LAY OFF THE PART OF THE EMPLOYEES for savings to survive this hard COVID-19 time 

--REM   Script: BQ1_Employees_to_be_Laid_Off
--REM   15 statements

--1. HOW MANY EMPLOYEES DO WE HAVE
select count(*) as EMPLOYEES_TOTAL   
from hr.employees ;

--2. DEPARTMENTS LIST (WITH LOCATIONS)
select department_id  
    , department_name  
    , location_id  
from hr.departments  
order by location_id ;

--3. EMPLOYEES NUMBER IN DEPARTMENT
select count(distinct employee_id) as EMPLOYEES_TOTAL 
    , department_id 
from hr.employees 
group by department_id 
order by department_id ;

--4. JOINING DEPARTMENTS TO EMPLOYEES AND LOOKING FOR EMPTY DEPARTMENTS
select hr.departments.department_id 
    , department_name 
    , employee_id 
from hr.departments 
left join hr.employees   
    on hr.departments.department_id=hr.employees.department_id 
where employee_id is null ;

--5. MISSING VALUES IN OUR TABLES
-- We will see all employees and all departments and all missing IDs in one place
select distinct employee_id  
        , last_name 
        , first_name 
        , hr.employees.department_id  
        , department_name 
        , hr.employees.job_id 
        , job_title  
        , hr.employees.manager_id 
        , hr.locations.location_id 
        , hr.countries.country_id 
        , country_name 
        , hr.regions.region_id 
        , region_name 
        , hire_date 
from hr.employees 
 
left join hr.departments  
    on hr.employees.department_id=hr.departments.department_id  
left join hr.jobs on hr.employees.job_id=hr.jobs.job_id  
left join hr.locations  
    on hr.departments.location_id=hr.locations.location_id  
left join hr.countries on hr.locations.country_id=hr.countries.country_id  
left join hr.regions on hr.countries.region_id=hr.regions.region_id  
 
where hr.departments.department_id is null 
        or hr.employees.employee_id is null 
        or hr.employees.manager_id is null 
        or hr.locations.location_id is null 
        or hr.countries.country_id is null 
        or hr.regions.region_id is null ;

--6. Kimberly Grant's Salary
select salary 
from hr.employees 
where employee_id = 178 ;

--7. LOOKING FOR SALES REPRESENTATIVES WITH MANAGER_ID = 149
-- To find out all of the missing information for Kimberly Grant
select distinct employee_id  
        , last_name 
        , first_name 
        , hr.employees.department_id  
        , department_name 
        , hr.employees.job_id 
        , job_title  
        , hr.employees.manager_id 
        , hr.locations.location_id 
        , hr.countries.country_id 
        , country_name 
        , hr.regions.region_id 
        , region_name 
from hr.employees 
 
left join hr.departments  
    on hr.employees.department_id=hr.departments.department_id  
left join hr.jobs on hr.employees.job_id=hr.jobs.job_id  
left join hr.locations  
    on hr.departments.location_id=hr.locations.location_id  
left join hr.countries on hr.locations.country_id=hr.countries.country_id  
left join hr.regions on hr.countries.region_id=hr.regions.region_id  
 
where job_title = 'Sales Representative' and hr.employees.manager_id = 149 
 
order by employee_id ;

--8. CORRECTED EMPLOYEES NUMBER IN DEPARTMENTS
select count(distinct employee_id) as EMPLOYEES_TOTAL 
    , coalesce(department_id, 80) as Department_ID 
from hr.employees 
group by coalesce(department_id, 80) 
order by department_id ;

--9. SALARY DISTRIBUTION IN DEPARTMENTS
select count(distinct employee_id) as EMPLOYEE_TOTAL 
    , sum(salary) as TOTAL_SALARY 
    , max(salary) as MAX_SALARY 
-- rounding average salary 
    , round(avg(salary)) as AVG_SALARY 
    , UPPER(coalesce(department_name, 'Sales')) as DEPARTMENT_NAME  
from hr.employees  
inner join hr.departments  
    on coalesce(hr.employees.department_id, 80) =  
    coalesce(hr.departments.department_id, 80) 
group by department_name 
order by total_salary desc ;

--10. CLOSER LOOK AT EXECUTIVE, SALES, SHIPPING AND FINANCE DEPARTMENTS
select  employee_id  
-- the last and first names were joined to one column named Full_Name  
    , UPPER(last_name)||' '||first_name as FULL_NAME  
    , department_name  
    , job_title  
    , salary  
-- changing the date format to YYYY   
    , to_char(hire_date,'YYYY') as HIRE_DATE  
-- counting rows in each department separately  
    , (row_number() over (partition by department_name order by employee_id))   
        as Row_Number  
from hr.employees  
inner join hr.departments   
    on coalesce(hr.employees.department_id, 80) =   
    coalesce(hr.departments.department_id, 80)  
inner join hr.jobs on hr.employees.job_id = hr.jobs.job_id  
where department_name = 'Executive'   
    or coalesce(department_name,'Sales') = 'Sales'    
    or department_name = 'Shipping' and salary >= 5000   
    or department_name = 'Finance' ;

--11. EMPLOYEES TO BE LAID OF
-- Creating view to use it later, when needed
create view  empl_laid_off as 
select distinct employee_id  
    , UPPER(last_name)||' '||first_name as FULL_NAME  
    , hr.departments.department_id  
    , job_title  
    , salary  
    , to_char(hire_date,'YYYY') as HIRE_DATE 
-- Writing full email addresses 
    , LOWER(email)||coalesce (null, '@jb.com ') as EMAIL_ADDRESS 
from hr.employees  
inner join hr.departments   
    on coalesce(hr.employees.department_id, 80) =   
    coalesce(hr.departments.department_id, 80)  
inner join hr.jobs on hr.employees.job_id = hr.jobs.job_id  
where department_name = 'Executive' and to_char(hire_date,'YYYY') = '2001'  
    or department_name = 'Finance' and salary <7800  
    or department_name = 'Shipping' and salary > 5000 and salary < 8000  
    or job_title = 'Sales Representative' and salary <= 7000   
        and to_char(hire_date,'YYYY')  = '2008' ;

--11.1 CREATED VIEW                          
select * 
from empl_laid_off  
order by employee_id, department_id ;

--12. SAVINGS PER MONTH AND YEAR
-- Using the view from the 11th statement
select count(distinct employee_id) as LAID_OFF_TOTAL  
    , sum(salary) AS SAVINGS_PER_MONTH  
    , sum(salary)*12 as SAVINGS_PER_YEAR  
    , round(((count(employee_id)/107)*100),1) as PERCENT_OF_TOTAL_EMPLOYEES  
from empl_laid_off ;

--13. EMAILS TO EMPLOYEES WHO WILL BE LAID OFF
-- Using the view from the 11th statement                
select full_name 
    , email_address 
from empl_laid_off ;

--14. SENT EMAILS 
-- Using the view from the 11th statement           
select full_name 
-- Adding an empty column to use later (when an email is sent) 
    , coalesce (null, ' ') as EMAIL_SENT 
from empl_laid_off ;

 
            
-- The Second Business Question: RELOCATE THE PART OF THE EMPLOYEES from departments with the highest number of employees
            
--REM   Script: BQ2_Employees_to_be_Relocated
--REM   2 statements
            
 select distinct employee_id 
    , hr.departments.department_id 
    , department_name 
    , hr.departments.location_id 
    , country_name, city 
    , hr.countries.country_id 
    , region_id 
    , salary 
from hr.employees 
full outer join hr.departments  
    on coalesce(hr.departments.department_id, 80) =  
        coalesce(hr.employees.department_id,80) 
full outer join hr.locations  
    on hr.departments.location_id = hr.locations.location_id 
full outer join hr.countries  
    on hr.locations.country_id = hr.countries.country_id 
where department_name = 'Shipping'  
    or coalesce(department_name, 'Sales') = 'Sales' ;    
            
select distinct employee_id 
    , hr.departments.department_id 
    , department_name 
    , hr.departments.location_id 
    , country_name, city 
    , hr.countries.country_id 
    , region_id 
    , salary  
from hr.employees 
full outer join hr.departments  
    on hr.departments.department_id = hr.employees.department_id 
full outer join hr.locations  
    on hr.departments.location_id = hr.locations.location_id 
full outer join hr.countries  
    on hr.locations.country_id = hr.countries.country_id 
where coalesce(department_name, 'Sales') = 'Sales' and salary >= ( 
         select round(avg(salary)) as AVG_SALARY 
         from hr.employees  
          where coalesce(hr.employees.department_id, 80) = 80 
          ) 
    or 
     department_name = 'Shipping' and salary > ( 
         select round(avg(salary)) as AVG_SALARY 
         from hr.employees  
         where hr.employees.department_id = 50 
    )    
order by department_name, salary desc
    and employee_id is NOT NULL and salary is NOT NULL 
order by department_name ;                      
