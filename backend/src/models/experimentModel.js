const { pool } = require('../config/db');

async function createSession(userId, session) {
  const {
    experimentType,
    waveformType,
    resistanceOhm,
    capacitanceF,
    amplitudeV,
    frequencyHz,
    notes,
  } = session;

  const [result] = await pool.query(
    `INSERT INTO experiment_sessions
      (user_id, experiment_type, waveform_type, resistance_ohm, capacitance_f, amplitude_v, frequency_hz, notes)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      userId,
      experimentType,
      waveformType,
      resistanceOhm,
      capacitanceF,
      amplitudeV,
      frequencyHz,
      notes || null,
    ]
  );

  return findById(result.insertId, userId);
}

async function findAllForUser(userId, limit = 50) {
  const [rows] = await pool.query(
    `SELECT id, experiment_type, waveform_type, resistance_ohm, capacitance_f,
            amplitude_v, frequency_hz, notes, created_at
     FROM experiment_sessions
     WHERE user_id = ?
     ORDER BY created_at DESC
     LIMIT ?`,
    [userId, limit]
  );
  return rows;
}

async function findById(id, userId) {
  const [rows] = await pool.query(
    `SELECT id, experiment_type, waveform_type, resistance_ohm, capacitance_f,
            amplitude_v, frequency_hz, notes, created_at
     FROM experiment_sessions
     WHERE id = ? AND user_id = ?
     LIMIT 1`,
    [id, userId]
  );
  return rows[0] || null;
}

async function deleteById(id, userId) {
  const [result] = await pool.query(
    'DELETE FROM experiment_sessions WHERE id = ? AND user_id = ?',
    [id, userId]
  );
  return result.affectedRows > 0;
}

module.exports = { createSession, findAllForUser, findById, deleteById };
