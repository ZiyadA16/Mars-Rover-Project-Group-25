from server_db_functions import *

def resolve(input):
    out = []
    #print("in resolve")
    '''
    if input[0] == "all":
        #in is the unpickled list[all, name, score, date]
        out.append(query_rq(input[1], dynamodb=None)) #returns list of dictionary which has attribute: value

        out.append(put_row(input[1], input[2], input[3])) #return dictionary with bunch of stuff (might be single element list) - most importantly https status code which you can use to decide to retry or not

        #out.append(query_top10())

        return out
    '''
    elif input[0] == "rq":
        out.append(query_rq(dynamodb=None))
        #out = sorted(out)
        return out[0]

    elif input[0] == "input":
        out.append(put_row(input[1], input[2], input[3])) #(might be single element list)
        return out
    else:
        #print("Query incorrect/not supported")
        return "I'm disappointed"