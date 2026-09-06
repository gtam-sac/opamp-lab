const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const experimentRoutes = require('./routes/experimentRoutes');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');

const app = express();

// In development, allow any origin so "flutter run -d chrome" (which
// uses a random localhost port) works without extra configuration.
// In production, restrict to CORS_ORIGIN from the environment.
const corsOrigin =
  process.env.NODE_ENV === 'production' ? process.env.CORS_ORIGIN : true;
app.use(cors({ origin: corsOrigin }));

app.use(express.json());

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', service: 'opamp-lab-backend' });
});

app.use('/api/auth', authRoutes);
// Keep the legacy path working for frontend builds made before the /api prefix
// was added.
app.use('/auth', authRoutes);
app.use('/api/experiments', experimentRoutes);

app.use(notFoundHandler);
app.use(errorHandler);

module.exports = app;
