const {v4:uuidv4} = require('uuid');
const express = require('express');

const app = express();
// const ipAddress="http://localhost:3000";
const ipAddress="http://192.168.67.154:3000";

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb' }));

app.use('/imgs', express.static('pictures'));

app.get('/', (request, response) => {
  response.set('Content-Type', 'text/html');
  response.send(Buffer.from('<h2>Servidor de Arquivos Base64</h2>'));
});

app.post('/', (request, response) => {
  let base64Data = request.body.file.replace(/^data:image\/png;base64,/, "");
  const nameFile = `${uuidv4()}.${request.body.extension}`;
  require("fs").writeFile(`./pictures/${nameFile}`, base64Data, 'base64', function (err) {
    console.log(err);
    return response.status(500).end();
  });

  const json = {link:`${ipAddress}/imgs/${nameFile}`};
  return response.json(json);
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});