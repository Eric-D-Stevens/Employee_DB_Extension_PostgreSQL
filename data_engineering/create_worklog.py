import random
import string
from PG import mypg
import datetime

# random text generator
def draw_random(numlets):
    letters = string.ascii_letters + ' '*10
    ll = random.choices(letters, k=numlets)
    return ''.join(ll)

# database interaction class
pg = mypg()

# earliest date
earliest = datetime.datetime(2010,6,12,9,0,0)
latest = datetime.datetime.now()


# get task_team
task_team = pg.sql_query(
    """
    select task_id, emp_no
    from employee.task_team;
    """
)


# hold value enteries
insert_value_strings = []

ins = 0

# loop through each task_team and add work logs
for task_id, emp_no in task_team:

    # for loop for number of tasks per employee per task
    for _ in range(random.randint(1,3)):
        
        ins += 1
        print("INSERTION {}".format(ins), end='\r')

        # start offset
        start_year_offset = random.randint(0, 10)
        year_days = 365*start_year_offset
        start_day_offset = random.randint(0, 365)
        start_offset = datetime.timedelta(days=year_days+start_year_offset)

        # log start time
        log_start = earliest+start_offset

        # log offset
        log_day_offset = random.randint(1,365)
        log_hour_offset = random.randint(2,9)
        log_offset = datetime.timedelta(days=log_day_offset, hours=log_hour_offset)

        # log end
        log_end = log_start + log_offset

        # generate summary (random chars)
        summary = draw_random(random.randint(50,100))

        insert_value_strings.append(
            "({},{},'{}','{}','{}')".format(emp_no, task_id, summary, log_start, log_end)
        )


# (emp_no, task_id, summary, start_timestamp, end_timestamp)
print("Joining String")
values = ",\n".join(insert_value_strings)

print("Sending Upstream")
pg.sql_run(
    """
    INSERT INTO employee.work_log(emp_no, task_id, summary, start_timestamp, end_timestamp)
    VALUES
    {};
    """.format(values)
)

