import random
from PG import mypg

# database interaction class
pg = mypg()

# get the project id and department id from projects table
# order by department id
task_by_dept = pg.sql_query(
    """
    SELECT p.dept_id, t.task_id, t.task_mngr
    FROM employee.projects p
    RIGHT JOIN employee.tasks t
    ON p.proj_id = t.project_id
    ORDER BY p.dept_id
    """
)


# retrieve employee ids from first department in task list
curr_dept = task_by_dept[0][0]
curr_dept_employees = pg.sql_query(
    """
    SELECT de.dept_no, de.emp_no
    FROM employee.dept_emp de
    WHERE de.dept_no = '{}'
    """.format(curr_dept)
)


# holds insert values for query
insert_value_strings = []

# loop through each task adding random employees until dept changes
for task in task_by_dept:
    curr_task_id = task[1]
    curr_task_mngr = task[2]

    # when dept changes re-query employees from new department
    if task[0] != curr_dept:
        curr_dept = task[0]
        curr_dept_employees = pg.sql_query(
            """
            SELECT de.dept_no, de.emp_no
            FROM employee.dept_emp de
            WHERE de.dept_no = '{}'
            """.format(curr_dept)
        )

    print("Dept: {} \t Task{}".format(curr_dept, curr_task_id))



    # hold list of employees for current task
    task_emp_list = []

    # add task manager
    task_emp_list.append(curr_task_mngr)

    # between 10 and 50 emps per task + mngr
    emps_per_task = random.randint(10,50)
    for _ in range(emps_per_task):
        task_emp = random.choice(curr_dept_employees)
        print("Emp Dept: {} \t Emp No: {}".format(task_emp[0], task_emp[1]), end='\r')
        if task_emp not in task_emp_list: 
            task_emp_list.append(task_emp[1])

    for e in task_emp_list:
        insert_value_strings.append(
                "({},{})".format(curr_task_id, e)
            )

# insert values into table
insert_value_strings = list(set(insert_value_strings))
values = ",\n".join(insert_value_strings)
pg.sql_run(
    """
    INSERT INTO employee.task_team(task_id, emp_no)
    VALUES
    {};
    """.format(values)
)


if 1:
    print('done')