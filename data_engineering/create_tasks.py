import random
import string
from PG import mypg

# random text generator
def draw_random(numlets):
    letters = string.ascii_letters + ' '*10
    ll = random.choices(letters, k=numlets)
    return ''.join(ll)

# database interaction class
pg = mypg()

# get the project id and department id from projects table
# order by department id
prj_by_dept = pg.sql_query(
    """
    select proj_id, dept_id from employee.projects
    order by dept_id;
    """
)


# get first dept id in query and get all employees from that dept 
_, current_dept = prj_by_dept[0]
current_emps = pg.col_as_list(
                    table='employee.dept_emp', 
                    column='emp_no', 
                    where="dept_no = '{}'".format(current_dept)
                )


# list to hold INSERT VALUE strings
insert_value_strings = []

# loop through every projectk
for prj, dept in prj_by_dept:

    #chek if dept has changed and requery the department if it has
    if dept != current_dept:
        current_dept = dept
        current_emps = pg.col_as_list(
                            table='employee.dept_emp', 
                            column='emp_no', 
                            where="dept_no = '{}'".format(current_dept)
                        )

       
    # assign a random number of tasks to each project
    tasks_in_proj = random.randint(5,50)

    # for each task assign a random task manager
    for _ in range(tasks_in_proj):
        task_mngr = random.choice(current_emps)
        task_desc = draw_random(random.randint(20,199))
        insert_value_strings.append(
            "({},{},'{}')".format(prj, task_mngr, task_desc)
        )

values = ",\n".join(insert_value_strings)
pg.sql_run(
    """
    INSERT INTO employee.tasks(project_id, task_mngr, task_description)
    VALUES
    {};
    """.format(values)
)