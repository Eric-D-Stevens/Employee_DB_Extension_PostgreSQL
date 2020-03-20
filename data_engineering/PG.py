import psycopg2 as pg

class mypg:

    def __init__(self):

        self.creds = {
            'host':'dbclass.cs.pdx.edu',
            'dbname':'win20db58',
            'user':'win20db58',
            'password':'ar3Nvvk+4h'
        }


    def sql_query(self, query):
        with pg.connect(**self.creds) as con:
            cursor = con.cursor()
            cursor.execute(query)
            rows = cursor.fetchall()

        return rows

    def sql_run(self, query):
        with pg.connect(**self.creds) as con:
            cursor = con.cursor()
            cursor.execute(query)


    def col_as_list(self, table, column, where=None):
        query_string = "SELECT {} FROM {}".format(column, table)
        if where: query_string += "\nWHERE {}".format(where)
        query_string += ";"
        query_tups = self.sql_query(query_string)
        query_list = []
        for i in query_tups:
            query_list.append(*i)
        return query_list
        

