import socket, pickle
from pathlib import Path
from server_functions import resolve
import os

#select a server port 
server_port = 12000 
#create a welcoming socket
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#bind the server to the localhost at port server_port 
server_socket.bind(("",server_port))
server_socket.listen(1) # We ask OS to start listening on this port, with the number of pending/waiting connection you'll allow
#ready message 
print('Server running on port', server_port)
#Now the main server loop 
tmp = Path("./tmp")
#server_socket.setblocking(0)
dir_path = Path(os.path.dirname(os.path.realpath(__file__)))
os.makedirs(dir_path/"tmp", exist_ok=True)

while True: 
    connection_socket, caddr = server_socket.accept() #halts until accepting a new connection
    

    # with open(tmp/"data.pickle","wb") as file_handle:
       
    #     #print("Some Data Received")

    #     file_handle.write(cmsg)
    #     print("all data received")
    cmsg = connection_socket.recv(1024)

    # with open(tmp/"data.pickle","rb") as file_handle:
    #     out = pickle.load(file_handle)
    #print("query request loaded: {out}")

    #NOW pass out to a function which will parse + make the necessary calls
    #Return list of query results
    try:
        out = pickle.loads(cmsg)
    except:
        connection_socket.send(pickle.dumps("Request failed"))
        continue
    res = resolve(out)
    print(f"resolved query: {res}")
    
    #SEND res back
    data = pickle.dumps(res)
    connection_socket.send(data)
    print("data sent back - returning to accept state")

