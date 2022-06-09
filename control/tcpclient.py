import socket, pickle, os
from pathlib import Path
import select
from sys import getsizeof

#the server name and port client wishes to access 'ec2-34-230-42-217.eu-west-2.compute-1.amazonaws.com'
server_name = 'ec2-52-91-190-128.compute-1.amazonaws.com'

server_port = 12000 
#create a TCP client socket 


#Set up a TCP connection with the server 
#connection_socket will be assigned to this client on the server side 

dir_path = Path(os.path.dirname(os.path.realpath(__file__)))
os.makedirs(dir_path/"tmp", exist_ok=True)

#client_socket.setblocking(0)
#print ("Client Socket Created")

def send_command(command_and_data):
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        client_socket.connect((server_name, server_port))
    except:
        print("Could not connect to server")
        return False
    timeout_in_seconds = 0.5
    data = pickle.dumps(command_and_data)  

    #send the message to the TCP server 
    client_socket.send(data)
    print("Data Sent")
        
        
    with open(dir_path/"tmp"/"data.pickle","wb") as file_handle:

        #OPTION 1
        ready = select.select([client_socket], [], [], timeout_in_seconds)
        #print("Passed first select")
        while ready[0]:
            #print("In while loop")
            msg = client_socket.recv(2048)
            file_handle.write(msg)
            ready = select.select([client_socket], [], [], timeout_in_seconds)
            #print(ready)

        #OPTION 2
        # msg = client_socket.recv(2048)
        # print("Response from server")
        # file_handle.write(msg)
        # print("Wrote to pickle file")

            
        

        print("All data received")

    with open(dir_path/"tmp"/"data.pickle","rb") as file_handle:
        out = pickle.load(file_handle)
    print("Response loaded. Size: " + str(getsizeof(out)) + " bytes")
    #data.pickle has what we want. MIGHT BE CHANGED since we might not send pickled data from server to client.
    
    #dump from file into out

    #out is data we want, such as db query response


    client_socket.close()
    return out
    