const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const teacherController = require('../controllers/authController');
const studentController = require('../controllers/studentController');
const upload = require('../middlewares/upload');
const authMiddleware = require('../middlewares/authMiddleware');

router.post('/signup', adminController.register);
router.post('/login', adminController.login);

//enregistrement des enseignants
router.post('/teacher/signup',authMiddleware, upload.single('image_url'), teacherController.register);

//enregistrement des étudiants
router.post('/student/signup',authMiddleware, upload.single('image_url'), studentController.register);

router.get('/teacher/All',authMiddleware, teacherController.AllTeacher);

module.exports = router;