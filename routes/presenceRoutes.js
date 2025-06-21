const express = require('express');
const router = express.Router();
const authMiddleware = require('../middlewares/authMiddleware');
const presenceController = require('../controllers/presenceController');

router.post('/start',authMiddleware, presenceController.start);
router.post('/end',authMiddleware, presenceController.end);
router.get('/student',authMiddleware, presenceController.getByStudent);
router.get('/PresenceByCours/:courseId/:date',authMiddleware, presenceController.getPresenceParCoursEtDate);
router.get('/PresenceByCoursImg/:courseId/:date',authMiddleware, presenceController.getPresenceParCoursEtDateImg);
router.get('/MesHistoriques',authMiddleware,presenceController.MesHistoriques)

module.exports = router;