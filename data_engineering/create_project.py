from PG import mypg
import random

prj_mng_titles = "('Senior Engineer', 'Manager','Senior Staff','Technique Leader')"

# database interaction class
pg = mypg()

# get department numbers as list
department_list = pg.col_as_list('employee.departments', 'dept_no')

# get list of spy.mission names (using as project names)
project_names = pg.col_as_list('spy.mission', 'name')

# get dictionary of potential project managers
# key=dept_no val=list(emp_no)
dept_proj_mngrs = {}
for dept in department_list:
    dept_proj_mngrs[dept] = pg.sql_query(
        """
        SELECT emp_no
        FROM employee.titles T
        NATURAL JOIN employee.dept_emp DE
        WHERE DE.dept_no = '{}'
        AND T.title IN {}
        """.format(dept, prj_mng_titles)
    )

# randomly select employees to be project managers
# prepare string for INSERT VALUES, store in list
insert_value_strings = []
for name in project_names:
    rand_dept = random.choice(department_list)
    rand_mang = random.choice(dept_proj_mngrs[rand_dept][0])
    insert_value_strings.append(
        "('{}','{}',{})".format(name,rand_dept,rand_mang)
    )


# run INSERT VALUES
values = ",\n".join(insert_value_strings)
pg.sql_run(
    """
    INSERT INTO employee.projects (proj_name, dept_id, prj_mngr)
    VALUES
    {};
    """.format(values)
)

