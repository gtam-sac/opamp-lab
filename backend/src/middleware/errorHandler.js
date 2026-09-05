/**
 * Centralized error handler. Never leaks raw DB/driver errors to the
 * client - logs the real error server-side and returns a clean,
 * generic message instead.
 */
function errorHandler(err, req, res, _next) {
  console.error('[Unhandled error]', err);

  if (err && err.code === 'ER_DUP_ENTRY') {
    return res.status(409).json({ message: 'That email address is already registered.' });
  }

  if (err && (err.code === 'ECONNREFUSED' || err.code === 'PROTOCOL_CONNECTION_LOST')) {
    return res.status(503).json({ message: 'Database is currently unavailable. Please try again shortly.' });
  }

  return res.status(500).json({ message: 'Something went wrong on the server. Please try again.' });
}

function notFoundHandler(req, res) {
  res.status(404).json({ message: `Route not found: ${req.method} ${req.originalUrl}` });
}

module.exports = { errorHandler, notFoundHandler };
