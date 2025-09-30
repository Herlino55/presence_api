const express = require('express');
const router = express.Router();
const courseController = require('../controllers/coursController');
const authMiddleware = require('../middlewares/authMiddleware');

router.post('/CreateCours', authMiddleware, courseController.createCourse);
router.get('/ReadCours', authMiddleware, courseController.getMyCourses);

module.exports = router;
