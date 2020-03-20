
/*

-- 1) What is the gender breakdown of the company
SELECT
	ROUND( 100 *
		(SELECT COUNT(*)::NUMERIC FROM employee.employees e WHERE e.gender = 'F')/
		(SELECT COUNT(*)::NUMERIC FROM employee.employees)
		,2 ) as Percent_Female,
	ROUND( 100 *
		(SELECT COUNT(*)::NUMERIC FROM employee.employees e WHERE e.gender = 'M')/
		(SELECT COUNT(*)::NUMERIC FROM employee.employees)
		,2 ) as Percent_Male


-- 2) Who are the highest and lowest paid employees
SELECT e.emp_no, e.first_name, e.last_name, sm.salary
FROM employee.employees e
JOIN ( 
		SELECT s.emp_no, s.salary
		FROM employee.salaries s
		WHERE s.salary = (SELECT MIN(s.salary) FROM employee.salaries s)
		OR s.salary = (SELECT MAX(s.salary) FROM employee.salaries s)
	 ) sm
ON e.emp_no = sm.emp_no


-- 3) How many people currently work each job title in the company
SELECT t.title, COUNT(*) AS employee_count
	FROM employee.titles t
	WHERE t.to_date > current_date
	GROUP BY t.title


-- 4) What is the average salary for each job title
SELECT t.title, ROUND(AVG(s.salary),2) as average_salary
	FROM employee.titles t
	JOIN employee.salaries s
	ON t.emp_no = s.emp_no
	GROUP BY t.title
	ORDER BY average_salary


-- 5) How much department managers make in salary compared to their employees
SELECT d.dept_name, ROUND(s.salary,2) AS manager_salary, 
ROUND(avg_emp_sal.average_employee_salary,2) AS average_employee_salary

FROM employee.departments d
JOIN employee.dept_manager dm
ON d.dept_no = dm.dept_no
JOIN employee.salaries s
ON s.emp_no = dm.emp_no
JOIN
	(
		SELECT adepts.dept_name, AVG(asal.salary) as average_employee_salary
		FROM employee.salaries asal
		JOIN employee.dept_emp aemp
		ON asal.emp_no = aemp.emp_no
		JOIN employee.departments adepts
		ON aemp.dept_no = adepts.dept_no
		GROUP BY adepts.dept_name
	) avg_emp_sal
ON d.dept_name = avg_emp_sal.dept_name
WHERE dm.to_date > current_date
AND s.to_date > current_date;



-- 6) How long did the current manager of the each department work for the company before becoming a manager?
SELECT current_managers.dept_name AS department, 
joined_company.start_day AS started_at_company, 
current_managers.from_date AS started_as_manager,
make_interval(years => ((current_managers.from_date - joined_company.start_day)/365))
AS years_working_before_manager
FROM 
	(
		SELECT  dm.dept_no, depts.dept_name, dm.emp_no, dm.from_date
		FROM employee.dept_manager dm
		JOIN employee.departments depts
		ON depts.dept_no = dm.dept_no
		WHERE dm.to_date > current_date
	) current_managers
JOIN
	(
		SELECT t.emp_no, MIN(t.from_date) as start_day
		FROM employee.titles t
		JOIN employee.dept_manager dm
		ON t.emp_no = dm.emp_no
		GROUP BY t.emp_no
	) joined_company
ON current_managers.emp_no = joined_company.emp_no;



-- 7) How many employees have held 3 different titles at the company
SELECT title_count.num_titles, COUNT(title_count.emp_no)
FROM
	(
		SELECT t.emp_no, COUNT(t.title) as num_titles
		FROM employee.titles t
		GROUP BY t.emp_no
		ORDER BY num_titles DESC
	) title_count
WHERE title_count.num_titles = 3
GROUP BY title_count.num_titles;



-- 8) How many employees are named Eric?
SELECT COUNT(*) as erics_in_company
FROM employee.employees e
WHERE e.first_name = 'Eric';
	 


-- 9) How many people currently work in each department
SELECT d.dept_name, COUNT(de.emp_no) as employee_count
FROM employee.departments d
JOIN employee.dept_emp de
ON d.dept_no = de.dept_no
WHERE de.to_date > current_date
GROUP BY d.dept_name;



-- 10) How much does the company currently pay for all salaries
SELECT SUM(s.salary) AS cost_of_salaries
FROM employee.salaries s
WHERE s.to_date > current_date;


__________________________________________________________________________________________________________________
__________________________________________________________________________________________________________________
TASKS ON ADDITION TO THE EMPLOYEE DATABASE


-- 11) How many different projects does each department have going
SELECT d.dept_name, COUNT(p.proj_id) as project_count
FROM employee.departments d
JOIN employee.projects p
ON d.dept_no = p.dept_id
GROUP BY d.dept_name;



-- 12) What are the names of the projects under the Human Resources department
SELECT d.dept_name, p.proj_name
FROM employee.departments d
JOIN employee.projects p
ON d.dept_no = p.dept_id
WHERE d.dept_name = 'Human Resources';




-- 13) Which employees are both department managers and project managers
SELECT dm.emp_no, dm.dept_no, p.proj_id
FROM employee.dept_manager dm
JOIN employee.projects p
ON dm.emp_no = p.prj_mngr;


-- 14) Which employees are both project managers and task managers
SELECT e.first_name, e.last_name, p.proj_name, t.task_id
FROM employee.tasks t
JOIN employee.projects p
ON t.task_mngr = p.prj_mngr
JOIN employee.employees e
ON t.task_mngr = e.emp_no
WHERE p.proj_id = t.project_id



-- 15) What are the three most common job titles for project managers
SELECT t.title, COUNT(*) AS title_count
FROM employee.titles t
JOIN employee.projects p
ON t.emp_no = p.prj_mngr
GROUP BY t.title
LIMIT 3;


-- Creation of index for fast lookup of work performed in given range
CREATE INDEX work_log_timestamp_range_idx ON employee.work_log(start_timestamp, end_timestamp)



-- 16) How many work logs have been submitted so far this year?
SELECT COUNT(*) AS submitted_work_logs_2020
FROM employee.work_log wl
WHERE wl.start_timestamp > '2020-01-10'::DATE;



-- 17) Who are the 10 star employees of 2019 in terms of hours logged (most hours logged in 2019)
SELECT e.emp_no, e.first_name, e.last_name, tlog.time_logged
FROM
	(
		SELECT wl.emp_no, SUM(wl.end_timestamp-wl.start_timestamp) as time_logged
		FROM employee.work_log wl
		WHERE wl.start_timestamp >= '2019-01-01'::DATE
		AND wl.end_timestamp < '2020-01-10'::DATE
		GROUP BY wl.emp_no
	) tlog
JOIN employee.employees e
ON tlog.emp_no = e.emp_no
ORDER BY tlog.time_logged DESC
LIMIT 10;



-- 18) How much time has been put into each task in the 'Dark Years' project
SELECT dark_year.proj_name, dark_year.task_id, 
sum(wl.end_timestamp - wl.start_timestamp) time_on_task
FROM
	(
		SELECT p.proj_id, p.proj_name, t.project_id, t.task_id
		FROM employee.projects p
		JOIN employee.tasks t
		ON p.proj_id = t.project_id
		WHERE p.proj_name = 'Dark Years'
	) dark_year
JOIN employee.work_log wl
ON dark_year.task_id = wl.task_id
GROUP BY (dark_year.proj_name, dark_year.task_id)
ORDER BY time_on_task DESC;



-- 19) Which employees worked on the 'Dark Years' project in June of 2018?
SELECT e.emp_no, e.first_name, e.last_name
FROM employee.employees e
JOIN employee.work_log wl
ON wl.emp_no = e.emp_no
WHERE wl.start_timestamp >= '2018-06-01'::DATE
AND wl.end_timestamp < '2018-07-01'::DATE
AND wl.task_id IN
	(
		SELECT t.task_id
		FROM employee.tasks t
		JOIN employee.projects p
		ON p.proj_id = t.project_id
		WHERE p.proj_name = 'Dark Years'
	)



-- 20) A system crash happened on New Years 2020 at around 4:00pm! 
--     Which employees loged work on that day in the hours adjacent to the crash?
SELECT e.emp_no, e.first_name, e.last_name, l.end_timestamp AS commited, l.summary AS summary_of_work
FROM employee.employees e
JOIN employee.work_log l
ON e.emp_no = l.emp_no
WHERE l.end_timestamp > '2020-01-01 15:00:00'::TIMESTAMP
AND l.end_timestamp < '2020-01-01 17:00:00'::TIMESTAMP;

*/
