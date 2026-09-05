-- =====================================================================
-- Op-Amp Virtual Lab - Database Schema
-- "Study of Differentiator and Integrator using Operational Amplifier"
--
-- Run this once against your MySQL/MariaDB server:
--   mysql -u root -p < schema.sql
-- =====================================================================

CREATE DATABASE IF NOT EXISTS opamp_lab
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE opamp_lab;

-- ---------------------------------------------------------------------
-- Users table: stores registered lab accounts.
-- Passwords are NEVER stored in plain text - only bcrypt hashes.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(100)  NOT NULL,
  email         VARCHAR(150)  NOT NULL UNIQUE,
  password_hash VARCHAR(255)  NOT NULL,
  created_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Experiment sessions: an optional "save this run" record so a
-- student can revisit the parameters they used for a past run.
-- We intentionally do NOT log every slider movement - only the
-- parameter set active when the user explicitly saves a run.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS experiment_sessions (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id         INT UNSIGNED NOT NULL,
  experiment_type ENUM('differentiator', 'integrator') NOT NULL,
  waveform_type   ENUM('sine', 'square', 'triangle') NOT NULL,
  resistance_ohm  DOUBLE NOT NULL,
  capacitance_f   DOUBLE NOT NULL,
  amplitude_v     DOUBLE NOT NULL,
  frequency_hz    DOUBLE NOT NULL,
  notes           VARCHAR(255) NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_experiment_sessions_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  INDEX idx_user_created (user_id, created_at DESC)
) ENGINE=InnoDB;
