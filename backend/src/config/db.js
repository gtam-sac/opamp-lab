const mysql = require('mysql2/promise');
require('dotenv').config();

// A single connection pool shared by the whole app. mysql2's pool
// handles reconnects and concurrent requests for us, which is all a
// project of this size needs (no ORM required).
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  dateStrings: true,
});

/**
 * Simple helper used at server startup to confirm the database is
 * reachable before we start accepting requests. Fails loudly instead
 * of letting every request hit a confusing connection error.
 */
async function verifyConnection() {
  const connection = await pool.getConnection();
  try {
    await connection.query('SELECT 1');
  } finally {
    connection.release();
  }
}

module.exports = { pool, verifyConnection };
