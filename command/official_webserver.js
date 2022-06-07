var express = require('express');
var server = express();


server.get('/', function(req, res) {
    //res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25-main 2/command/rover_mainpage.html'); 
    res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25-main 2/command/rover_mainpage.html'); 
});

server.get('/rover_mainpage.html', function(req, res) {
    //res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25-main 2/command/rover_mainpage.html'); 
    res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25-main 2/command/rover_mainpage.html'); 
});

server.get('/rover_explore.html', function(req, res) {
    //res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25-main 2/command/rover_mainpage.html'); 
    res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25-main 2/command/rover_explore.html'); 
});

server.get('/rover_map.html', function(req, res) {
    //res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25-main 2/command/rover_mainpage.html'); 
    res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25-main 2/command/rover_map.html'); 
});

server.get('/rover_about.html', function(req, res) {
    //res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25-main 2/command/rover_mainpage.html'); 
    res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25-main 2/command/rover_about.html'); 
});

console.log('Server is running on port 3000'); 
server.listen(3000,'0.0.0.0');