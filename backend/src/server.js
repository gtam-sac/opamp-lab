require('dotenv').config();
const app = require('./app');
const { verifyConnection } = require('./config/db');

const PORT = process.env.PORT || 4000;

async function start() {
  try {
    await verifyConnection();
    console.log('Connected to MySQL/MariaDB successfully.');
  } catch (err) {
    console.error('Could not connect to the database. Check your .env settings.');
    console.error(err.message);
    process.exit(1);
  }

  app.listen(PORT, () => {
    console.log(`Op-Amp Lab backend listening on http://localhost:${PORT}`);
  });
}

start();
