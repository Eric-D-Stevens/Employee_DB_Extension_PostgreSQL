/*
DROP TABLE employee.work_log;
DROP TABLE employee.task_team;
DROP TABLE employee.tasks CASCADE;
DROP TABLE employee.projects CASCADE;
*/

/*
-- PROJECTS TABLE --
CREATE TABLE employee.projects
(
    proj_id SERIAL,
    proj_name varchar(50) NOT NULL,
    dept_id CHARACTER(4) NOT NULL,
    prj_mngr INTEGER NOT NULL,
    CONSTRAINT projects_pkey PRIMARY KEY (proj_id),
    CONSTRAINT projects_dept_id_fkey FOREIGN KEY (dept_id)
        REFERENCES employee.departments (dept_no),
    CONSTRAINT projects_prj_mngr_fkey FOREIGN KEY (prj_mngr)
        REFERENCES employee.employees (emp_no)
);


-- TASKS TABLE --
CREATE TABLE employee.tasks
(
    task_id SERIAL,
    project_id INTEGER NOT NULL,
    task_mngr INTEGER NOT NULL,
	task_description VARCHAR(200),
    CONSTRAINT tasks_pkey PRIMARY KEY (task_id),
    CONSTRAINT tasks_project_id_fkey FOREIGN KEY (project_id)
        REFERENCES employee.projects (proj_id),
	CONSTRAINT tasks_task_mngr_fkey FOREIGN KEY (task_mngr)
        REFERENCES employee.employees (emp_no)
);


-- TASK_TEAM TABLE --
CREATE TABLE employee.task_team
(
    task_id INTEGER NOT NULL,
    emp_no INTEGER NOT NULL,
    CONSTRAINT task_team_pkey PRIMARY KEY (task_id, emp_no),
    CONSTRAINT task_team_task_id_fkey FOREIGN KEY (task_id)
        REFERENCES employee.tasks (task_id),
    CONSTRAINT task_team_emp_no_fkey FOREIGN KEY (emp_no)
        REFERENCES employee.employees (emp_no)
);

-- WORK_LOG TABLE --
CREATE TABLE employee.work_log
(
    log_id SERIAL,
    emp_no INTEGER NOT NULL,
    task_id INTEGER NOT NULL,
    summary varchar(1000),
    start_timestamp TIMESTAMP NOT NULL,
    end_timestamp TIMESTAMP NOT NULL,
    CONSTRAINT work_log_pkey PRIMARY KEY (log_id),
    CONSTRAINT work_log_emp_no_fkey FOREIGN KEY (emp_no)
        REFERENCES employee.employees (emp_no),
    CONSTRAINT work_log_task_id_fkey FOREIGN KEY (task_id)
        REFERENCES employee.tasks (task_id)
);

*/