var express = require('express');
var server = express();

server.get('/', function(req, res) {
    res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25/command/rover_mainpage.html'); 
    //res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25/command/rover_mainpage.html'); 
});

server.get('/rover_mainpage.html', function(req, res) {
    res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25/command/rover_mainpage.html'); 
    //res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25/command/rover_mainpage.html'); 
});

server.get('/rover_explore.html', function(req, res) {
    res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25/command/rover_explore.html'); 
    //res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25/command/rover_explore.html'); 
});

server.get('/rover_map.html', function(req, res) {
    res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25/command/rover_map.html'); 
    //res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25/command/rover_map.html'); 
});

server.get('/rover_about.html', function(req, res) {
    res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25/command/rover_about.html'); 
    //res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25/command/rover_about.html'); 
});

server.get('/foreign-alien.ttf', function(req, res) {
     res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25/command/foreign-alien.ttf'); 
    //res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25/command/foreign-alien.ttf'); 
});

server.get('/Astronomus.ttf', function(req, res) {
     res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25/command/Astronomus.ttf'); 
    //res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25/command/Astronomus.ttf'); 
});

server.get('/Roboto-Light.ttf', function(req, res) {
    res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25/command/Roboto-Light.ttf'); 
    //res.sendFile('/home/ubuntu/command/Roboto-Light.ttf');
    //res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25/command/Roboto-Light.ttf'); 
});

var button = document.getElementById("")

server.get('/mars_pic.jpg', function(req, res) {
    res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25/command/mars_pic.jpg'); 
    //res.sendFile('/home/ubuntu/command/mars_pic.jpg');
    //res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25/command/Roboto-Light.ttf'); 
});

server.get('/mars_pic2.jpg', function(req, res) {
    res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25/command/mars_pic2.jpg');
    //res.sendFile('/home/ubuntu/command/mars_pic2.jpg');
    //res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25/command/Roboto-Light.ttf'); 
});

server.get('/nightsky.jpeg', function(req, res) {
    res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25/command/nightsky.jpeg');
    //res.sendFile('/home/ubuntu/command/nightsky.jpeg');
    //res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25/command/nightsky.jpeg'); 
});

server.get('/about_page.png', function(req, res) {
    res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25/command/about_page.png');
    //res.sendFile('/home/ubuntu/command/about_page.png');
    //res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25/command/about_page.png'); 
});

server.get('/Roverium.png', function(req, res) {
    res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25/command/Roverium.png'); 
    //res.sendFile('/home/ubuntu/command/Roverium.png');
    //res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25/command/about_page.png'); 
});

server.get('/grid.jpeg', function(req, res) {
    res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25/command/grid.jpeg'); 
    //res.sendFile('/home/ubuntu/command/Roverium.png');
    //res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25/command/grid.jpeg'); 
});

server.get('/mars_backdrop.jpeg', function(req, res) {
    res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25/command/mars_backdrop.jpeg'); 
    //res.sendFile('/home/ubuntu/command/Roverium.png');
    //res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25/command/mars_backdrop.jpeg'); 
});

server.get('/marstoearth.jpeg', function(req, res) {
    res.sendFile('/home/ubuntu/Mars-Rover-Project-Group-25/command/marstoearth.jpeg'); 
    //res.sendFile('/home/ubuntu/command/Roverium.png');
    //res.sendFile('/Users/aryanrana/Desktop/Mars-Rover-Project-Group-25/command/mars_backdrop.jpeg'); 
});

console.log('Server is running on port 3000'); 
server.listen(3000,'0.0.0.0');