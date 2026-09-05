const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const VALID_EXPERIMENT_TYPES = ['differentiator', 'integrator'];
const VALID_WAVEFORM_TYPES = ['sine', 'square', 'triangle'];

function isNonEmptyString(value) {
  return typeof value === 'string' && value.trim().length > 0;
}

function validateSignup({ name, email, password }) {
  const errors = [];

  if (!isNonEmptyString(name)) errors.push('Name is required.');
  if (!isNonEmptyString(email) || !EMAIL_REGEX.test(email.trim())) {
    errors.push('A valid email address is required.');
  }
  if (!isNonEmptyString(password) || password.length < 6) {
    errors.push('Password must be at least 6 characters long.');
  }

  return errors;
}

function validateLogin({ email, password }) {
  const errors = [];

  if (!isNonEmptyString(email)) errors.push('Email is required.');
  if (!isNonEmptyString(password)) errors.push('Password is required.');

  return errors;
}

function isFiniteNumber(value) {
  return typeof value === 'number' && Number.isFinite(value);
}

function validateExperimentSession(body) {
  const errors = [];
  const {
    experimentType,
    waveformType,
    resistanceOhm,
    capacitanceF,
    amplitudeV,
    frequencyHz,
  } = body;

  if (!VALID_EXPERIMENT_TYPES.includes(experimentType)) {
    errors.push(`experimentType must be one of: ${VALID_EXPERIMENT_TYPES.join(', ')}`);
  }
  if (!VALID_WAVEFORM_TYPES.includes(waveformType)) {
    errors.push(`waveformType must be one of: ${VALID_WAVEFORM_TYPES.join(', ')}`);
  }
  if (!isFiniteNumber(resistanceOhm) || resistanceOhm <= 0) {
    errors.push('resistanceOhm must be a positive number.');
  }
  if (!isFiniteNumber(capacitanceF) || capacitanceF <= 0) {
    errors.push('capacitanceF must be a positive number.');
  }
  if (!isFiniteNumber(amplitudeV) || amplitudeV <= 0) {
    errors.push('amplitudeV must be a positive number.');
  }
  if (!isFiniteNumber(frequencyHz) || frequencyHz <= 0) {
    errors.push('frequencyHz must be a positive number.');
  }

  return errors;
}

module.exports = {
  validateSignup,
  validateLogin,
  validateExperimentSession,
  VALID_EXPERIMENT_TYPES,
  VALID_WAVEFORM_TYPES,
};
