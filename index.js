const express = require('express');
const app = express();
const PORT = 3000;
const authRoutes = require('./routes/authRoutes');
const presenceRoutes = require('./routes/presenceRoutes');
require('dotenv').config();
const authMiddleware = require('./middlewares/authMiddleware');
const QRcodeRoutes = require('./routes/qrcodeRoutes');
const courseRoutes = require('./routes/coursRoutes');
const adminRoutes = require('./routes/adminRoutes');
const studentRoutes = require('./routes/studentRoutes');
const cors = require('cors');
const path = require('path');

// Middleware pour lire les requêtes JSON
app.use(express.json());

// Route de test
app.get('/', (req, res) => {
  res.status(200).send('API de gestion de présence démarrée ✔️');
});
app.get('/apropos', (req,res)=>
{
    res.send('Cette API permet de gérer la présence des étudiants dans les cours. Elle est conçue pour être utilisée avec une application front-end qui affiche les données de présence.');
})

app.get('/upload',(req,res) =>{
  res.status(200).send('interessant');
});

app.use('/teacher', authRoutes);

app.use('/admin', adminRoutes);

app.use('/student', studentRoutes);

app.use('/presence', presenceRoutes);

app.use('/qrcode', QRcodeRoutes);

app.use('/cours',courseRoutes);
  
app.use((req,res) =>{
    res.status(404).send('erreur ! URL incorrect');
})


app.use((req,res, next) =>{
    // res.status(404).send('erreur ! URL incorrect');
    console.log(`${req.method}`,res.url);
    next();
})

app.use('/uploads',authMiddleware, express.static(path.join(__dirname, 'uploads')));



app.use(cors(
  {
    origin: '*',
    methods: ['GET', 'POST', 'DELETE'],
    allowedHeaders: ['Content-Type','Authorization']
  }
));

// Démarrage du serveur
app.listen(PORT,'0.0.0.0', () => {
  console.log(`Serveur lancé sur https://presenceapi-production.up.railway.app:${PORT}`);
});
