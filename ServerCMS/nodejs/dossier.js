//dossier.js  el back office de dossier

var express = require('express');
var app = express();
const port = 3000;

//app.use(express.json());
const bodyParser = require('body-parser');
app.use(bodyParser.urlencoded({ extended: true }));

app.use(bodyParser.json())

app.get('/', function(req,res) {
    res.send('Epa Chamin, aqui estoy para ayudarte!!!');
})

app.get('/dossier', function(req,res) {
    res.send('Llamando a Dossier!!!');
})

app.get('/dossier/json', function(req,res) {
    res.json({"nombre":"luis","apellido":"bermudez","nick":"rtnzmayor"});
})

app.get('/dossier/img/:fname', function(req,res) {
    var fileName = req.params.fname;
    res.sendFile(__dirname+'/'+fileName);
})

app.post('/post',function (request, response){
    //response.end('Aqui estoy posteando...');
     response.json(request.body);    // echo the result back
  })

app.listen(port,function(){
    console.log('Escuchando por el 3000</br>Path is '+ __dirname);
})