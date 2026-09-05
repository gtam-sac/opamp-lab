const experimentModel = require('../models/experimentModel');
const { validateExperimentSession } = require('../utils/validators');

async function saveSession(req, res, next) {
  try {
    const errors = validateExperimentSession(req.body);
    if (errors.length > 0) {
      return res.status(400).json({ message: errors[0], errors });
    }

    const session = await experimentModel.createSession(req.user.id, req.body);
    return res.status(201).json({ session });
  } catch (err) {
    return next(err);
  }
}

async function listSessions(req, res, next) {
  try {
    const sessions = await experimentModel.findAllForUser(req.user.id);
    return res.json({ sessions });
  } catch (err) {
    return next(err);
  }
}

async function deleteSession(req, res, next) {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ message: 'Invalid session id.' });
    }

    const deleted = await experimentModel.deleteById(id, req.user.id);
    if (!deleted) {
      return res.status(404).json({ message: 'Session not found.' });
    }
    return res.status(204).send();
  } catch (err) {
    return next(err);
  }
}

module.exports = { saveSession, listSessions, deleteSession };
