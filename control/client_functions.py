from typing import Type
from tcpclient import *
'''
CALL update_all() ONLY, IT WILL HANDLE EVERYTHING
THESE ARE TO BE CALLED LOCALLY ON THE HOST MACHINE.

WRAP THIS IN TCP
'''

def new_row(time, position, date):
    try:
        return send_command(["input", time, position, date])[0]["ResponseMetadata"]["HTTPStatusCode"]
    except TypeError:
        return "Error inputting new row"
    #print(type(a))

def query_db():
    #query the database
    out = send_command(["rq"])
    #some data structure with the most recent row of the database
    return sort(out)

def sort(dict):
    recent = 0
    out = []
    for i in dict:
        if int(i['time'])>recent:
            recent = i['time']
            out = i
    return out