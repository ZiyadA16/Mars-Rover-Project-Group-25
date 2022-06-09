import client_functions as cf
import time
from pprint import pprint

def main():
    #yyeyey
#time.sleep(25)
    #(time,position,date)
    '''
    cf.new_row(1, 1551, 5)
    cf.new_row(2, 123314, 5)
    cf.new_row(3, 00, 5)
    cf.new_row(4, 1006, 5)
    cf.new_row(16, 1006, 10)
    '''
    
    out = cf.query_db()
    pprint(out)



if __name__ == main():
    main()