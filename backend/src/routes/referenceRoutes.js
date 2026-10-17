const express = require('express');
const router = express.Router();
const referenceController = require('../controllers/referenceController');

router.get('/', referenceController.getReferenceData);

module.exports = router;
