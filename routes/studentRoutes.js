const express = require('express');
const router = express.Router();
const studentController = require('../controllers/studentController');
const upload = require('../middlewares/upload');

router.post('/login', studentController.login);

module.exports = router;