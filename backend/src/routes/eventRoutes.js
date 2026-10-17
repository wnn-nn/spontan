const express = require('express');
const router = express.Router();
const eventController = require('../controllers/eventController');
const authMiddleware = require('../middleware/authMiddleware');

// Seluruh endpoint event dilindungi oleh authMiddleware
router.use(authMiddleware);

router.get('/', eventController.getMyEvents);
router.post('/', eventController.createEvent);
router.put('/:id', eventController.updateEvent);

module.exports = router;
