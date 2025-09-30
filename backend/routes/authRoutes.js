const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const upload = require('../middlewares/upload');

// Route pour l'inscription
router.post('/login', authController.login);

module.exports = router;