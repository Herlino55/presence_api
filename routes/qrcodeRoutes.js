const express = require('express');
const router = express.Router();
const qrcodeController = require('../controllers/qrcodeController');
const authMiddleware = require('../middlewares/authMiddleware')

router.get('/generate/:courseId/:type',authMiddleware, qrcodeController.getQRcode);

module.exports = router;
