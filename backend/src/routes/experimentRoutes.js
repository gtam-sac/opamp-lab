const express = require('express');
const experimentController = require('../controllers/experimentController');
const { requireAuth } = require('../middleware/authMiddleware');

const router = express.Router();

// All experiment routes require a logged-in user.
router.use(requireAuth);

router.post('/', experimentController.saveSession);
router.get('/', experimentController.listSessions);
router.delete('/:id', experimentController.deleteSession);

module.exports = router;
